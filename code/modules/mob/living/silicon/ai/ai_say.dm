/mob/living/silicon/ai/say(message, bubble_type,list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(parent && istype(parent) && parent.stat != DEAD) //If there is a defined "parent" AI, it is actually an AI, and it is alive, anything the AI tries to say is said by the parent instead.
		parent.say(message, language)
		return
	..(message)

/mob/living/silicon/ai/compose_track_href(atom/movable/speaker, namepart)
	var/mob/M = speaker.GetSource()
	if(M)
		return "<a href='?src=[REF(src)];track=[html_encode(namepart)]'>"
	return ""

/mob/living/silicon/ai/compose_job(atom/movable/speaker, message_langs, raw_message, radio_freq)
	//Also includes the </a> for AI hrefs, for convenience.
	return "[radio_freq ? " (" + speaker.GetJob() + ")" : ""]" + "[speaker.GetSource() ? "</a>" : ""]"

/mob/living/silicon/ai/IsVocal()
	return !CONFIG_GET(flag/silent_ai)

/mob/living/silicon/ai/radio(message, list/message_mods = list(), list/spans, language)
	if(incapacitated())
		return FALSE
	if(!radio_enabled) //AI cannot speak if radio is disabled (via intellicard) or depowered.
		to_chat(src, "<span class='danger'>Your radio transmitter is offline!</span>")
		return FALSE
	..()

//For holopads only. Usable by AI.
/mob/living/silicon/ai/proc/holopad_talk(message, language)
	message = trim(message)

	if (!message)
		return

	var/obj/machinery/holopad/T = current
	if(istype(T) && T.masters[src])//If there is a hologram and its master is the user.
		var/turf/padturf = get_turf(T)
		var/padloc
		if(padturf)
			padloc = AREACOORD(padturf)
		else
			padloc = "(UNKNOWN)"
		src.log_talk(message, LOG_SAY, tag="HOLOPAD in [padloc]")
		send_speech(message, 7, T, MODE_ROBOT, message_language = language)
		to_chat(src, "<i><span class='game say'>Holopad transmitted, <span class='name'>[real_name]</span> <span class='message robot'>\"[message]\"</span></span></i>")
	else
		to_chat(src, "<span class='alert'>No holopad connected.</span>")


// Make sure that the code compiles with AI_VOX undefined
#ifdef AI_VOX
#define VOX_DELAY 300
/mob/living/silicon/ai/proc/announcement()
	if(announcing_vox > world.time)
		to_chat(src, "<span class='notice'>Please wait [DisplayTimeText(announcing_vox - world.time)].</span>")
		return
	var/datum/http_request/req = new()
	req.prepare(RUSTG_HTTP_METHOD_GET, "https://api.15.ai/app/getCharacters")
	req.begin_async()
	UNTIL(req.is_complete())
	var/datum/http_response/response = req.into_response()
	if(!response.status_code)
		to_chat(src, "Connection to 15.ai failed. Error: [req._raw_response]")
		return
	if(response.status_code != 200)
		to_chat(src, "Connection to 15.ai failed. Error code: [response.status_code]")
		return
	var/list/usable_characters = json_decode(response["body"])
	var/list/allowed_characters = CONFIG_GET(keyed_list/vox_voice_whitelist)
	var/list/passed_characters = list()
	if(allowed_characters.len)
		for(var/character_name in usable_characters)
			var/changed_name = lowertext(replacetext(character_name, " ", "_"))
			if(allowed_characters[changed_name])
				passed_characters += character_name
	else
		passed_characters = usable_characters
	var/character_to_use = input(src, "Choose what 15.ai character to use:", "15.ai Character Choice")  as null|anything in passed_characters
	if(!character_to_use)
		return
	var/max_characters = 300 // magic number but its the cap 15 allows
	var/message = input(src, "Use the power of 15.ai to say anything! ([max_characters] character maximum)", "15.ai VOX System", src.last_announcement) as text|null

	if(!message || announcing_vox > world.time)
		return

	if(incapacitated())
		return

	if(control_disabled)
		to_chat(src, "<span class='warning'>Wireless interface disabled, unable to interact with announcement PA.</span>")
		return

	if(length(message) > max_characters)
		to_chat(src, "<span class='notice'>You have too many characters! You used [length(message)] characters, you need to lower this to [max_characters] or lower.</span>")
		return
	var/regex/check_for_bad_chars = regex("\[^a-zA-Z!?.,' :\]+")
	if(check_for_bad_chars.Find(message))
		to_chat(src, "<span class='notice'>These characters are not available on the 15.ai system: [english_list(check_for_bad_chars.group)].</span>")
		return
	last_announcement = message

	announcing_vox = world.time + VOX_DELAY

	log_game("[key_name(src)] started making a 15.AI announcement with the following message: [message]")
	message_admins("[key_name(src)] started making a 15.AI announcement with the following message: [message]")
	play_vox_word(message, character_to_use, src, src.z, null)


/proc/play_vox_word(message, character, mob/living/silicon/ai/speaker, z_level, mob/only_listener)
	var/api_url = "https://api.15.ai/app/getAudioFile"
	var/static/vox_voice_number = 0
	var/datum/http_request/req = new()
	vox_voice_number++
	req.prepare(RUSTG_HTTP_METHOD_POST, api_url, "{\"character\":\"[character]\",\"text\":\"[message]\",\"emotion\":\"Contextual\"}", list("Content-Type" = "application/json", "User-Agent" = "/tg/station 13 server"), json_encode(list("output_filename" = "data/vox_[vox_voice_number].wav")))
	req.begin_async()
	UNTIL(req.is_complete())
	var/datum/http_response/res = req.into_response()
	if(res.status_code == 200)
		var/full_name_file = "data/vox_[vox_voice_number].wav"
		// Slap an extra 5 seconds on at the end for reverb padding.
		shell("./data/ffmpeg.exe -nostats -loglevel 0 -i ./[full_name_file] -af \"apad=pad_dur=6\" -vn -y ./[full_name_file]")
		// Apply a reverb effect for space authenticity.
		shell("./data/ffmpeg.exe -nostats -loglevel 0 -i ./[full_name_file] -i ./sound/effects/reverb_effect_vox.wav -filter_complex \"\[0\] \[1\] afir=dry=10:wet=10 \[reverb\]; \[0\] \[reverb\] amix=inputs=2:weights=7 1\" -vn -y ./data/vox_[vox_voice_number].mp3")
		if (!istype(SSassets.transport, /datum/asset_transport/webroot))
			log_game("CDN not set up, VOX aborted.")
			message_admins("CDN not set up, VOX aborted.")
			fdel("data/vox_[vox_voice_number].wav")
			fdel("data/vox_[vox_voice_number].mp3")
			return
		var/datum/asset_transport/webroot/WR = SSassets.transport
		var/shit_fuck_ass = "data/vox_[vox_voice_number].mp3"
		var/datum/asset_cache_item/ACI = new("[md5filepath(shit_fuck_ass)].mp3", file("data/vox_[vox_voice_number].mp3"))
		ACI.namespace = "15aivox"
		WR.save_asset_to_webroot(ACI)
		var/url = WR.get_asset_url(null, ACI)

		log_game("[key_name(speaker)] finished making a 15.AI announcement with the following message: [message]")
		message_admins("[key_name(speaker)] finished making a 15.AI announcement with the following message: [message]")
		speaker.say(";[message]")
		// If there is no single listener, broadcast to everyone in the same z level
		if(!only_listener)
			// Play voice for all mobs in the z level
			for(var/mob/M in GLOB.player_list)
				var/turf/T = get_turf(M)
				if(T.z == z_level && M.can_hear())
					M <<browse({"<META http-equiv="X-UA-Compatible" content="IE=edge"><audio autoplay><source src=\"[url]\" type=\"audio/mpeg\"></audio>"}, "window=vox_player&file=vox_player.htm")
		else
			only_listener <<browse({"<META http-equiv="X-UA-Compatible" content="IE=edge"><audio autoplay><source src=\"[url]\" type=\"audio/mpeg\"></audio>"}, "window=vox_player&file=vox_player.htm")
		fdel("data/vox_[vox_voice_number].wav")
		fdel("data/vox_[vox_voice_number].mp3")
		addtimer(CALLBACK(GLOBAL_PROC, .world/proc/delete_vox_statement, "[CONFIG_GET(string/asset_cdn_webroot)][WR.get_asset_suffex(ACI)]"), 30 SECONDS)
		return 1
	else
		if(!res.status_code)
			log_game("[key_name(speaker)] failed to produce a 15.AI announcement due to an error. Error: [req._raw_response]")
			message_admins("[key_name(speaker)] failed to produce a 15.AI announcement due to an error. Error: [req._raw_response]")
		else
			log_game("[key_name(speaker)] failed to produce a 15.AI announcement due to an error. Error code: [res.status_code]")
			message_admins("[key_name(speaker)] failed to produce a 15.AI announcement due to an error. Error code: [res.status_code]")
		to_chat(speaker, "The speech synthesizer failed to return audio. Your speech cooldown has been reset. Please try again.")
		fdel("data/vox_[vox_voice_number].wav")
		fdel("data/vox_[vox_voice_number].mp3")
		speaker.announcing_vox = world.time
	return 0

/world/proc/delete_vox_statement(string)
	fdel(string)

#undef VOX_DELAY
#endif
