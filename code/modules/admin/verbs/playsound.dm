#define YTDL_NOT_CONFIGURED "YOUTUBE DL NOT CONFIGURED"
#define YTDL_FAILURE_NO_HTTPS "MEDIA IS NOT HTTP(S)"
#define YTDL_FAILURE_NO_URL "NO URL SPECIFIED"
#define YTDL_FAILURE_UNKNOWN "YOUTUBE DL FAILED (UNKNOWN)"
#define YTDL_FAILURE_FORMAT "YOUTUBE DL COULD NOT FIND THE RIGHT FORMAT"
#define YTDL_FAILURE_BAD_JSON "YOUTUBE DL RETURNED A BAD JSON"

/client/proc/play_sound(S as sound)
	set category = "Fun"
	set name = "Play Global Sound"
	if(!check_rights(R_SOUNDS))
		return

	var/freq = 1
	var/vol = input(usr, "What volume would you like the sound to play at?",, 100) as null|num
	if(!vol)
		return
	vol = CLAMP(vol, 1, 100)

	var/sound/admin_sound = new()
	admin_sound.file = S
	admin_sound.priority = 250
	admin_sound.channel = CHANNEL_ADMIN
	admin_sound.frequency = freq
	admin_sound.wait = 1
	admin_sound.repeat = 0
	admin_sound.status = SOUND_STREAM
	admin_sound.volume = vol

	var/res = alert(usr, "Show the title of this song to the players?",, "Yes","No", "Cancel")
	switch(res)
		if("Yes")
			to_chat(world, "<span class='boldannounce'>An admin played: [S]</span>")
		if("Cancel")
			return

	log_admin("[key_name(src)] played sound [S]")
	message_admins("[key_name_admin(src)] played sound [S]")

	for(var/mob/M in GLOB.player_list)
		if(M.client.prefs.toggles & SOUND_MIDI)
			var/user_vol = M.client.chatOutput.adminMusicVolume
			if(user_vol)
				admin_sound.volume = vol * (user_vol / 100)
			SEND_SOUND(M, admin_sound)
			admin_sound.volume = vol

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Global Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/play_local_sound(S as sound)
	set category = "Fun"
	set name = "Play Local Sound"
	if(!check_rights(R_SOUNDS))
		return

	log_admin("[key_name(src)] played a local sound [S]")
	message_admins("[key_name_admin(src)] played a local sound [S]")
	playsound(get_turf(src.mob), S, 50, 0, 0)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Local Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/proc/invoke_youtubedl(url, dump_error_to_chat, mob/dump_to)
	if(!istext(url))
		return YTDL_FAILURE_NO_URL
	var/ytdl = CONFIG_GET(string/invoke_youtubedl)
	if(!ytdl)
		return YTDL_NOT_CONFIGURED
	url = trim(url)
	if(!length(url))
		return YTDL_FAILURE_NO_URL 
	if(findtext(url, ":") && !findtext(url, GLOB.is_http_protocol))
		return YTDL_FAILURE_NO_HTTPS
	var/shell_scrubbed_input = shell_url_scrub(url)
	var/list/output = world.shelleo("[ytdl] --format \"bestaudio\[ext=mp3]/best\[ext=mp4]\[height<=360]/bestaudio\[ext=m4a]/bestaudio\[ext=aac]\" --dump-single-json --no-playlist -- \"[shell_scrubbed_input]\"")
	var/errorlevel = output[SHELLEO_ERRORLEVEL]
	var/stdout = output[SHELLEO_STDOUT]
	var/stderr = output[SHELLEO_STDERR]
	if(!errorlevel)
		var/list/data
		try			//NOTE: Try/catch might break admin proccalls on exception catch. It is recommended to admins to not directly call this proc unless they really know what they are doing or are willing to lose their proccall for a round.
			data = json_decode(stdout)
		catch(var/exception/e)
			if(dump_error_to_chat)
				if(!dump_to && usr)
					dump_to = usr
				to_chat(dump_to, "<span class='boldwarning'>Youtube-dl JSON parsing error: </span><span class='warning'>[e]: [stdout]</span>")
			return YTDL_FAILURE_BAD_JSON
		if(data["url"] && !findtext(data["url"], GLOB.is_http_protocol))
			return YTDL_FAILURE_NO_HTTPS
		return data
	else
		if(!dump_error_to_chat)
			stack_trace("YoutubeDL error: [stderr]")
		else
			if(!dump_to && usr)
				dump_to = usr
			to_chat(dump_to, "<span class='boldwarning'>Youtube-dl retrieval failed.</span><span class='warning'> Error: [stderr]</span>")
	return YTDL_FAILURE_UNKNOWN

/client/proc/play_web_sound(pitch = 1)
	set category = "Fun"
	set name = "Play Internet Sound"
	if(!check_rights(R_SOUNDS))
		return
	var/url = input("Enter content URL (supported sites only, leave blank to stop playing)", "Play Internet Sound via youtube-dl") as text|null
	if(!length(url))//pressed ok with blank
		log_admin("[key_name(src)] stopped web sound")
		message_admins("[key_name(src)] stopped web sound")
		for(var/m in GLOB.player_list)
			var/mob/M = m
			var/client/C = M.client
			if((C.prefs.toggles & SOUND_MIDI) && C.chatOutput && !C.chatOutput.broken && C.chatOutput.loaded)
				C.chatOutput.stopMusic()
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Internet Sound")
		return
	var/list/returned = invoke_youtubedl(url, TRUE, src)
	if(returned == YTDL_NOT_CONFIGURED)
		to_chat(src, "<span class='boldwarning'>Youtube-dl was not configured, action unavailable</span>") //Check config.txt for the INVOKE_YOUTUBEDL value
		return
	if(returned == YTDL_FAILURE_NO_HTTPS)
		to_chat(src, "<span class='boldwarning'>Non-http(s) URIs are not allowed.</span>")
		to_chat(src, "<span class='warning'>For youtube-dl shortcuts like ytsearch: please use the appropriate full url from the website.</span>")
		return
	if(returned == YTDL_FAILURE_BAD_JSON)
		to_chat(src, "<span class='boldwarning'>Youtube-dl JSON parsing FAILED. Error dumped above.</span>")
		return
	if(returned == YTDL_FAILURE_UNKNOWN)
		return	
	var/web_sound_url
	if (returned["url"])
		web_sound_url = returned["url"]
		var/title = "[returned["title"]]"
		var/webpage_url = title
		if (returned["webpage_url"])
			webpage_url = "<a href=\"[returned["webpage_url"]]\">[title]</a>"
		var/res = alert(usr, "Show the title of and link to this song to the players?\n[title]",, "No", "Yes", "Cancel")
		switch(res)
			if("Yes")
				to_chat(world, "<span class='boldannounce'>An admin played: [webpage_url]</span>")
			if("Cancel")
				return
		SSblackbox.record_feedback("nested tally", "played_url", 1, list("[ckey]", "[url]"))
		log_admin("[key_name(src)] played web sound: [url]")
		message_admins("[key_name(src)] played web sound: [url]")
		for(var/m in GLOB.player_list)
			var/mob/M = m
			var/client/C = M.client
			if((C.prefs.toggles & SOUND_MIDI) && C.chatOutput && !C.chatOutput.broken && C.chatOutput.loaded)
				C.chatOutput.sendMusic(web_sound_url, pitch)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Internet Sound")

/client/proc/set_round_end_sound(S as sound)
	set category = "Fun"
	set name = "Set Round End Sound"
	if(!check_rights(R_SOUNDS))
		return

	SSticker.SetRoundEndSound(S)

	log_admin("[key_name(src)] set the round end sound to [S]")
	message_admins("[key_name_admin(src)] set the round end sound to [S]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Set Round End Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/stop_sounds()
	set category = "Debug"
	set name = "Stop All Playing Sounds"
	if(!src.holder)
		return

	log_admin("[key_name(src)] stopped all currently playing sounds.")
	message_admins("[key_name_admin(src)] stopped all currently playing sounds.")
	for(var/mob/M in GLOB.player_list)
		if(M.client)
			SEND_SOUND(M, sound(null))
			var/client/C = M.client
			if(C && C.chatOutput && !C.chatOutput.broken && C.chatOutput.loaded)
				C.chatOutput.stopMusic()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Stop All Playing Sounds") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
