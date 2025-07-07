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
 * etTime.c MinGW implementation of etTime
 *
 */

#include "osal/etTime.h"

#include <time.h>


void getTimeFromTarget(etTime *t){
	// https://pubs.opengroup.org/onlinepubs/9699919799/functions/clock_getres.html
	// unspecified start point but monotonic
	struct timespec currentTime;
	clock_gettime(CLOCK_MONOTONIC, &currentTime);
	t->sec = (etInt32) currentTime.tv_sec;
	t->nSec = (etInt32) currentTime.tv_nsec;
}
