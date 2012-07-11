/mob/Logout()
	log_access("Logout: [key_name(src)]")
	if (admins[src.ckey])
		if (ticker && ticker.current_state == GAME_STATE_PLAYING) //Only report this stuff if we are currently playing.
			var/admins_number = 0
			for(var/client/C)
				if(C.holder)
					admins_number++

			message_admins("Admin logout: [key_name(src)]")
			if(admins_number == 1) //Since this admin has not logged out yet, they are still counted, if the number of admins is 1 it means that after this one logs out, it will be 0.
				send2irc("Server", "I have no admins online!")
	..()

	return 1