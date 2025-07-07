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



#include "osal/etPlatformLifecycle.h"

#include "osal/etThread.h"
#include "etPlatform.h"


/* must be implemented projectspecific */
extern void etSingleThreadedProjectSpecificUserEntry();

void etUserEntry(void){
	etSingleThreadedProjectSpecificUserEntry();
}

void etUserPreRun(void){ }

/* execute function for single threaded */
extern void etThread_executeSingleThread(void);

int etUserMainRun(int argc, char** argv) {
	/*	__enable_irq(); */
	etThread_executeSingleThread();
	return 0;
}

void etUserPostRun(void){ }
void etUserExit(void){ }
