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
 * 		Thomas Schuetz (initial contribution)
 *
 *******************************************************************************/

#include "modelbase/etPort.h"

#include "debugging/etMSCLogger.h"
#include "base/etMemory.h"
#include <string.h>

#ifdef ET_LOGGER_ACTIVATE
#include "debugging/etLogger.h"
#endif

/*
void etPort_receive(const etPort* self, const etMessage* msg) {
	ET_MSC_LOGGER_SYNC_ENTRY("etPort", "receive")
	if (self->receiveMessageFunc!=NULL)
		(self->receiveMessageFunc)(self->myActor, (void*)self, msg);
	ET_MSC_LOGGER_SYNC_EXIT
}
*/

void etPort_sendMessage(const etPort* self, etInt16 evtId, unsigned int size, const void* data) {
	unsigned int offset = MEM_CEIL(sizeof(etMessage));
	unsigned int totalSize = offset+size;
	etMessage* msg = NULL;
	ET_MSC_LOGGER_SYNC_ENTRY("etPort", "sendMessage")
	if(self->msgService == NULL) return;
	msg = etMessageService_getMessageBuffer(self->msgService, (size_t)totalSize);
	if (msg!=NULL) {
		msg->address = self->peerAddress;
		msg->evtID = evtId;

		if (size>0 && data!=NULL) {
			memcpy(((char*)msg)+offset, data, size);
		}

		etMessageService_pushMessage(self->msgService, msg);
	}
	ET_MSC_LOGGER_SYNC_EXIT
}

size_t etPort_getTotalMessageSize(size_t size) {
	size_t offset = MEM_CEIL(sizeof(etMessage));
	return offset + size;
}

void* etPort_getMessageDataPtr(const etMessage * msg) {
	size_t offset = MEM_CEIL(sizeof(etMessage));
	return (void*)(((char*)msg)+offset);
}

void etPort_sendMessageBuffer(etPort const * const self, etInt16 evtId, etMessage* msg) {
	ET_MSC_LOGGER_SYNC_ENTRY("etPort", "sendMessage")
	if(self->msgService == NULL) return;
	if (msg!=NULL) {
		msg->address = self->peerAddress;
		msg->evtID = evtId;
		etMessageService_pushMessage(self->msgService, msg);
	}
	ET_MSC_LOGGER_SYNC_EXIT
}

bool etPort_sendStringMessage(etPort const * const self, etInt16 const evtId, char const * const str) {
	// charPtr handled as c-string as @StringMessage annotation is present on the message
	if(self->msgService == NULL) return false; // return if we have no message service (e.g. if we have no peer)
	size_t stringLen = strlen(str);
	size_t len = stringLen + 1 + sizeof(char*); // strlen does not count the \0 character + we need extra space for the new char ptr
	size_t totalSize = etPort_getTotalMessageSize(len);
	etMessage *msg = etMessageService_getMessageBuffer(self->msgService, (size_t)totalSize);
	if(msg != NULL) {
		char* dataPtr = (char*)etPort_getMessageDataPtr(msg);
		memcpy(dataPtr + sizeof(char*), str, stringLen + 1);
		// We package the char ptr as first data element into the message data.
		// That way the receiving function can unpack it as it usually would and get back a valid charPtr pointing to the string contained in the message.
		*((char**)dataPtr) = dataPtr + sizeof(char*);
		etPort_sendMessageBuffer(self, evtId, msg);
		return true;
	} else {
		#ifdef ET_LOGGER_ACTIVATE
		etLogger_logError("String message does not fit in message queue block size. Message dropped.");
		#endif
	}
	return false;
}

