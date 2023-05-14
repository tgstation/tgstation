#define TARGET_INDEX 1
#define IDENTIFIER_INDEX 2
#define START_TIME_INDEX 3
#define REQUEST_INDEX 4
#define MESSAGE_INDEX 5

SUBSYSTEM_DEF(tts)
	name = "Text To Speech"
	wait = 0.05 SECONDS
	priority = FIRE_PRIORITY_TTS
	init_order = INIT_ORDER_TTS
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	/// Queued HTTP requests that have yet to be sent. TTS requests are handled as lists rather than datums.
	/// It could be worth refactoring TTS messages to be datums instead to reduce complexity.
	var/datum/heap/queued_tts_messages

	/// HTTP requests currently in progress but not being processed yet
	var/list/in_process_tts_messages = list()

	/// HTTP requests that are being processed to see if they've been finished
	var/list/current_processing_tts_messages = list()

	/// A list of available speakers, which are string identifiers of the TTS voices that can be used to generate TTS messages.
	var/list/available_speakers = list()

	/// A list of current tts messages being processed, mapped by their sha1 identifier.
	/// Used to prevent double processing of the same message, voice and filter, since we can just
	/// cache extra requests to the current tts message being processed at once and play them upon request completion.
	var/list/cached_voices = list()

	/// Whether TTS is enabled or not
	var/tts_enabled = FALSE

	/// TTS messages won't play if requests took longer than this duration of time.
	var/message_timeout = 7 SECONDS

	/// Messages can be timed out earlier if the algorithm thinks that
	/// it's going to take too long for their message to be processed.
	/// This'll determine the minimum extent of how late it is allowed to begin timing messages out
	var/message_timeout_early_minimum = 5 SECONDS

	/// The max concurrent http requests that can be made at one time. Used to prevent 1 server from overloading the tts server
	var/max_concurrent_requests = 4

	/// Used to calculate the average time it takes for a tts message to be received from the http server
	/// For tts messages which time out, it won't keep tracking the tts message and will just assume that the message took
	/// 7 seconds (or whatever the value of message_timeout is) to receive back a response.
	var/average_tts_messages_time = 0

/datum/controller/subsystem/tts/vv_edit_var(var_name, var_value)
	// tts being enabled depends on whether it actually exists
	if(NAMEOF(src, tts_enabled) == var_name)
		return FALSE
	return ..()

/datum/controller/subsystem/tts/stat_entry(msg)
	msg = "Active:[length(in_process_tts_messages)]|Standby:[length(queued_tts_messages.L)]|Avg:[average_tts_messages_time]"
	return ..()

/proc/cmp_word_length_asc(list/a, list/b)
	return length(b[MESSAGE_INDEX]) - length(a[MESSAGE_INDEX])

/datum/controller/subsystem/tts/Initialize()
	if(!CONFIG_GET(string/tts_http_url))
		return SS_INIT_NO_NEED

	queued_tts_messages = new /datum/heap(GLOBAL_PROC_REF(cmp_word_length_asc))
	var/datum/http_request/request = new()
	var/list/headers = list()
	headers["Authorization"] = CONFIG_GET(string/tts_http_token)
	request.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/tts_http_url)]/tts-voices", "", headers)
	request.begin_async()
	UNTIL(request.is_complete())
	var/datum/http_response/response = request.into_response()
	if(response.errored || response.status_code != 200)
		stack_trace(response.error)
		return SS_INIT_FAILURE
	max_concurrent_requests = CONFIG_GET(number/tts_max_concurrent_requests)
	available_speakers = json_decode(response.body)
	tts_enabled = TRUE
	rustg_file_write(json_encode(available_speakers), "data/cached_tts_voices.json")
	rustg_file_write("rustg HTTP requests can't write to folders that don't exist, so we need to make it exist.", "tmp/tts/init.txt")
	return SS_INIT_SUCCESS

/datum/controller/subsystem/tts/proc/play_tts(target, sound/audio, datum/language/language, local, range = 7)
	if(local)
		SEND_SOUND(target, audio)
		return

	var/turf/turf_source = get_turf(target)
	if(!turf_source)
		return

	var/channel = SSsounds.random_available_channel()
	var/listeners = get_hearers_in_view(range, turf_source)

	for(var/mob/listening_mob in listeners | SSmobs.dead_players_by_zlevel[turf_source.z])//observers always hear through walls
		var/datum/language_holder/holder = listening_mob.get_language_holder()
		if(!listening_mob.client?.prefs.read_preference(/datum/preference/toggle/sound_tts))
			continue

		if(get_dist(listening_mob, turf_source) <= range && holder.has_language(language, spoken = FALSE))
			listening_mob.playsound_local(
				turf_source,
				vol = (listening_mob == target)? 60 : 85,
				falloff_exponent = SOUND_FALLOFF_EXPONENT,
				channel = channel,
				pressure_affected = TRUE,
				sound_to_use = audio,
				max_distance = SOUND_RANGE,
				falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE,
				distance_multiplier = 1,
				use_reverb = TRUE
			)

/datum/controller/subsystem/tts/proc/handle_request(list/entry)
	var/timeout_time = entry[START_TIME_INDEX] + message_timeout
	if(timeout_time < world.time)
		cached_voices -= entry[IDENTIFIER_INDEX]
		return
	var/datum/http_request/request = entry[REQUEST_INDEX]
	request.begin_async()
	in_process_tts_messages += list(entry)

// Need to wait for all HTTP requests to complete here because of a rustg crash bug that causes crashes when dd restarts whilst HTTP requests are ongoing.
/datum/controller/subsystem/tts/Shutdown()
	tts_enabled = FALSE
	for(var/list/data in in_process_tts_messages)
		var/datum/http_request/request = data[REQUEST_INDEX]
		UNTIL(request.is_complete())

/datum/controller/subsystem/tts/fire(resumed)
	if(!tts_enabled)
		flags |= SS_NO_FIRE
		return

	if(!resumed)
		while(length(in_process_tts_messages) < max_concurrent_requests && length(queued_tts_messages.L) > 0)
			var/list/entry = queued_tts_messages.pop()
			handle_request(entry)
		current_processing_tts_messages = in_process_tts_messages.Copy()

	// For speed
	var/list/processing_messages = current_processing_tts_messages
	while(processing_messages.len)
		var/current_message = processing_messages[processing_messages.len]
		processing_messages.len--
		var/datum/http_request/request = current_message[REQUEST_INDEX]
		if(!request.is_complete())
			continue

		var/datum/http_response/response = request.into_response()
		in_process_tts_messages -= list(current_message)
		average_tts_messages_time = MC_AVERAGE(average_tts_messages_time, world.time - current_message[START_TIME_INDEX])
		// If it took too long to process, don't bother playing it
		var/timeout_time = current_message[START_TIME_INDEX] + message_timeout
		var/identifier = current_message[IDENTIFIER_INDEX]
		cached_voices -= identifier
		if(response.errored || timeout_time < world.time)
			continue

		var/sound/new_sound = new("tmp/tts/[identifier].ogg")
		for(var/target in current_message[TARGET_INDEX])
			play_tts(target["target"], new_sound, target["language"], target["local"], target["range"])
		if(MC_TICK_CHECK)
			return

#define ADD_TARGET_TO_STRUCT(tts_struct, target, language, local, range) ##tts_struct[TARGET_INDEX] += list(list("target" = ##target, "language" = ##language, "local" = ##local, "range" = ##range))

/datum/controller/subsystem/tts/proc/queue_tts_message(target, message, datum/language/language, speaker, filter, local = FALSE, message_range = 7)
	if(!tts_enabled)
		return

	var/static/regex/contains_alphanumeric = regex("\[a-zA-Z0-9]")
	// If there is no alphanumeric char, the output will usually be static, so
	// don't bother sending
	if(contains_alphanumeric.Find(message) == 0)
		return

	var/shell_scrubbed_input = tts_speech_filter(message)
	shell_scrubbed_input = copytext(shell_scrubbed_input, 1, 300)
	var/identifier = sha1(speaker + filter + shell_scrubbed_input)
	var/cached_voice = cached_voices[identifier]
	if(islist(cached_voice))
		ADD_TARGET_TO_STRUCT(cached_voice, target, language, local, message_range)
		return
	else if(fexists("tmp/tts/[identifier].ogg"))
		var/sound/new_sound = new("tmp/tts/[identifier].ogg")
		play_tts(target, new_sound, language, local, message_range)
		return
	if(!(speaker in available_speakers))
		return

	var/list/headers = list()
	headers["Content-Type"] = "application/json"
	headers["Authorization"] = CONFIG_GET(string/tts_http_token)
	var/datum/http_request/request = new()
	var/file_name = "tmp/tts/[identifier].ogg"
	request.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/tts_http_url)]/tts?voice=[speaker]&identifier=[identifier]&filter=[url_encode(filter)]", json_encode(list("text" = shell_scrubbed_input)), headers, file_name)
	// This'll probably be better off datumized in the future, but it's not necessary to do right now
	var/list/data = list(
		// TARGET_INDEX = 1
		list(),
		// IDENTIFIER_INDEX = 2
		identifier,
		// START_TIME_INDEX = 3
		world.time,
		// REQUEST_INDEX = 4
		request,
		// MESSAGE_INDEX = 5
		shell_scrubbed_input,
	)
	ADD_TARGET_TO_STRUCT(data, target, language, local, message_range)
	cached_voices[identifier] = data
	if(length(in_process_tts_messages) < max_concurrent_requests)
		request.begin_async()
		in_process_tts_messages += list(data)
	else
		queued_tts_messages.insert(list(data))

#undef ADD_TARGET_TO_STRUCT

#undef TARGET_INDEX
#undef IDENTIFIER_INDEX
#undef START_TIME_INDEX
#undef REQUEST_INDEX
#undef MESSAGE_INDEX
