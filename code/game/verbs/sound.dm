/client/verb/togglemidis()
	set category = "Special Verbs"
	set name = "Toggle Midis"
	set desc = "This will prevent further admin midis from playing, as well as cut off the current one."

	midis = !midis
	if(!midis)
		var/sound/break_sound = sound(null, repeat = 0, wait = 0, channel = 777)
		break_sound.priority = 250
		src << break_sound	//breaks the client's sound output on channel 777

	src << "You will now [midis? "start":"stop"] receiving any sounds uploaded by admins[midis? "":", and any current midis playing have been disabled"]."


/mob/verb/toggletitlemusic()
	set category = "Special Verbs"
	set name = "Toggle Pregame Music"
	set desc = "Stops the pregame lobby music from playing."

	if(istype(usr,/mob/new_player))
		var/mob/M = usr

		if(M.client)
			M << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // stop the jamsz

		return
