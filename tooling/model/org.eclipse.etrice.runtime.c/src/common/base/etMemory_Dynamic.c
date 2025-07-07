/*******************************************************************************
 * Copyright (c) 2012 protos software gmbh (http://www.protos.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * which accompanies this distribution, and is available at
 * https://www.eclipse.org/legal/epl-2.0/
 *
 * SPDX-License-Identifier: EPL-2.0
 *
 * CONTRIBUTORS:
 * 		Juergen Haug (initial contribution)
 *
 *******************************************************************************/

#include "etMemory_Dynamic.h"

#include <stdint.h>
#include <stdlib.h>

static void* etMemory_Dynamic_alloc(etMemory *self, size_t size) {
	ET_TOUCH(self);
	return calloc(1, size);
}

static void etMemory_Dynamic_free(etMemory *self, void *obj) {
	ET_TOUCH(self);
	free(obj);
}

etMemory* etMemory_Dynamic_init(void) {
	etMemory* self = (etMemory*) calloc(1, sizeof(etMemory));
	if(self) {
		etMemory_init(self, SIZE_MAX, etMemory_Dynamic_alloc, etMemory_Dynamic_free);
	}

	return self;
}
