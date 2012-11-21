/client/verb/togglemidis()
	set category = "Special Verbs"
	set name = "Toggle Midis"
	set desc = "This will prevent further admin midis from playing, as well as cut off the current one."
	prefs.toggles ^= SOUND_MIDI
	prefs.save_preferences()
	if(prefs.toggles & SOUND_MIDI)
		src << "You will now hear any sounds uploaded by admins."
		var/sound/break_sound = sound(null, repeat = 0, wait = 0, channel = 777)
		break_sound.priority = 250
		src << break_sound	//breaks the client's sound output on channel 777
	else
		src << "You will no longer hear sounds uploaded by admins; any currently playing midis have been disabled."


/client/verb/toggletitlemusic()
	set category = "Special Verbs"
	set name = "Toggle Pregame Music"
	set desc = "Stops the pregame lobby music from playing."
	prefs.toggles ^= SOUND_LOBBY
	prefs.save_preferences()
	if(prefs.toggles & SOUND_LOBBY)
		src << "You will now hear music in the game lobby."
		if(istype(mob, /mob/new_player))
			playtitlemusic()
	else
		src << "You will no longer hear music in the game lobby."
		if(istype(mob, /mob/new_player))
			src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // stop the jamsz

/client/proc/playtitlemusic()
	if(!ticker || !ticker.login_music)	return
	if(prefs.toggles & SOUND_LOBBY)
		src << sound(ticker.login_music, repeat = 0, wait = 0, volume = 85, channel = 1) // MAD JAMS