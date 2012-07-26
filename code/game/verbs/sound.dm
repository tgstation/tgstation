/mob/verb/togglemidis()
	set category = "Special Verbs"
	set name = "Toggle Midis"
	set desc = "This will prevent further admin midis from playing, as well as cut off the current one."

	if(istype(usr,/mob))
		var/mob/M = usr

		if(M.client)
			M.client.midis = !M.client.midis
			if(!M.client.midis)
				M << sound(null, 0, 0, 777) // breaks the client's sound output on channel 777

			M << "You will now [M.client.midis? "start":"stop"] receiving any sounds uploaded by admins[M.client.midis? "":", and any current midis playing have been disabled"]."
		return



/mob/verb/toggletitlemusic()
	set category = "Special Verbs"
	set name = "Toggle Pregame Music"
	set desc = "Stops the pregame lobby music from playing."

	if(istype(usr,/mob/new_player))
		var/mob/M = usr

		if(M.client)
			M << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // stop the jamsz

		return
