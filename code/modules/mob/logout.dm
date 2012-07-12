/mob/Logout()
	log_access("Logout: [key_name(src)]")
	if (admins[src.ckey])
		if (ticker && ticker.current_state == GAME_STATE_PLAYING) //Only report this stuff if we are currently playing.
			var/admins_number = 0
			for(var/client/C)
				if(C.holder)
					admins_number++

			message_admins("Admin logout: [key_name(src)]")
			if(admins_number == 0) //Apparently the admin logging out is no longer an admin at this point, so we have to check this towards 0 and not towards 1. Awell.
				send2irc("Server", "I have no admins online!")
	..()

	return 1