//world/proc/shelleo
#define SHELLEO_ERRORLEVEL 1
#define SHELLEO_STDOUT 2
#define SHELLEO_STDERR 3

ADMIN_VERB(play_sound, "Play Global Sound", "Send a sound to all connected clients.", R_SOUND, VERB_CATEGORY_FUN, sound as sound)
	var/freq = 1
	var/vol = input(user, "What volume would you like the sound to play at?",, 100) as null|num
	if(!vol)
		return
	vol = clamp(vol, 1, 100)

	var/sound/admin_sound = new()
	admin_sound.file = sound
	admin_sound.priority = 250
	admin_sound.channel = CHANNEL_ADMIN
	admin_sound.frequency = freq
	admin_sound.wait = 1
	admin_sound.repeat = FALSE
	admin_sound.status = SOUND_STREAM
	admin_sound.volume = vol

	var/res = tgui_alert(user, "Show the title of this song to the players?",, list("Yes","No", "Cancel"))
	switch(res)
		if("Yes")
			to_chat(world, span_boldannounce("An admin played: [sound]"), confidential = TRUE)
		if("Cancel")
			return

	log_admin("[key_name(user)] played sound [sound]")
	message_admins("[key_name_admin(user)] played sound [sound]")

	for(var/mob/M in GLOB.player_list)
		if(M.client.prefs.read_preference(/datum/preference/toggle/sound_midi))
			admin_sound.volume = vol * M.client.admin_music_volume
			SEND_SOUND(M, admin_sound)
			admin_sound.volume = vol

ADMIN_VERB(play_sound_local, "Play Local Sound", "Play a sound centered on your current turf.", R_SOUND, VERB_CATEGORY_FUN, sound as sound)
	log_admin("[key_name(user)] played a local sound [sound]")
	message_admins("[key_name_admin(user)] played a local sound [sound]")
	playsound(get_turf(user.mob), sound, 50, FALSE, FALSE)

ADMIN_VERB_CONTEXT_MENU(play_sound_direct, "Play Direct Sound", R_SOUND, mob/target in world, sound as sound)
	if(!target)
		target = input(user, "Choose a mob to play the sound to. Only they will hear it.", "Play Mob Sound") as null|anything in sort_names(GLOB.player_list)
	if(!target || QDELETED(target))
		return
	log_admin("[key_name(user)] played a direct mob sound [sound] to [target].")
	message_admins("[key_name_admin(user)] played a direct mob sound [sound] to [ADMIN_LOOKUPFLW(target)].")
	SEND_SOUND(target, sound)

///Takes an input from either proc/play_web_sound or the request manager and runs it through youtube-dl and prompts the user before playing it to the server.
/proc/web_sound(mob/user, input)
	if(!check_rights(R_SOUND))
		return
	var/ytdl = CONFIG_GET(string/invoke_youtubedl)
	if(!ytdl)
		to_chat(user, span_boldwarning("Youtube-dl was not configured, action unavailable"), confidential = TRUE) //Check config.txt for the INVOKE_YOUTUBEDL value
		return
	var/web_sound_url = ""
	var/stop_web_sounds = FALSE
	var/list/music_extra_data = list()
	if(istext(input))
		var/list/output = world.shelleo("[ytdl] --geo-bypass --format \"bestaudio\[ext=mp3]/best\[ext=mp4]\[height <= 360]/bestaudio\[ext=m4a]/bestaudio\[ext=aac]\" --dump-single-json --no-playlist -- \"[input]\"")
		var/errorlevel = output[SHELLEO_ERRORLEVEL]
		var/stdout = output[SHELLEO_STDOUT]
		var/stderr = output[SHELLEO_STDERR]
		if(errorlevel)
			to_chat(user, span_boldwarning("Youtube-dl URL retrieval FAILED:"), confidential = TRUE)
			to_chat(user, span_warning("[stderr]"), confidential = TRUE)
			return
		var/list/data
		try
			data = json_decode(stdout)
		catch(var/exception/e)
			to_chat(user, span_boldwarning("Youtube-dl JSON parsing FAILED:"), confidential = TRUE)
			to_chat(user, span_warning("[e]: [stdout]"), confidential = TRUE)
			return
		if (data["url"])
			web_sound_url = data["url"]
		var/title = "[data["title"]]"
		var/webpage_url = title
		if (data["webpage_url"])
			webpage_url = "<a href=\"[data["webpage_url"]]\">[title]</a>"
		music_extra_data["duration"] = DisplayTimeText(data["duration"] * 1 SECONDS)
		music_extra_data["link"] = data["webpage_url"]
		music_extra_data["artist"] = data["artist"]
		music_extra_data["upload_date"] = data["upload_date"]
		music_extra_data["album"] = data["album"]
		var/duration = data["duration"] * 1 SECONDS
		if (duration > 10 MINUTES)
			if((tgui_alert(user, "This song is over 10 minutes long. Are you sure you want to play it?", "Length Warning!", list("No", "Yes", "Cancel")) != "Yes"))
				return
		var/res = tgui_alert(user, "Show the title of and link to this song to the players?\n[title]", "Show Info?", list("Yes", "No", "Cancel"))
		switch(res)
			if("Yes")
				music_extra_data["title"] = data["title"]
			if("No")
				music_extra_data["link"] = "Song Link Hidden"
				music_extra_data["title"] = "Song Title Hidden"
				music_extra_data["artist"] = "Song Artist Hidden"
				music_extra_data["upload_date"] = "Song Upload Date Hidden"
				music_extra_data["album"] = "Song Album Hidden"
			if("Cancel", null)
				return
		var/anon = tgui_alert(user, "Display who played the song?", "Credit Yourself?", list("Yes", "No", "Cancel"))
		switch(anon)
			if("Yes")
				if(res == "Yes")
					to_chat(world, span_boldannounce("[user.key] played: [webpage_url]"), confidential = TRUE)
				else
					to_chat(world, span_boldannounce("[user.key] played a sound"), confidential = TRUE)
			if("No")
				if(res == "Yes")
					to_chat(world, span_boldannounce("An admin played: [webpage_url]"), confidential = TRUE)
			if("Cancel", null)
				return
		SSblackbox.record_feedback("nested tally", "played_url", 1, list("[user.ckey]", "[input]"))
		log_admin("[key_name(user)] played web sound: [input]")
		message_admins("[key_name(user)] played web sound: [input]")
	else
		//pressed ok with blank
		log_admin("[key_name(user)] stopped web sounds.")

		message_admins("[key_name(user)] stopped web sounds.")
		web_sound_url = null
		stop_web_sounds = TRUE
	if(web_sound_url && !findtext(web_sound_url, GLOB.is_http_protocol))
		tgui_alert(user, "The media provider returned a content URL that isn't using the HTTP or HTTPS protocol. This is a security risk and the sound will not be played.", "Security Risk", list("OK"))
		to_chat(user, span_boldwarning("BLOCKED: Content URL not using HTTP(S) Protocol!"), confidential = TRUE)

		return
	if(web_sound_url || stop_web_sounds)
		for(var/m in GLOB.player_list)
			var/mob/M = m
			var/client/C = M.client
			if(C.prefs.read_preference(/datum/preference/toggle/sound_midi))
				if(!stop_web_sounds)
					C.tgui_panel?.play_music(web_sound_url, music_extra_data)
				else
					C.tgui_panel?.stop_music()

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Internet Sound")

ADMIN_VERB(web_sound, "Play Internet Sound", "Plays the sound file from the given address.", R_SOUND, VERB_CATEGORY_FUN)
	var/ytdl = CONFIG_GET(string/invoke_youtubedl)
	if(!ytdl)
		to_chat(user, span_boldwarning("Youtube-dl was not configured, action unavailable"), confidential = TRUE) //Check config.txt for the INVOKE_YOUTUBEDL value
		return

	var/web_sound_input = tgui_input_text(user, "Enter content URL (supported sites only, leave blank to stop playing)", "Play Internet Sound", null)

	if(length(web_sound_input))
		web_sound_input = trim(web_sound_input)
		if(findtext(web_sound_input, ":") && !findtext(web_sound_input, GLOB.is_http_protocol))
			to_chat(user, span_boldwarning("Non-http(s) URIs are not allowed."), confidential = TRUE)
			to_chat(user, span_warning("For youtube-dl shortcuts like ytsearch: please use the appropriate full URL from the website."), confidential = TRUE)
			return
		var/shell_scrubbed_input = shell_url_scrub(web_sound_input)
		web_sound(user.mob, shell_scrubbed_input)
	else
		web_sound(user.mob, null)

/datum/admin_verb_holder/web_sound/assosciate_client(client/user)
	if(!CONFIG_GET(string/invoke_youtubedl))
		return
	..()

ADMIN_VERB(set_round_end_sound, "Set Round End Sound", "Sets the sound sent to all connected clients when the round ends.", R_SOUND, VERB_CATEGORY_FUN, sound as sound)
	SSticker.SetRoundEndSound(sound)

	log_admin("[key_name(user)] set the round end sound to [sound]")
	message_admins("[key_name_admin(user)] set the round end sound to [sound]")

ADMIN_VERB(stop_sounds, "Stop All Playing Sounds", "Stop all currently playing sounds.", NONE, VERB_CATEGORY_FUN)
	log_admin("[key_name(user)] stopped all currently playing sounds.")
	message_admins("[key_name_admin(user)] stopped all currently playing sounds.")
	for(var/mob/listener as anything in GLOB.player_list)
		SEND_SOUND(listener, sound(null))
		listener.client?.tgui_panel?.stop_music()

//world/proc/shelleo
#undef SHELLEO_ERRORLEVEL
#undef SHELLEO_STDOUT
#undef SHELLEO_STDERR
