SUBSYSTEM_DEF(autosandbox)
	name = "Autosandbox"
	wait = 5 SECONDS
	flags = SS_NO_INIT | SS_BACKGROUND
	runlevels = RUNLEVEL_LOBBY

/datum/controller/subsystem/autosandbox/fire(resumed)
	if(SSticker.GetTimeLeft() <= 30 SECONDS)
		SSautosandbox.can_fire = FALSE
		if(CONFIG_GET(flag/autosandbox_enabled))

			//check for present admins
			var/active_admins = 0
			for(var/client/C in GLOB.admins)
				if(!C.is_afk() && check_rights_for(C, R_ADMIN))
					active_admins = 1
					break

			//shift down to sandbox
			if(GLOB.master_mode == "secret" && SSticker.totalPlayers <= CONFIG_GET(number/autosandbox_min))
				SEND_SOUND(world, sound('sound/misc/notice2.ogg'))
				if(!active_admins)
					to_chat(world, "<span class='boldnotice'>Notice: Insufficient player population for secret, switching from secret to sandbox and enabling respawn.</span>")
					SSticker.save_mode("sandbox")
					GLOB.master_mode = "sandbox"
				else
					to_chat(world, "<span class='boldnotice'>Notice: The current player count is below the sandbox threshold, but the game mode will not be changed because an admin is online.</span>")
					message_admins("The player count is below the auto sandbox population threshold, but there are active admins, so the game mode has not changed. If you wish, you may change the game mode to sandbox.")

			//shift up to secret
			else if(GLOB.master_mode == "sandbox" && SSticker.totalPlayers >= CONFIG_GET(number/autosandbox_max))
				SEND_SOUND(world, sound('sound/misc/notice2.ogg'))
				if(!active_admins)
					to_chat(world, "<span class='boldnotice'>Notice: Player population is now sufficient for secret, switching from sandbox to secret.</span>")
					SSticker.save_mode("secret")
					GLOB.master_mode = "secret"
				else
					to_chat(world, "<span class='boldnotice'>Notice: The current player count is meets the secret threshold, but the game mode will not be changed because an admin is online.</span>")
					message_admins("The player count meets the auto secret population threshold, but there are active admins, so the game mode has not changed. If you wish, you may change the game mode to secret.")
					
			if(GLOB.master_mode == "sandbox")
				CONFIG_SET(flag/norespawn, FALSE)
				world.update_status()
				message_admins("Respawn has been automatically enabled due to the mode being sandbox.")
