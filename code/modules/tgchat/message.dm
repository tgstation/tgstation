/**
 * Message-related procs
 *
 * Message format (/list):
 * - type - Message type, must be one of defines in `code/__DEFINES/chat.dm`
 * - text - Plain message text
 * - html - HTML message text
 * - Optional metadata, can be any key/value pair.
 *
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/proc/message_to_html(message)
	// Here it is possible to add a switch statement
	// to custom-handle various message types.
	return message["html"] || message["text"]
