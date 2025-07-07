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

/**
 * \file etPort.h
 *
 * the base "class" of a port
 *
 * \author Thomas Schuetz, Henrik Rentz-Reichert
 */

#ifndef _ETPORT_H_
#define _ETPORT_H_

#include "messaging/etMessage.h"
#include "messaging/etMessageReceiver.h"
#include "messaging/etMessageService.h"
#include "etRuntimeConfig.h"

ET_EXTERN_C_BEGIN

/**
 * the data structure of a port that holds the constant data
 */
typedef struct {
	void* varData;					/**< a pointer to the variable part of the data */
	etMessageService* msgService;	/**< the associated message service */
	etAddressId peerAddress;		/**< the peer port's address */
	etAddressId localId;			/**< the local ID of the port instance in its parent actor */

	#ifdef ET_ASYNC_MSC_LOGGER_ACTIVATE
		const char* myInstName;		/**< the instance name (i.e. path) of our actor */
		const char* peerInstName;	/**< the instance name (i.e. path) of our peer actor */
	#endif
	#ifdef etDEBUG
		etAddressId address;		/**< the port's adress */
		/* thread ID from msg service: msgService->threadId */
	#endif
} etPort;

/**
 * data needed for a sub port of a replicated port
 */
typedef struct {
	etPort port;					/**< the sub port data */
	etAddressId index;				/**< the offset in the array of sub ports */
} etReplSubPort;

/**
 * data of a replicated port
 */
typedef struct {
	etInt16 size;					/**< the number of sub ports */
	const etReplSubPort* ports;		/**< pointers to the sub ports */
} etReplPort;

typedef etPort InterfaceItemBase;

/*void etPort_receive(const etPort* self, const etMessage* msg);*/

/**
 * sends a message
 *
 * \param self the this pointer
 * \param evtId the event id
 * \param size the size of the data
 * \param a pointer to the data (may be <code>NULL</code>)
 */
void etPort_sendMessage(const etPort* self, etInt16 evtId, unsigned int size, const void* data);

/**
 * sends the passed message buffer. You may only send buffers returned by etMessageService_getMessageBuffer for self->msgService!
 *
 * \param self the this pointer
 * \param evtId the event id
 * \param a pointer to the message buffer. Must be a buffer returned by etMessageService_getMessageBuffer for self->msgService!
 */
void etPort_sendMessageBuffer(etPort const * const self, etInt16 evtId, etMessage* msg);

/**
 * \param msg the message buffer for which the data pointer shall be returned
 * \return a pointer pointing to the data part of the message passed into the function
 */
void* etPort_getMessageDataPtr(const etMessage* msg);

/**
 * \param size number of bytes to be transported in the message
 * \return the size in bytes needed for a message buffer which can transport the passed number of bytes
 */
size_t etPort_getTotalMessageSize(size_t size);

/**
 * \param self the this pointer
 * \param evtId the event id
 * \param str pointer to the c-string to be send
 * \return true if the string was put into the message queue. false otherwise.
 */
bool etPort_sendStringMessage(etPort const * const self, etInt16 const evtId, char const * const str);

ET_EXTERN_C_END

#endif /* _ETPORT_H_ */
