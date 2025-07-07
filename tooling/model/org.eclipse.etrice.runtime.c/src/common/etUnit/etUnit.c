/*******************************************************************************
 * Copyright (c) 2011 protos software gmbh (http://www.protos.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * which accompanies this distribution, and is available at
 * https://www.eclipse.org/legal/epl-2.0/
 *
 * SPDX-License-Identifier: EPL-2.0
 *
 * CONTRIBUTORS:
 * 		Thomas Schuetz (initial contribution)
 *
 *******************************************************************************/

#include "etUnit/etUnit.h"
#include <string.h>
#include <time.h>
#include <stdlib.h>
#include <assert.h>
#include "debugging/etLogger.h"
#include "osal/etSema.h"
#include "runtime/etRuntime.h"
#include "helpers/etTimeHelpers.h"

/*** member variables */

/* file handling */
static FILE* etUnit_reportfile = NULL;

/* counters */
static etInt16 etUnit_nextCaseId;
static etInt32 etUnit_errorCounter;

static etBool etUnit_parallelTestCases = ET_FALSE;
#define ETUNIT_MAX_PARALLEL_TEST_CASES 5
static etBool etUnit_testcaseSuccess[ETUNIT_MAX_PARALLEL_TEST_CASES];
static etBool etUnit_testcaseOpen[ETUNIT_MAX_PARALLEL_TEST_CASES];

#define ETUNIT_FAILURE_TEXT_LEN 256

/* time measuring */
static etTime etUnit_startTime;
static etTime etUnit_lastTestCaseTime;


/*
 * Returns index to store current test case state
 *  - 'caseId' for parallel test cases
 *  - 0 for singleton test case
 */
static etInt16 getParallelIndex(etInt16 caseId) {
	etInt16 idx = (etInt16)((etUnit_parallelTestCases) ? caseId - 1 : 0);
	assert(idx >= 0 && idx < ETUNIT_MAX_PARALLEL_TEST_CASES);
	return idx;
}

/* Lookup valid open test case id */
static etInt16 getOpenTestCaseId(etInt16 id) {
	etInt16 caseId;
	if (etUnit_parallelTestCases) {
		// index is id of parallel test case
		assert(id > 0);
		caseId = id;
	} else {
		// index is 0, return current open test case
		assert(id == 0);
		caseId = (etInt16)(etUnit_nextCaseId - 1);
	}
	if(!etUnit_testcaseOpen[getParallelIndex(caseId)]) {
		etLogger_logErrorF("Test case was not opened");
	}

	return caseId;
}

/* order */
#define ETUNIT_ORDER_MAX	16
typedef struct OrderInfo {
	etInt16 id;
	etInt16 currentIndex;
	etInt16 size;
	const etInt16* list;
} OrderInfo;
static OrderInfo etUnit_orderInfo[ETUNIT_ORDER_MAX];

static OrderInfo* getOrderInfo(etInt16 id) {
	etInt16 caseId = getOpenTestCaseId(id);
	for (int i = 0; i < ETUNIT_ORDER_MAX; ++i)
		if (etUnit_orderInfo[i].id == caseId)
			return etUnit_orderInfo + i;

	return NULL;
}

/* float measuring */
#if defined (ET_FLOAT32) || defined (ET_FLOAT64)
#define ETUNIT_FLOAT
#ifdef ET_FLOAT64
typedef etFloat64 etUnitFloat;
#else
typedef etFloat32 etUnitFloat;
#endif
#endif

/* forward declarations of private functions */
static void expect_equal_int(etInt16 id, const char* message, etInt32 expected, etInt32 actual, const char* file, int line);
/* currently not used
static void expect_range_int(etInt16 id, const char* message, etInt32 min, etInt32 max, etInt32 actual, const char* file, int line);
*/
static void expect_equal_uint(etInt16 id, const char* message, etUInt32 expected, etUInt32 actual, const char* file, int line);
/* currently not used
static void expect_range_uint(etInt16 id, const char* message, etUInt32 min, etUInt32 max, etUInt32 actual, const char* file, int line);
*/

#ifdef ETUNIT_FLOAT
static void expect_equal_float(etInt16 id, const char* message, etUnitFloat expected, etUnitFloat actual, etUnitFloat precision, const char* file, int line);
static void expect_range_float(etInt16 id, const char* message, etUnitFloat min, etUnitFloat max, etUnitFloat actual, const char* file, int line);
#endif

static void etUnit_handleExpect(etInt16 id, etBool result, const char *trace, const char* expected, const char* actual, const char* file, int line);

/* forward declarations of internally used non-API functions */
etBool etUnit_timeInMillis32(const etTime* time, etInt32 *millis);

/* configuration functions */

void etUnit_setParallelTestCases(etBool enabled) {
	etUnit_parallelTestCases = enabled;
}
/* public functions */

void etUnit_open(const char* testResultPath, const char* testFileName) {
	etLogger_logInfoF("************* TEST START (%s) **************", testFileName);

	{
		char filename[ETUNIT_FAILURE_TEXT_LEN];

		if (testResultPath != NULL)
			snprintf(filename, sizeof(filename), "%s/%s.etu", testResultPath, testFileName);
		else
			snprintf(filename, sizeof(filename),"%s.etu", testFileName);

		/* init global data */
		for (int i = 0; i < ETUNIT_ORDER_MAX; ++i) {
			etUnit_orderInfo[i].id = 0;
		}
		for (int i = 0; i < ETUNIT_MAX_PARALLEL_TEST_CASES; ++i) {
			etUnit_testcaseSuccess[i] = ET_TRUE;
			etUnit_testcaseOpen[i] = ET_FALSE;
		}
		etUnit_errorCounter = 0;
		etUnit_nextCaseId = 1;

		if (etUnit_reportfile == NULL) {
			etUnit_reportfile = etLogger_fopen(filename, "w+");
			if (etUnit_reportfile != NULL) {
				etLogger_fprintf(etUnit_reportfile, "etUnit report\n");
			} else {
				etLogger_logErrorF("Unable to open file %s", filename);
			}
		}
	}

	/* prepare time measurement */
	getTimeFromTarget(&etUnit_startTime);
}

void etUnit_close(void) {
	etTime endTime;
	if (etUnit_reportfile != NULL) {
		etLogger_fclose(etUnit_reportfile);
		etUnit_reportfile = NULL;
	}
	getTimeFromTarget(&endTime);
	etTimeHelpers_subtract(&endTime, &etUnit_startTime);
	etInt32 msecs = 0;
	etBool msecsValid = etUnit_timeInMillis32(&endTime, &msecs);
	etLogger_logInfoF("Elapsed Time: %ld ms", msecsValid ? msecs : -1);
	if (etUnit_errorCounter == 0)
		etLogger_logInfoF("Error Counter: %ld", etUnit_errorCounter);
	else
		etLogger_logErrorF("Error Counter: %ld", etUnit_errorCounter);
	etLogger_logInfoF("************* TEST END **************");
}

void etUnit_openTestSuite(const char* testSuiteName) {
	if (etUnit_reportfile != NULL) {
		etLogger_fprintf(etUnit_reportfile, "ts start: %s\n", testSuiteName);
	}
}

void etUnit_closeTestSuite(void) {
}

/* Opens new test case, if parallel is activated returns new test case id otherwise 0*/
etInt16 etUnit_openTestCase(const char* testCaseName) {
	if(etUnit_nextCaseId >= INT16_MAX) {
		etLogger_logErrorF("Too many test cases. Maximum number is %d", INT16_MAX);
		exit(-1);
	}
	etInt16 caseId = etUnit_nextCaseId++;
	etInt16 idx = getParallelIndex(caseId);
	if (etUnit_parallelTestCases && idx >= ETUNIT_MAX_PARALLEL_TEST_CASES) {
		etLogger_logErrorF("Too many parallel test cases. Maximum number is %d", ETUNIT_MAX_PARALLEL_TEST_CASES);
		exit(-1);
	}
	if (etUnit_reportfile != NULL) {
		etLogger_fprintf(etUnit_reportfile, "tc start %d: %s\n", caseId, testCaseName);
		getTimeFromTarget(&etUnit_lastTestCaseTime);
	}


	if(etUnit_testcaseOpen[idx]) {
		etLogger_logErrorF("Previous test case was not closed");
		EXPECT_FAIL(idx, "Test case was not closed");
	}
	etUnit_testcaseOpen[idx] = ET_TRUE;
	etUnit_testcaseSuccess[idx] = ET_TRUE;

	return (etUnit_parallelTestCases) ? caseId : 0;
}

void etUnit_closeTestCase(etInt16 id) {
	// clear order
	OrderInfo* info = getOrderInfo(id);
	if(info != NULL) {
		if (info->currentIndex != info->size) {
			EXPECT_FAIL(id, "EXPECT_ORDER was not completed");
		}
		info->id = 0;
	}
	etInt16 caseId = getOpenTestCaseId(id);
	etInt16 parallelId = getParallelIndex(caseId);
	etUnit_testcaseOpen[parallelId] = ET_FALSE;

	if (etUnit_reportfile != NULL) {
		etTime time;
		getTimeFromTarget(&time);
		etTimeHelpers_subtract(&time, &etUnit_lastTestCaseTime);
		etInt32 msecs = 0;
		etBool msecsValid = etUnit_timeInMillis32(&time, &msecs);
		etLogger_fprintf(etUnit_reportfile, "tc end %d: %d\n", caseId, msecsValid ? msecs : -1);
	}
}

void etUnit_skipTestCase(etInt16 id, const char* msg) {
	etInt16 caseId = getOpenTestCaseId(id);
	etInt16 parallelId = getParallelIndex(caseId);
	etUnit_testcaseOpen[parallelId] = ET_FALSE;

	if (etUnit_reportfile != NULL) {
		etLogger_fprintf(etUnit_reportfile, "tc skip %d: %s\n", caseId, msg);
	}
}

etInt16 etUnit_openAll(const char* testResultPath, const char* testFileName, const char* testSuiteName, const char* testCaseName) {
	etUnit_open(testResultPath, testFileName);
	etUnit_openTestSuite(testSuiteName);
	return etUnit_openTestCase(testCaseName);
}

void etUnit_closeAll(etInt16 id) {
	etUnit_closeTestCase(id);
	etUnit_closeTestSuite();
	etUnit_close();
}

void etUnit_testFinished(etInt16 id) {
	ET_TOUCH(id);
	etSema_wakeup(etRuntime_getTerminateSemaphore());
}

void expectTrue(etInt16 id, const char* message, etBool condition, const char* file, int line) {
	if (condition == ET_FALSE) {
		char testresult[ETUNIT_FAILURE_TEXT_LEN];
		snprintf(testresult, sizeof(testresult), "%s: *** EXPECT_TRUE == FALSE", message);
		etUnit_handleExpect(id, ET_FALSE, testresult, "TRUE", "FALSE", file, line);
	} else {
		etUnit_handleExpect(id, ET_TRUE, "", NULL, NULL, file, line);
	}
}

void expectFalse(etInt16 id, const char* message, etBool condition, const char* file, int line) {
	if (condition == ET_TRUE) {
		char testresult[ETUNIT_FAILURE_TEXT_LEN];
		snprintf(testresult, sizeof(testresult), "%s: EXPECT_FALSE == TRUE", message);
		etUnit_handleExpect(id, ET_FALSE, testresult, "FALSE", "TRUE", file, line);
	} else {
		etUnit_handleExpect(id, ET_TRUE, "", NULL, NULL, file, line);
	}
}

void expectFail(etInt16 id, const char* message, const char* file, int line) {
	char testresult[ETUNIT_FAILURE_TEXT_LEN];
	snprintf(testresult, sizeof(testresult), "%s: EXPECT_FAILED", message);
	etUnit_handleExpect(id, ET_FALSE, testresult, "NO_FAIL", "FAIL", file, line);
}

void expectEqualInt8(etInt16 id, const char* message, etInt8 expected, etInt8 actual, const char* file, int line) {
	expect_equal_int(id, message, (etInt32) expected, (etInt32) actual, file, line);
}

void expectEqualInt16(etInt16 id, const char* message, etInt16 expected, etInt16 actual, const char* file, int line) {
	expect_equal_int(id, message, (etInt32) expected, (etInt32) actual, file, line);
}

void expectEqualInt32(etInt16 id, const char* message, etInt32 expected, etInt32 actual, const char* file, int line) {
	expect_equal_int(id, message, (etInt32) expected, (etInt32) actual, file, line);
}

void expectEqualUInt8(etInt16 id, const char* message, etUInt8 expected, etUInt8 actual, const char* file, int line) {
	expect_equal_uint(id, message, (etUInt32) expected, (etUInt32) actual, file, line);
}

void expectEqualUInt16(etInt16 id, const char* message, etUInt16 expected, etUInt16 actual, const char* file, int line) {
	expect_equal_uint(id, message, (etUInt32) expected, (etUInt32) actual, file, line);
}

void expectEqualUInt32(etInt16 id, const char* message, etUInt32 expected, etUInt32 actual, const char* file, int line) {
	expect_equal_uint(id, message, (etUInt32) expected, (etUInt32) actual, file, line);
}

void expect_equal_void_ptr(etInt16 id, const char* message, const void* expected, const void* actual, const char* file, int line) {
	if (expected != actual) {
		char testresult[ETUNIT_FAILURE_TEXT_LEN];
		char exp[16], act[16];
		snprintf(testresult,  sizeof(testresult), "%s: expected=%p, actual=%p", message, expected, actual);
		sprintf(exp, "%p", expected);
		sprintf(act, "%p", actual);
		etUnit_handleExpect(id, ET_FALSE, testresult, exp, act, file, line);
	} else {
		etUnit_handleExpect(id, ET_TRUE, "", NULL, NULL, file, line);
	}
}

void expectEqualStr(etInt16 id, const char* message, const char* expected, const char* actual, const char* file, int line) {
	if (!(expected && actual && strcmp(expected, actual) == 0)) {
		char testresult[ETUNIT_FAILURE_TEXT_LEN];
		snprintf(testresult,  sizeof(testresult), "%s: expected=%s, actual=%s", message, expected, actual);
		etUnit_handleExpect(id, ET_FALSE, testresult, expected, actual, file, line);
	} else {
		etUnit_handleExpect(id, ET_TRUE, "", NULL, NULL, file, line);
	}
}

#ifdef ET_FLOAT32
void expectEqualFloat32(etInt16 id, const char* message, etFloat32 expected, etFloat32 actual, etFloat32 precision, const char* file, int line) {
	expect_equal_float(id, message, expected, actual, precision, file, line);
}

void expectRangeFloat32(etInt16 id, const char* message, etFloat32 min, etFloat32 max, etFloat32 actual, const char* file, int line) {
	expect_range_float(id, message, min, max, actual, file, line);
}
#endif

#ifdef ET_FLOAT64
void expectEqualFloat64(etInt16 id, const char* message, etFloat64 expected, etFloat64 actual, etFloat64 precision, const char* file, int line) {
	expect_equal_float(id, message, expected, actual, precision, file, line);
}

void expectRangeFloat64(etInt16 id, const char* message, etFloat64 min, etFloat64 max, etFloat64 actual, const char* file, int line) {
	expect_range_float(id, message, min, max, actual, file, line);
}
#endif

void expectOrderStart(etInt16 id, const etInt16* list, etInt16 size, const char* file, int line) {
	ET_TOUCH(file);
	ET_TOUCH(line);

	etInt16 caseId = getOpenTestCaseId(id);
	for (int i = 0; i < ETUNIT_ORDER_MAX; ++i) {
		if (etUnit_orderInfo[i].id == caseId) {
			EXPECT_FAIL(id, "previous expect order was not closed");
			etUnit_orderInfo[i].id = 0;
		}
	}
	for (int i = 0; i < ETUNIT_ORDER_MAX; ++i) {
		if (etUnit_orderInfo[i].id == 0) {
			etUnit_orderInfo[i].id = caseId;
			etUnit_orderInfo[i].currentIndex = 0;
			etUnit_orderInfo[i].size = size;
			etUnit_orderInfo[i].list = list;
			return;
		}
	}
	EXPECT_FAIL(id, "cannot start order, maximum opened orders reached");
}

void expectOrder(etInt16 id, const char* message, etInt16 identifier, const char* file, int line) {
	OrderInfo* info = getOrderInfo(id);
	if (info != NULL) {
		if (info->currentIndex < info->size) {
			if (info->list[info->currentIndex] != identifier) {
				char testresult[ETUNIT_FAILURE_TEXT_LEN];
				char exp[16], act[16];
				snprintf(testresult,  sizeof(testresult), "EXPECT_ORDER %s: index=%d, expected=%d, actual=%d", message, info->currentIndex, identifier,
						info->list[info->currentIndex]);
				sprintf(exp, "%d", identifier);
				sprintf(act, "%d", info->list[info->currentIndex]);
				etUnit_handleExpect(id, ET_FALSE, testresult, exp, act, file, line);
			} else {
				etUnit_handleExpect(id, ET_TRUE, "", NULL, NULL, file, line);
				info->currentIndex++;
			}
		} else {
			char testresult[ETUNIT_FAILURE_TEXT_LEN];
			snprintf(testresult, sizeof(testresult), "EXPECT_ORDER: index(%d) is too big in %s", info->currentIndex, message);
			etUnit_handleExpect(id, ET_FALSE, testresult, NULL, NULL, file, line);
			etLogger_logInfoF("EXPECT_ORDER: index too big in %s", message);
		}
	} else {
		EXPECT_FAIL(id, "no order info found");
	}
}

void expectOrderEnd(etInt16 id, const char* message, etInt16 identifier, const char* file, int line) {
	expectOrder(id, message, identifier, file, line);
	OrderInfo* info = getOrderInfo(id);
	if (info != NULL) {
		if(info->currentIndex != info->size) {
			char testresult[ETUNIT_FAILURE_TEXT_LEN];
			snprintf(testresult,  sizeof(testresult), "EXPECT_ORDER_END %s: wrong index at the end: expected=%d, actual=%d", message, info->size, info->currentIndex);
			etUnit_handleExpect(id, ET_FALSE, testresult, NULL, NULL, file, line);
		}
		info->id = 0;
	}
}

etBool etUnit_isSuccess(etInt16 id) {
	return etUnit_testcaseSuccess[getParallelIndex(id)];
}

/* private functions */

static void expect_equal_int(etInt16 id, const char* message, etInt32 expected, etInt32 actual, const char* file, int line) {
	if (expected != actual) {
		char testresult[ETUNIT_FAILURE_TEXT_LEN];
		char exp[16], act[16];
		snprintf(testresult, sizeof(testresult), "%s: expected=%d, actual=%d", message, expected, actual);
		sprintf(exp, "%d", expected);
		sprintf(act, "%d", actual);
		etUnit_handleExpect(id, ET_FALSE, testresult, exp, act, file, line);
	} else {
		etUnit_handleExpect(id, ET_TRUE, "", NULL, NULL, file, line);
	}
}

/* currently not used
static void expect_range_int(etInt16 id, const char* message, etInt32 min, etInt32 max, etInt32 actual, const char* file, int line) {
	if (actual < min || actual > max) {
		char testresult[ETUNIT_FAILURE_TEXT_LEN];
		char exp[64], act[16];
		sprintf(testresult, "%s: min=%ld, max=%ld, actual=%ld", message, min, max, actual);
		if (actual < min) {
			sprintf(exp, ">=%ld(min)", min);
			sprintf(act, "%ld", actual);
		} else {
			sprintf(exp, "<=%ld(max)", max);
			sprintf(act, "%ld", actual);
		}
		etUnit_handleExpect(id, ET_FALSE, testresult, exp, act, file, line);
	} else {
		etUnit_handleExpect(id, ET_TRUE, "", NULL, NULL, file, line);
	}
}
*/

static void expect_equal_uint(etInt16 id, const char* message, etUInt32 expected, etUInt32 actual, const char* file, int line) {
	if (expected != actual) {
		char testresult[ETUNIT_FAILURE_TEXT_LEN];
		char exp[16], act[16];
		snprintf(testresult, sizeof(testresult), "%s: expected=%u, actual=%u", message, expected, actual);
		sprintf(exp, "%u", expected);
		sprintf(act, "%u", actual);
		etUnit_handleExpect(id, ET_FALSE, testresult, exp, act, file, line);
	} else {
		etUnit_handleExpect(id, ET_TRUE, "", NULL, NULL, file, line);
	}
}

/* currently not used
static void expect_range_uint(etInt16 id, const char* message, etUInt32 min, etUInt32 max, etUInt32 actual, const char* file, int line) {
	if (actual < min || actual > max) {
		char testresult[ETUNIT_FAILURE_TEXT_LEN];
		char exp[64], act[16];
		sprintf(testresult, "%s: min=%lu, max=%lu, actual=%lu", message, min, max, actual);
		if (actual < min) {
			sprintf(exp, ">=%lu(min)", min);
			sprintf(act, "%lu", actual);
		} else {
			sprintf(exp, "<=%lu(max)", max);
			sprintf(act, "%lu", actual);
		}
		etUnit_handleExpect(id, ET_FALSE, testresult, exp, act, file, line);
	} else {
		etUnit_handleExpect(id, ET_TRUE, "", NULL, NULL, file, line);
	}
}
*/

#ifdef ETUNIT_FLOAT
static void expect_equal_float(etInt16 id, const char* message, etUnitFloat expected, etUnitFloat actual, etUnitFloat precision, const char* file, int line) {
	if (expected - actual < -precision || expected - actual > precision) {
		char testresult[ETUNIT_FAILURE_TEXT_LEN];
		char exp[16], act[16];
		snprintf(testresult, sizeof(testresult), "%s: expected=%f, actual=%f", message, expected, actual);
		sprintf(exp, "%f", expected);
		sprintf(act, "%f", actual);
		etUnit_handleExpect(id, ET_FALSE, testresult, exp, act, file, line);
	} else {
		etUnit_handleExpect(id, ET_TRUE, "", NULL, NULL, file, line);
	}
}

static void expect_range_float(etInt16 id, const char* message, etUnitFloat min, etUnitFloat max, etUnitFloat actual, const char* file, int line) {
	if (actual < min || actual > max) {
		char testresult[ETUNIT_FAILURE_TEXT_LEN];
		char exp[64], act[16];
		snprintf(testresult, sizeof(testresult), "%s: min=%f, max=%f, actual=%f", message, min, max, actual);
		if (actual < min) {
			sprintf(exp, ">=%f(min)", min);
			sprintf(act, "%f", actual);
		} else {
			sprintf(exp, "<=%f(max)", max);
			sprintf(act, "%f", actual);
		}
		etUnit_handleExpect(id, ET_FALSE, testresult, exp, act, file, line);
	} else {
		etUnit_handleExpect(id, ET_TRUE, "", NULL, NULL, file, line);
	}
}
#endif

static void etUnit_handleExpect(etInt16 id, etBool result, const char *resulttext, const char* exp, const char* act, const char* file, int line) {
	// check open
	etInt16 caseId = getOpenTestCaseId(id);
	if (result == ET_TRUE) {
		/* nothing to do because no failure */
	} else {
		etUnit_errorCounter++;
		etInt16 parallelId = getParallelIndex(caseId);
		if (etUnit_testcaseSuccess[parallelId] == ET_TRUE) {
			/* first failure will be remembered */
			etUnit_testcaseSuccess[parallelId] = ET_FALSE;
			
			if (act != NULL && exp != NULL)
				etLogger_fprintf(etUnit_reportfile, "tc fail %d: #%s#%s#%s:%d#%s\n", caseId, exp, act, file, line, resulttext);
			else
				etLogger_fprintf(etUnit_reportfile, "tc fail %d: ###%s:%d#%s\n", caseId, file, line, resulttext);
		} else {
			/* more than one error will be ignored */
		}
	}
}

///
/// Utility functions for etUnit
///

/**
 * Converts etTime to milliseconds as a 32-bit integer value. A range check is performed to determine if the conversion will be successful.
 * If the conversion is out of range, then the millis out-param will not be modified.
 *
 * /param [in] time etTime to convert
 * /param [out] millis number of milliseconds represented by etTime
 * /return ET_TRUE if the conversion was successful, ET_FALSE if the conversion was out of range
 *         or invalid arguments were encountered
 */
etBool etUnit_timeInMillis32(const etTime * time, etInt32 * millis) {
	// check arguments
	if (NULL == millis|| NULL == time) {
		return ET_FALSE;
	}

	etTime t = *time;
	etTimeHelpers_normalize(&t); // after normalization, nSec is within range [0, 1e9)
	etInt32 ms_from_nsec = (t.nSec + 500000) / 1000000;

	// check that conversion is within range
	if (
			(t.sec > INT32_MAX/1000) ||
			((t.sec == INT32_MAX/1000) && (ms_from_nsec > 647))
	) {
		return ET_FALSE;
	}
	if (
			(t.sec < (INT32_MIN/1000)-1) ||
			((t.sec == (INT32_MIN/1000)-1) && (ms_from_nsec < 352))
	) {
		return ET_FALSE;
	}

	*millis = (t.sec * 1000) + ms_from_nsec;
	return ET_TRUE;
}
