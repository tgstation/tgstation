
/// Do NOT actually use this in a real round, numb nuts. You'll log your auth key. Good for local testing only
GLOBAL_VAR(tts_auth_key_fallback)

/proc/get_tts_voice(mob/speaker, message, seed)
	var/auth_key = CONFIG_GET(string/tts_auth_key) || GLOB.tts_auth_key_fallback
	if(!auth_key)
		return ""
	var/text = url_encode(html_decode(message))
	var/chosen_seed = url_encode(seed || DEFAULT_SEED)
	var/static/tts_voice_number = 0
	tts_voice_number++
	var/api_url = "https://api.novelai.net/ai/generate-voice?"
	var/list/headers = list("authorization" = auth_key)
	api_url += "text=[text]"
	api_url += "&seed=[chosen_seed]"
	api_url += "&voice=-1"
	api_url += "&opus=false"
	api_url += "&version=v2"
	var/output_file = "data/vox_output_[tts_voice_number].mp3"
	var/datum/http_request/req = new()
	req.prepare(RUSTG_HTTP_METHOD_GET, api_url, "", headers, output_file)
	req.begin_async()
	UNTIL(req.is_complete())
	var/datum/http_response/response = req.into_response()
	if(response.status_code != 200)
		if(!response.status_code)
			log_game("[key_name(speaker)] failed to produce tts. Error: [req._raw_response]")
			message_admins("[key_name(speaker)] failed to produce tts. Error: [req._raw_response]")
		else
			log_game("[key_name(speaker)] failed to produce tts. Error code: [response.status_code]")
			message_admins("[key_name(speaker)] failed to produce a tts. Error code: [response.status_code]")
		fdel(output_file)
		return ""
	addtimer(CALLBACK(GLOBAL_PROC, /proc/cleanup_tts_file, output_file), 20 SECONDS)
	return output_file

/proc/play_tts_locally(mob/speaker, message, seed)
	var/voice = get_tts_voice(speaker, message, seed)
	if(!voice)
		return
	playsound(speaker, voice, 100, FALSE, falloff_distance = 4, ignore_walls = FALSE)

/proc/play_tts_directly(mob/listener, message, seed)
	var/voice = get_tts_voice(listener, message, seed)
	if(!voice)
		return
	SEND_SOUND(listener, sound(voice))

/proc/cleanup_tts_file(file)
	fdel(file)
