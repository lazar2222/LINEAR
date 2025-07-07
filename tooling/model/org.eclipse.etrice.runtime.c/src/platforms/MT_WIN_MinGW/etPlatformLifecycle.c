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

#include "runtime/etRuntime.h"
#include <string.h>

void etUserEntry(void){ /* not needed for this OS */ }
void etUserPreRun(void){ /* not needed for this OS */ }

int etUserMainRun(int argc, char** argv) {
	etBool runAsTest = false;
	if (argc>1 && strcmp(argv[1], "-headless")==0) {
		runAsTest = ET_TRUE;
	} if (argc>1 && strcmp(argv[1], "-run_as_test")==0) {
		runAsTest = ET_TRUE;	
	}

	if (runAsTest) {
		// wait until tests are finished
		etSema_waitForWakeup(etRuntime_getTerminateSemaphore());
	}
	else {
		// wait for user
		printf("type quit to exit\n");
		fflush(stdout);
		while (ET_TRUE) {
			char line[64];

			if (fgets(line, 64, stdin) != NULL) {
				if (strncmp(line, "quit", 4)==0)
					break;
			}
		}
	}
	return 0;
}

void etUserPostRun(void){ /* not needed for this OS */ }
void etUserExit(void){ /* not needed for this OS */ }

