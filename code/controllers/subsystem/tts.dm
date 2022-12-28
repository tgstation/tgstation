/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/proc/tts_filter(text)
	// Only allow alphanumeric characters and whitespace
	var/static/regex/bad_chars_regex = regex("\[^a-zA-Z0-9 ,?.!']", "g")
	return bad_chars_regex.Replace(text, " ")


#define TARGET_INDEX 1
#define IDENTIFIER_INDEX 2
#define TIMEOUT_INDEX 3
#define REQUEST_INDEX 4

SUBSYSTEM_DEF(tts)
	name = "Text To Speech"
	wait = 0.1 SECONDS
	init_order = INIT_ORDER_TTS

	var/list/queued_tts_messages = list()

	var/list/processing_tts_messages = list()

	var/list/available_speakers = list()

	var/tts_enabled = FALSE

	var/message_timeout = 5 SECONDS

/datum/controller/subsystem/tts/vv_edit_var(var_name, var_value)
	// tts being enabled depends on whether it actually exists
	if(NAMEOF(src, tts_enabled) == var_name)
		return FALSE
	return ..()

/datum/controller/subsystem/tts/Initialize()
	if(!CONFIG_GET(string/tts_http_url))
		return SS_INIT_NO_NEED

	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/tts_http_url)]/tts-voices", "", "")
	request.begin_async()
	UNTIL(request.is_complete())
	var/datum/http_response/response = request.into_response()
	if(response.errored || response.status_code != 200)
		return SS_INIT_NO_NEED
	available_speakers = json_decode(response.body)
	tts_enabled = TRUE

	return SS_INIT_SUCCESS

/datum/controller/subsystem/tts/fire(resumed)
	if(!tts_enabled)
		flags |= SS_NO_FIRE
		return

	if(!resumed)
		processing_tts_messages = queued_tts_messages.Copy()

	// For speed
	var/list/processing_messages = processing_tts_messages
	while(processing_messages.len)
		var/current_message = processing_messages[processing_messages.len]
		processing_messages.len--
		var/atom/movable/target = current_message[TARGET_INDEX]
		if(QDELETED(target))
			queued_tts_messages -= list(current_message)
			continue

		var/datum/http_request/request = current_message[REQUEST_INDEX]
		if(!request.is_complete())
			if(current_message[TIMEOUT_INDEX] < world.time)
				queued_tts_messages -= list(current_message)
			continue

		var/datum/http_response/response = request.into_response()
		queued_tts_messages -= list(current_message)
		if(response.errored)
			continue
		var/sound/new_sound = new("tmp/[current_message[IDENTIFIER_INDEX]].ogg")
		playsound(current_message[TARGET_INDEX], new_sound, 100)
		fdel(file("tmp/[current_message[IDENTIFIER_INDEX]].ogg"))
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/tts/proc/queue_tts_message(target, message, speaker, filter)
	if(!tts_enabled)
		return

	var/shell_scrubbed_input = tts_filter(message)
	shell_scrubbed_input = copytext(shell_scrubbed_input, 1, 100)
	var/identifier = md5(speaker + shell_scrubbed_input + filter)
	speaker = tts_filter(speaker)
	if(!(speaker in available_speakers))
		CRASH("Tried to use invalid speaker for TTS message! ([speaker])")

	var/list/headers = list()
	headers["Content-Type"] = "application/json"
	var/datum/http_request/request = new()
	var/file_name = "tmp/[identifier].ogg"
	request.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/tts_http_url)]/tts?voice=[speaker]&identifier=[identifier]&filter=[url_encode(filter)]", json_encode(list("text" = shell_scrubbed_input)), headers, file_name)
	request.begin_async()

	queued_tts_messages += list(list(target, identifier, world.time + message_timeout, request))

#undef TARGET_INDEX
#undef IDENTIFIER_INDEX
#undef TIMEOUT_INDEX
#undef REQUEST_INDEX
