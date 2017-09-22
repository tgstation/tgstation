/client/proc/play_sound(S as sound)
	set category = "Fun"
	set name = "Play Global Sound"
	if(!check_rights(R_SOUNDS))
		return

	var/freq = 1
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		freq = pick(0.5, 0.7, 0.8, 0.85, 0.9, 0.95, 1.1, 1.2, 1.4, 1.6, 2.0, 2.5)
		to_chat(src, "You feel the Honkmother messing with your song...")

	var/vol = input(usr, "What volume would you like the sound to play at?",, 100) as null|num
	if(!vol)
		return
	vol = Clamp(vol, 1, 100)

	var/sound/admin_sound = new()
	admin_sound.file = S
	admin_sound.priority = 250
	admin_sound.channel = CHANNEL_ADMIN
	admin_sound.frequency = freq
	admin_sound.wait = 1
	admin_sound.repeat = 0
	admin_sound.status = SOUND_STREAM
	admin_sound.volume = vol

	var/res = alert(usr, "Show the title of this song to the players?",, "No", "Yes", "Cancel")
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

	SSblackbox.add_details("admin_verb","Play Global Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/play_local_sound(S as sound)
	set category = "Fun"
	set name = "Play Local Sound"
	if(!check_rights(R_SOUNDS))
		return

	log_admin("[key_name(src)] played a local sound [S]")
	message_admins("[key_name_admin(src)] played a local sound [S]")
	playsound(get_turf(src.mob), S, 50, 0, 0)
	SSblackbox.add_details("admin_verb","Play Local Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/play_web_sound()
	set category = "Fun"
	set name = "Play Internet Sound"
	if(!check_rights(R_SOUNDS))
		return

	if(!config.invoke_youtubedl)
		to_chat(src, "<span class='boldwarning'>Youtube-dl was not configured, action unavailable</span>") //Check config.txt for the INVOKE_YOUTUBEDL value
		return

	var/web_sound_input = input("Enter content URL (supported sites only, leave blank to stop playing)", "Play Internet Sound via youtube-dl") as text|null
	if(istext(web_sound_input))
		var/web_sound_url = ""
		var/pitch
		if(length(web_sound_input))

			web_sound_input = trim(web_sound_input)
			var/static/regex/html_protocol_regex = regex("https?://")
			if(findtext(web_sound_input, ":") && !findtext(web_sound_input, html_protocol_regex))
				to_chat(src, "<span class='boldwarning'>Non-http(s) URIs are not allowed.</span>")
				to_chat(src, "<span class='warning'>For youtube-dl shortcuts like ytsearch: please use the appropriate full url from the website.</span>")
				return
			var/shell_scrubbed_input = shell_url_scrub(web_sound_input)
			var/list/output = world.shelleo("[config.invoke_youtubedl] --format \"bestaudio\[ext=mp3]/best\[ext=mp4]\[height<=360]/bestaudio\[ext=m4a]/bestaudio\[ext=aac]\" --get-url \"[shell_scrubbed_input]\"")
			var/errorlevel = output[SHELLEO_ERRORLEVEL]
			var/stdout = output[SHELLEO_STDOUT]
			var/stderr = output[SHELLEO_STDERR]
			if(!errorlevel)
				var/static/regex/content_url_regex = regex("https?://\\S+")
				if(content_url_regex.Find(stdout))
					web_sound_url = content_url_regex.match

					if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
						pitch = pick(0.5, 0.7, 0.8, 0.85, 0.9, 0.95, 1.1, 1.2, 1.4, 1.6, 2.0, 2.5)
						to_chat(src, "You feel the Honkmother messing with your song...")

					log_admin("[key_name(src)] played web sound: [web_sound_input]")
					message_admins("[key_name(src)] played web sound: [web_sound_input]")
			else
				to_chat(src, "<span class='boldwarning'>Youtube-dl URL retrieval FAILED:</span>")
				to_chat(src, "<span class='warning'>[stderr]</span>")

		else //pressed ok with blank
			log_admin("[key_name(src)] stopped web sound")
			message_admins("[key_name(src)] stopped web sound")
			web_sound_url = " "

		if(web_sound_url)
			for(var/m in GLOB.player_list)
				var/mob/M = m
				var/client/C = M.client
				if((C.prefs.toggles & SOUND_MIDI) && C.chatOutput && !C.chatOutput.broken && C.chatOutput.loaded)
					C.chatOutput.sendMusic(web_sound_url, pitch)

	SSblackbox.add_details("admin_verb","Play Internet Sound")

/client/proc/set_round_end_sound(S as sound)
	set category = "Fun"
	set name = "Set Round End Sound"
	if(!check_rights(R_SOUNDS))
		return

	SSticker.SetRoundEndSound(S)

	log_admin("[key_name(src)] set the round end sound to [S]")
	message_admins("[key_name_admin(src)] set the round end sound to [S]")
	SSblackbox.add_details("admin_verb","Set Round End Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

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
				C.chatOutput.sendMusic(" ")
	SSblackbox.add_details("admin_verb","Stop All Playing Sounds") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
