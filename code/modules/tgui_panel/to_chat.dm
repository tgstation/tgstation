/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * global
 *
 * Circumvents the message queue and sends the message
 * to the recipient (target) as soon as possible.
 */
/proc/to_chat_immediate(
		target,
		text,
		handle_whitespace = TRUE,
		trailing_newline = TRUE,
		confidential = FALSE)
	if(!target || !text)
		return
	if(target == world)
		target = GLOB.clients
	var/flags = handle_whitespace \
		| trailing_newline << 1 \
		| confidential << 2
	var/message = TGUI_CREATE_MESSAGE("chat/message", list(
		"text" = text,
		"flags" = flags,
	))
	if(islist(target))
		for(var/_target in target)
			var/client/client = CLIENT_FROM_VAR(_target)
			if(client)
				// Send to tgchat
				client.tgui_panel?.window.send_raw_message(message)
				// Send to old chat
				SEND_TEXT(client, text)
		return
	var/client/client = CLIENT_FROM_VAR(target)
	if(client)
		// Send to tgchat
		client.tgui_panel?.window.send_raw_message(message)
		// Send to old chat
		SEND_TEXT(client, text)

/**
 * global
 *
 * Sends the message to the recipient (target).
 */
/proc/to_chat(
		target,
		text,
		handle_whitespace = TRUE,
		trailing_newline = TRUE,
		confidential = FALSE)
	if(Master.current_runlevel == RUNLEVEL_INIT || !SSchat?.initialized)
		to_chat_immediate(
			target,
			text,
			handle_whitespace,
			trailing_newline,
			confidential)
		return
	if(!target || !text)
		return
	if(target == world)
		target = GLOB.clients
	var/flags = handle_whitespace \
		| trailing_newline << 1 \
		| confidential << 2
	SSchat.queue(target, text, flags)
