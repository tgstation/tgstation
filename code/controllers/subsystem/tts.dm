/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/proc/tts_alphanumeric_filter(text)
	// Only allow alphanumeric characters and whitespace
	var/static/regex/bad_chars_regex = regex("\[^a-zA-Z0-9 ,?.!'&-]", "g")
	return bad_chars_regex.Replace(text, " ")


#define TARGET_INDEX 1
#define IDENTIFIER_INDEX 2
#define TIMEOUT_INDEX 3
#define REQUEST_INDEX 4
#define MESSAGE_INDEX 5
#define EXTRA_TARGETS_INDEX 6
#define LANGUAGE_INDEX 7

#define CACHE_PENDING "pending"

SUBSYSTEM_DEF(tts)
	name = "Text To Speech"
	// Basically every tick
	wait = 0.05 SECONDS
	init_order = INIT_ORDER_TTS
	priority = FIRE_PRIORITY_TTS

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

	/// Messages can be timed out earlier if the algorithm thinks that
	/// it's going to take too long for their message to be processed.
	/// This'll determine the minimum extent of how late it is allowed to begin timing messages out
	var/message_timeout_early_minimum = 3 SECONDS

	var/max_concurrent_requests = 5

	/// The real time factor. For example, an RTF of 0.33 means it'll take 2 seconds to create a 6 second voice clip
	/// This is estimated based on how long it takes to receive text based on how long it take to process on the server
	var/rtf = 0

/proc/cmp_word_length_asc(list/a, list/b)
	return length(a[MESSAGE_INDEX]) - length(b[MESSAGE_INDEX])

#define AVERAGE_SPEECH_WPM 100
#define AVERAGE_SYLLABLE_LENGTH 3
#define AVERAGE_SYLLABLE_PER_SECOND 4

/datum/controller/subsystem/tts/proc/estimate_word_processing_length(text, rtf_override)
	var/rtf_to_use = rtf_override
	if(!rtf_to_use)
		rtf_to_use = rtf
	var/words = length(splittext(text, " "))
	var/characters = length(replacetext(text, " ", ""))
	// Take the longest time
	return max(
		// Average speech time based on word count
		(words / AVERAGE_SPEECH_WPM) * 60,
		// Average speech time based on character count
		(characters / (AVERAGE_SYLLABLE_LENGTH * AVERAGE_SYLLABLE_PER_SECOND))
	) * rtf_to_use

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
	rustg_file_write(json_encode(available_speakers), "data/cached_tts_voices.json")
	return SS_INIT_SUCCESS

/datum/controller/subsystem/tts/proc/play_tts(target, sound, datum/language/language, text_url = null, identifier)
	var/turf/turf_source = get_turf(target)

	if (!turf_source)
		return

	//allocate a channel if necessary now so its the same for everyone
	var/channel = SSsounds.random_available_channel()
	var/listeners = get_hearers_in_view(SOUND_RANGE, turf_source)

	for(var/mob/listening_mob in listeners | SSmobs.dead_players_by_zlevel[turf_source.z])//observers always hear through walls
		var/datum/language_holder/holder = listening_mob.get_language_holder()
		if(!istype(SSassets.transport, /datum/asset_transport/webroot)) // set up a CDN
			SSassets.transport.send_assets(listening_mob, list(identifier))
		if(!listening_mob.client?.prefs.read_preference(/datum/preference/toggle/sound_tts_use_html_audio)) // If they're using HTML audio, that subsystem handles hearing it.
			if(get_dist(listening_mob, turf_source) <= SOUND_RANGE && listening_mob.client?.prefs.read_preference(/datum/preference/toggle/sound_tts) && holder.has_language(language, spoken = FALSE))
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

	if(text_url)
		if(!SShtml_audio.channel_assignment.Find(target))
			SShtml_audio.register_player(target, TRUE) // we require LOS for speakers on TTS
		SShtml_audio.play_audio(target, text_url)

/datum/controller/subsystem/tts/proc/handle_request(list/entry)
	var/time_left = entry[TIMEOUT_INDEX]
	var/estimated_processing_time = estimate_word_processing_length(entry[MESSAGE_INDEX])
	if(time_left < world.time || (time_left < world.time + message_timeout_early_minimum && time_left - estimated_processing_time < world.time))
		cached_voices -= entry[IDENTIFIER_INDEX]
		return
	var/datum/http_request/request = entry[REQUEST_INDEX]
	request.begin_async()
	in_process_tts_messages += list(entry)

/datum/controller/subsystem/tts/fire(resumed)
	if(!tts_enabled)
		flags |= SS_NO_FIRE
		return

	if(!resumed)
		var/list/priority_list = priority_queued_tts_messages
		while(length(in_process_tts_messages) < max_concurrent_requests && priority_list.len > 0)
			var/list/entry = popleft(priority_list)
			handle_request(entry)
		var/list/less_priority_list = queued_tts_messages
		while(length(in_process_tts_messages) < max_concurrent_requests && less_priority_list.len > 0)
			var/list/entry = popleft(less_priority_list)
			handle_request(entry)
		current_processing_tts_messages = in_process_tts_messages.Copy()

	// For speed
	var/list/processing_messages = current_processing_tts_messages
	while(processing_messages.len)
		var/current_message = processing_messages[processing_messages.len]
		processing_messages.len--
		if(current_message[TIMEOUT_INDEX] < world.time)
			in_process_tts_messages -= list(current_message)
			cached_voices -= current_message[IDENTIFIER_INDEX]
			continue

		var/datum/http_request/request = current_message[REQUEST_INDEX]
		if(!request.is_complete())
			continue

		var/datum/http_response/response = request.into_response()
		in_process_tts_messages -= list(current_message)
		if(response.errored)
			cached_voices -= current_message[IDENTIFIER_INDEX]
			continue
		var/datum/asset_transport/asset_transport = SSassets.transport
		var/identifier = current_message[IDENTIFIER_INDEX]
		var/sound/new_sound = new("tmp/[identifier].mp3")
		var/datum/asset_cache_item/cached_mp3 = new(identifier, "tmp/[identifier].mp3")
		cached_mp3.namespace = "text_to_speech"
		asset_transport.register_asset(identifier, cached_mp3)
		var/current_text_url = asset_transport.get_asset_url(null, cached_mp3)
		play_tts(current_message[TARGET_INDEX], new_sound, current_message[LANGUAGE_INDEX], current_text_url, identifier)
		for(var/atom/movable/target in current_message[EXTRA_TARGETS_INDEX])
			play_tts(target, new_sound, current_message[LANGUAGE_INDEX], current_text_url, identifier)
		cached_voices -= identifier
		var/time_taken = (message_timeout - (current_message[TIMEOUT_INDEX] - world.time)) / 10
		rtf = time_taken / estimate_word_processing_length(current_message[MESSAGE_INDEX], 1)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/tts/proc/queue_tts_message(target, message, datum/language/language, speaker, filter, high_priority = FALSE)
	if(!tts_enabled)
		return

	var/static/regex/contains_alphanumeric = regex("\[a-zA-Z0-9]", "g")
	// If there is no alphanumeric char, the output will usually be static, so
	// don't bother sending
	if(contains_alphanumeric.Find(message) == 0)
		return

	var/shell_scrubbed_input = tts_alphanumeric_filter(message)
	shell_scrubbed_input = copytext(shell_scrubbed_input, 1, 100)
	var/identifier = sha1(speaker + shell_scrubbed_input + filter)
	var/cached_voice = cached_voices[identifier]
	if(islist(cached_voice))
		cached_voice[EXTRA_TARGETS_INDEX] += target
		return
	else if(fexists("tmp/[identifier].mp3"))
		var/sound/new_sound = new("tmp/[identifier].mp3")
		var/current_text_url = SSassets.transport.get_asset_url(identifier)
		play_tts(target, new_sound, language, current_text_url, identifier)
		return
	if(!(speaker in available_speakers))
		return
	speaker = tts_alphanumeric_filter(speaker)

	var/list/headers = list()
	headers["Content-Type"] = "application/json"
	var/datum/http_request/request = new()
	var/file_name = "tmp/[identifier].mp3"
	request.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/tts_http_url)]/tts?voice=[speaker]&identifier=[identifier]&filter=[url_encode(filter)]", json_encode(list("text" = shell_scrubbed_input)), headers, file_name)
	var/list/waiting_list = queued_tts_messages
	if(length(in_process_tts_messages) < max_concurrent_requests)
		request.begin_async()
		waiting_list = in_process_tts_messages
	else if(high_priority)
		waiting_list = priority_queued_tts_messages

	var/list/data = list(target, identifier, world.time + message_timeout, request, shell_scrubbed_input, list(), language)
	cached_voices[identifier] = data
	waiting_list += list(data)
	sortTim(waiting_list, GLOBAL_PROC_REF(cmp_word_length_asc))

#undef TARGET_INDEX
#undef IDENTIFIER_INDEX
#undef TIMEOUT_INDEX
#undef REQUEST_INDEX
#undef MESSAGE_INDEX
#undef EXTRA_TARGETS_INDEX
#undef LANGUAGE_INDEX
