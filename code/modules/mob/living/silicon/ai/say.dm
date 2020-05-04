/mob/living/silicon/ai/say(message, bubble_type,var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
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

/mob/living/silicon/ai/radio(message, message_mode, list/spans, language)
	if(incapacitated())
		return FALSE
	if(!radio_enabled) //AI cannot speak if radio is disabled (via intellicard) or depowered.
		to_chat(src, "<span class='danger'>Your radio transmitter is offline!</span>")
		return FALSE
	..()

/mob/living/silicon/ai/get_message_mode(message)
	var/static/regex/holopad_finder = regex(@"[:.#][hH]")
	if(holopad_finder.Find(message, 1, 1))
		return MODE_HOLOPAD
	else
		return ..()

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
		send_speech(message, 7, T, "robot", message_language = language)
		to_chat(src, "<i><span class='game say'>Holopad transmitted, <span class='name'>[real_name]</span> <span class='message robot'>\"[message]\"</span></span></i>")
	else
		to_chat(src, "<span class='alert'>No holopad connected.</span>")


// Make sure that the code compiles with AI_VOX undefined
#ifdef AI_VOX
#define VOX_DELAY 600
/mob/living/silicon/ai/proc/announcement()
	var/static/announcing_vox = 0 // Stores the time of the last announcement
	if(announcing_vox > world.time)
		to_chat(src, "<span class='notice'>Please wait [DisplayTimeText(announcing_vox - world.time)].</span>")
		return
	var/max_characters = 240 // magic number but its the cap 15 allows
	var/message = input(src, "Use the power of 15.ai to say anything! (240 character maximum)", "15.ai VOX System", src.last_announcement) as text|null

	if(!message || announcing_vox > world.time)
		return

	if(incapacitated())
		return

	if(control_disabled)
		to_chat(src, "<span class='warning'>Wireless interface disabled, unable to interact with announcement PA.</span>")
		return

	if(length(message) > max_characters)
		to_chat(src, "<span class='notice'>You have too many characters! You used [length(message)] characters, you need to lower this to 240 or lower.</span>")
	var/regex/check_for_bad_chars = regex("\[^a-zA-Z!?.,' :\]+")
	if(check_for_bad_chars.Find(message))
		to_chat(src, "<span class='notice'>These characters are not available on the 15.ai system: [english_list(check_for_bad_chars.group)].</span>")
		return

	var/character_to_use = "Soldier" // temp, will allow choosing soon

	last_announcement = message

	announcing_vox = world.time + VOX_DELAY

	log_game("[key_name(src)] made a vocal announcement with the following message: [message].")
	play_vox_word(message, character_to_use, src.z, null)


/proc/play_vox_word(message, character, z_level, mob/only_listener)
	var/api_url = "https://api.fifteen.ai/app/getAudioFile"

	var/datum/http_request/req = new()
	var/params = list(
	"text" = message,
	"character" = character,
	"emotion" = "Neutral"
	)
	if(character == "GLadOS")
		params["emotion"] = "Homicidal"

	req.prepare(RUSTG_HTTP_METHOD_POST, api_url, "", params)
	req.begin_async()
	UNTIL(req.is_complete())
	world.log << "15.AI: POST returned [req._raw_response]"
	/*word = lowertext(word)

	if(GLOB.vox_sounds[word])

		var/sound_file = GLOB.vox_sounds[word]
		var/sound/voice = sound(sound_file, wait = 1, channel = CHANNEL_VOX)
		voice.status = SOUND_STREAM

 		// If there is no single listener, broadcast to everyone in the same z level
		if(!only_listener)
			// Play voice for all mobs in the z level
			for(var/mob/M in GLOB.player_list)
				if(M.can_hear() && (M.client.prefs.toggles & SOUND_ANNOUNCEMENTS))
					var/turf/T = get_turf(M)
					if(T.z == z_level)
						SEND_SOUND(M, voice)
		else
			SEND_SOUND(only_listener, voice)
		return 1
	return 0*/

#undef VOX_DELAY
#endif
