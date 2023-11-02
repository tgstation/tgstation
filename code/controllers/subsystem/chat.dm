/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

SUBSYSTEM_DEF(chat)
	name = "Chat"
	flags = SS_TICKER|SS_NO_INIT
	wait = 1
	priority = FIRE_PRIORITY_CHAT
	init_order = INIT_ORDER_CHAT

	/// Assosciates a ckey with a list of messages to send to them.
	var/list/list/datum/chat_payload/client_to_payloads = list()

	/// Assosciates a ckey with their next sequence number.
	var/list/client_to_sequence_number = list()

/datum/controller/subsystem/chat/proc/generate_payload(client/target, message_data)
	var/sequence_number = client_to_sequence_number[target.ckey]
	client_to_sequence_number[target.ckey] += 1

	var/datum/chat_payload/payload = new
	payload.sequence_number = sequence_number
	payload.content = message_data
	return payload

/datum/controller/subsystem/chat/proc/send_payload_to_client(client/target, datum/chat_payload/payload)
	target.tgui_panel.window.send_message("chat/message", payload.into_message())
	payload.send_tries += 1
	payload.last_send = world.time

/datum/controller/subsystem/chat/fire()
	for(var/ckey in client_to_payloads)
		var/client/target = GLOB.directory[ckey]
		if(isnull(target)) // verify client still exists
			LAZYREMOVE(client_to_payloads, ckey)
			continue

		for(var/datum/chat_payload/payload as anything in client_to_payloads[ckey])
			if(payload.send_tries > CHAT_RESEND_TRIES)
				LAZYREMOVEASSOC(client_to_payloads, ckey, payload)
				continue // don't send this payload anymore; we tried
			if((payload.last_send + CHAT_RESEND_TICKS) >= world.time)
				continue // don't send this payload yet; we sent it recently
			send_payload_to_client(target, payload)

		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/chat/proc/handle_acknowledge(client/client, sequence_acknowledged)
	for(var/datum/chat_payload/payload as anything in LAZYACCESS(client_to_payloads, client.ckey))
		if(payload.sequence_number != sequence_acknowledged)
			continue
		LAZYREMOVEASSOC(client_to_payloads, client.ckey, payload)
		return

/datum/controller/subsystem/chat/proc/queue(queue_target, list/message_data)
	var/list/targets = islist(queue_target) ? queue_target : list(queue_target)
	for(var/target in targets)
		var/client/client = CLIENT_FROM_VAR(target)
		if(isnull(client))
			continue
		LAZYADDASSOCLIST(client_to_payloads, client.ckey, generate_payload(client, message_data))

/datum/controller/subsystem/chat/proc/send_immediate(send_target, list/message_data)
	var/list/targets = islist(send_target) ? send_target : list(send_target)
	for(var/target in targets)
		var/client/client = CLIENT_FROM_VAR(target)
		if(isnull(client))
			continue
		var/payload = generate_payload(client, message_data)
		LAZYADDASSOCLIST(client_to_payloads, client.ckey, payload)
		send_payload_to_client(client, payload)
