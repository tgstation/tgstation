/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/proc/tts_filter(text)
	// Only allow alphanumeric characters and whitespace
	var/static/regex/bad_chars_regex = regex("\[^a-zA-Z0-9 ,?.!'&-]", "g")
	return bad_chars_regex.Replace(text, " ")


#define TARGET_INDEX 1
#define IDENTIFIER_INDEX 2
#define TIMEOUT_INDEX 3
#define REQUEST_INDEX 4
#define EXTRA_TARGETS_INDEX 5

#define CACHE_PENDING "pending"

SUBSYSTEM_DEF(tts)
	name = "Text To Speech"
	wait = 0.1 SECONDS
	init_order = INIT_ORDER_TTS

	/// Queued HTTP requests that have yet to be sent
	var/list/queued_tts_messages = list()

	/// Queued HTTP requests that have yet to be sent. Takes priority over queued_tts_messages
	var/list/priority_queued_tts_messages = list()

	/// HTTP requests currently in progress but not being processed yet
	var/list/in_process_tts_messages = list()

	/// HTTP requests that are being processed to see if they've been finished
	var/list/current_processing_tts_messages = list()

	/// A list of available speakers
	var/list/available_speakers = list()

	var/list/cached_voices = list()

	/// Whether TTS is enabled or not
	var/tts_enabled = FALSE

	var/message_timeout = 5 SECONDS

	var/max_concurrent_requests = 15

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
	available_speakers -= "ED\n" // TODO: properly fix this
	tts_enabled = TRUE

	return SS_INIT_SUCCESS

/datum/controller/subsystem/tts/proc/play_tts(target, sound)

	var/turf/turf_source = get_turf(target)

	if (!turf_source)
		return

	//allocate a channel if necessary now so its the same for everyone
	var/channel = SSsounds.random_available_channel()
	var/listeners = get_hearers_in_view(SOUND_RANGE, turf_source)

	for(var/mob/listening_mob in listeners | SSmobs.dead_players_by_zlevel[turf_source.z])//observers always hear through walls
		if(get_dist(listening_mob, turf_source) <= SOUND_RANGE && listening_mob.client?.prefs.read_preference(/datum/preference/toggle/sound_tts))
			listening_mob.playsound_local(
				turf_source,
				sound,
				vol = listening_mob == target? 60 : 85,
				falloff_exponent = SOUND_FALLOFF_EXPONENT,
				channel = channel,
				pressure_affected = TRUE,
				sound_to_use = sound,
				max_distance = SOUND_RANGE,
				falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE,
				distance_multiplier = 1,
				use_reverb = TRUE
			)

/datum/controller/subsystem/tts/fire(resumed)
	if(!tts_enabled)
		flags |= SS_NO_FIRE
		return

	if(!resumed)
		var/list/priority_list = priority_queued_tts_messages
		while(length(in_process_tts_messages) < max_concurrent_requests && priority_list.len > 0)
			var/list/entry = popleft(priority_list)
			if(entry[TIMEOUT_INDEX] < world.time)
				continue
			var/datum/http_request/request = entry[REQUEST_INDEX]
			request.begin_async()
			in_process_tts_messages += list(entry)
		var/list/less_priority_list = queued_tts_messages
		while(length(in_process_tts_messages) < max_concurrent_requests && less_priority_list.len > 0)
			var/list/entry = popleft(less_priority_list)
			if(entry[TIMEOUT_INDEX] < world.time)
				continue
			var/datum/http_request/request = entry[REQUEST_INDEX]
			request.begin_async()
			in_process_tts_messages += list(entry)
		current_processing_tts_messages = in_process_tts_messages.Copy()

	// For speed
	var/list/processing_messages = current_processing_tts_messages
	while(processing_messages.len)
		var/current_message = processing_messages[processing_messages.len]
		processing_messages.len--
		var/atom/movable/target = current_message[TARGET_INDEX]
		if(QDELETED(target) || current_message[TIMEOUT_INDEX] < world.time)
			in_process_tts_messages -= list(current_message)
			continue

		var/datum/http_request/request = current_message[REQUEST_INDEX]
		if(!request.is_complete())
			continue

		var/datum/http_response/response = request.into_response()
		in_process_tts_messages -= list(current_message)
		if(response.errored)
			continue
		var/identifier = current_message[IDENTIFIER_INDEX]
		var/sound/new_sound = new("tmp/[identifier].ogg")
		play_tts(current_message[TARGET_INDEX], new_sound)
		for(var/atom/movable/target in current_message[EXTRA_TARGETS_INDEX])
			play_tts(target, new_sound)
		cached_voices -= identifier
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/tts/proc/queue_tts_message(target, message, speaker, filter, high_priority = FALSE)
	if(!tts_enabled)
		return

	var/static/regex/contains_alphanumeric = regex("\[a-zA-Z0-9]", "g")
	// If there is no alphanumeric char, the output will usually be static, so
	// don't bother sending
	if(contains_alphanumeric.Find(message) == 0)
		return

	var/shell_scrubbed_input = tts_filter(message)
	shell_scrubbed_input = copytext(shell_scrubbed_input, 1, 100)
	var/identifier = sha1(speaker + shell_scrubbed_input + filter)
	var/cached_voice = cached_voices[identifier]
	if(islist(cached_voice))
		cached_voice[EXTRA_TARGETS_INDEX] += target
		return
	else if(fexists("tmp/[identifier].ogg"))
		var/sound/new_sound = new("tmp/[identifier].ogg")
		play_tts(target, new_sound)
		return

	if(!(speaker in available_speakers))
		CRASH("Tried to use invalid speaker for TTS message! ([speaker])")
	speaker = tts_filter(speaker)

	var/list/headers = list()
	headers["Content-Type"] = "application/json"
	var/datum/http_request/request = new()
	var/file_name = "tmp/[identifier].ogg"
	request.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/tts_http_url)]/tts?voice=[speaker]&identifier=[identifier]&filter=[url_encode(filter)]", json_encode(list("text" = shell_scrubbed_input)), headers, file_name)
	var/list/waiting_list = queued_tts_messages
	if(length(in_process_tts_messages) < max_concurrent_requests)
		request.begin_async()
		waiting_list = in_process_tts_messages
	else if(high_priority)
		waiting_list = priority_queued_tts_messages

	var/list/data = list(target, identifier, world.time + message_timeout, request, list())
	cached_voices[identifier] = data
	waiting_list += list(data)

#undef TARGET_INDEX
#undef IDENTIFIER_INDEX
#undef TIMEOUT_INDEX
#undef REQUEST_INDEX
#undef EXTRA_TARGETS_INDEX
