/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * Circumvents the message queue and sends the message
 * to the recipient (target) as soon as possible.
 */
/proc/to_chat_immediate(target, message)
	if(!target || !message)
		return
	if(target == world)
		target = GLOB.clients
	// Normalize the message
	if(istext(message))
		// Always treat an old-style invocation as HTML
		message = list("html" = message)
	if(!islist(message))
		CRASH("to_chat() message must be a message-like list or a string!")
	var/message_blob = TGUI_CREATE_MESSAGE("chat/message", message)
	var/message_html = message_to_html(message)
	if(islist(target))
		for(var/_target in target)
			var/client/client = CLIENT_FROM_VAR(_target)
			if(client)
				// Send to tgchat
				client.tgui_panel?.window.send_raw_message(message_blob)
				// Send to old chat
				SEND_TEXT(client, message_html)
		return
	var/client/client = CLIENT_FROM_VAR(target)
	if(client)
		// Send to tgchat
		client.tgui_panel?.window.send_raw_message(message_blob)
		// Send to old chat
		SEND_TEXT(client, message_html)

/**
 * Sends the message to the recipient (target).
 */
/proc/to_chat(target, message,
		// FIXME: These flags are now pointless and must be refactored
		// into message annotations.
		handle_whitespace = TRUE,
		trailing_newline = TRUE,
		confidential = FALSE)
	if(Master.current_runlevel == RUNLEVEL_INIT || !SSchat?.initialized)
		to_chat_immediate(target, message)
		return
	if(!target || !message)
		return
	if(target == world)
		target = GLOB.clients
	// Normalize the message
	if(istext(message))
		// Always treat an old-style invocation as HTML
		message = list("html" = message)
	if(!islist(message))
		CRASH("to_chat() message must be a message-like list or a string!")
	SSchat.queue(target, message)
