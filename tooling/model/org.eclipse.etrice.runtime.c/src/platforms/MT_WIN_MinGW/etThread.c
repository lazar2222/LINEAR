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

/**
 *
 * etThread.c MinGW implementation of etThread
 *
 */

#include "osal/etThread.h"

#include "debugging/etLogger.h"
#include "debugging/etMSCLogger.h"

#include <process.h>

void etThread_execute(etThread* self);

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
	self->started = ET_FALSE;

	ET_MSC_LOGGER_SYNC_EXIT
}

void etThread_start(etThread* self) {
	ET_MSC_LOGGER_SYNC_ENTRY("etThread", "start")
	self->osData = (HANDLE)_beginthread( (etThreadFunction)etThread_execute, (unsigned int)self->stacksize, self );
	// TODO: consider changing thread creation to use CreateThread and a stop signal/event
	//  or use pthread approach from POSIX_GENERIC platform
	SetThreadPriority(self->osData, self->priority);
	ET_MSC_LOGGER_SYNC_EXIT
}

void etThread_execute(etThread* self){
	ET_MSC_LOGGER_SYNC_ENTRY("etThread", "execute")
	self->started = ET_TRUE;
	/* etThread_execute redirects the call from the thread to the execute function in the eTrice runtime to enable correct synchronous MSC logging */
	self->threadFunction(self->threadFunctionData);
	ET_MSC_LOGGER_SYNC_EXIT
}

void etThread_destruct(etThread* self){
	ET_MSC_LOGGER_SYNC_ENTRY("etThread", "destruct")
	ET_TOUCH(self);
	//TerminateThread(self->osData, 0); this causes hangs on exit, as it corrupts memory!
	// TODO: this is not a good state, the thread itself should return / exit;
	//  ideally a signaling mechanism would be implemented which can be used to trigger the thread to shut down cleanly and return
	ET_MSC_LOGGER_SYNC_EXIT
}

void etThread_sleep(etUInt32 millis){
	ET_MSC_LOGGER_SYNC_ENTRY("etThread", "sleep")
	Sleep(millis);
	ET_MSC_LOGGER_SYNC_EXIT
}

etOSThreadData etThread_self(void){
	return GetCurrentThread();
}

etOSThreadId etThread_self_id(void){
	return GetCurrentThreadId();
}

