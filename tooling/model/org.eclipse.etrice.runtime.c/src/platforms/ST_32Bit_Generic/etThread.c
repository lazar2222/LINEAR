/*******************************************************************************
 * Copyright (c) 2013 protos software gmbh (http://www.protos.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * which accompanies this distribution, and is available at
 * https://www.eclipse.org/legal/epl-2.0/
 *
 * SPDX-License-Identifier: EPL-2.0
 *
 * CONTRIBUTORS:
 * 		Thomas Schuetz, Thomas Jung (initial contribution)
 *
 *******************************************************************************/

#include "osal/etThread.h"

#include "debugging/etLogger.h"
#include "debugging/etMSCLogger.h"

static etThread * singleThread = NULL;

void etThread_construct(
		etThread* self,
		etStacksize stacksize,
		etPriority priority,
		etThreadname threadName,
		etThreadFunction threadFunction,
		void* threadFunctionData)
{
	ET_MSC_LOGGER_SYNC_ENTRY("etThread", "construct")

	/* fill in data */
	self->stacksize = stacksize;
	self->priority = priority;
	self->threadName = threadName;
	self->threadFunction = threadFunction;
	self->threadFunctionData = threadFunctionData;
	/* for the single threaded stacksize and prio is not needed */

	/* save the thread pointer as singleton */
	if (singleThread == NULL) {
		singleThread = self;
	} else {
		// error - single threaded, there can only be one thread
		while (1) {};
	}

	ET_MSC_LOGGER_SYNC_EXIT
}

void etThread_start(etThread* self) {
	ET_MSC_LOGGER_SYNC_ENTRY("etThread", "start")

	ET_MSC_LOGGER_SYNC_EXIT
}

void etThread_execute(etThread* self){
	ET_MSC_LOGGER_SYNC_ENTRY("etThread", "execute")
	/* etThread_execute redirects the call from the thread to the execute function in the eTrice runtime to enable correct synchronous MSC logging */
	self->threadFunction(self->threadFunctionData);
	ET_MSC_LOGGER_SYNC_EXIT
}

void etThread_executeSingleThread() {
	etThread_execute(singleThread);
}

void etThread_destruct(etThread* self){
	ET_MSC_LOGGER_SYNC_ENTRY("etThread", "destruct")

	ET_MSC_LOGGER_SYNC_EXIT
}

void etThread_sleep(etUInt32 millis){
	ET_MSC_LOGGER_SYNC_ENTRY("etThread", "sleep")

	ET_MSC_LOGGER_SYNC_EXIT
}

etOSThreadId etThread_self_id(void){
	return 0;
}
