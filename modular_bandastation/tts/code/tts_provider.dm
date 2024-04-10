/datum/tts_provider
	var/name = "STUB"
	var/is_enabled = TRUE
	var/api_url

	var/is_throttled = FALSE
	var/throttled_until = 0

	var/timed_out_requests = 0
	var/failed_requests = 0
	var/failed_requests_limit = 10

/datum/tts_provider/proc/request(text, datum/tts_seed/seed, datum/callback/proc_callback)
	return TRUE

/datum/tts_provider/proc/process_response(list/response)
	return null

/datum/tts_provider/proc/throttle_check()
	if(is_throttled && throttled_until < world.time)
		return TRUE
	is_throttled = FALSE
	return FALSE

/datum/tts_provider/proc/pitch_whisper(text)
	return text

/datum/tts_provider/proc/rate_faster(text)
	return text

/datum/tts_provider/proc/rate_medium(text)
	return text
