<<<<<<< HEAD
/mob/Logout()
	SStgui.on_logout(src)
	unset_machine()
	player_list -= src
	log_access("Logout: [key_name(src)]")
	if(admin_datums[src.ckey])
		if (ticker && ticker.current_state == GAME_STATE_PLAYING) //Only report this stuff if we are currently playing.
			var/admins_number = admins.len
			if(admins_number == 0) //Apparently the admin logging out is no longer an admin at this point, so we have to check this towards 0 and not towards 1. Awell.
				var/cheesy_message = pick( list(  \
					"I have no admins online!",\
					"I'm all alone :(",\
					"I'm feeling lonely :(",\
					"I'm so lonely :(",\
					"Why does nobody love me? :(",\
					"I want a man :(",\
					"Where has everyone gone?",\
					"I need a hug :(",\
					"Someone come hold me :(",\
					"I need someone on me :(",\
					"What happened? Where has everyone gone?",\
					"Forever alone :("\
				) )

				if(cheesy_message)
					cheesy_message += " (No admins online)"


				send2irc("Server", "[cheesy_message]")
	..()

	if(isobj(loc))
		var/obj/Loc=loc
		Loc.on_log()

	return 1
=======
/mob/Logout()
	if (isobj(loc))
		var/obj/location = loc
		location.on_log()

	if(!(flags & HEAR_ALWAYS))
		for(var/mob/virtualhearer/VH in virtualhearers)
			if(VH.attached == src)
				returnToPool(VH)

	remove_spell_channeling() //remove spell channeling before we log out

	nanomanager.user_logout(src) // this is used to clean up (remove) this user's Nano UIs

	player_list -= src

	log_access("Logout: [key_name(src)] ([formatLocation(loc)])")

	remove_screen_objs() //Used to remove hud elements

	if(admin_datums[src.ckey])
		if (ticker && ticker.current_state == GAME_STATE_PLAYING) //Only report this stuff if we are currently playing.
			var/admins_number = admins.len

			message_admins("Admin logout: [key_name(src)]")
			if(admins_number == 0) //Apparently the admin logging out is no longer an admin at this point, so we have to check this towards 0 and not towards 1. Awell.
				send2adminirc("[key_name(src)] logged out - no more admins online.")

	INVOKE_EVENT(on_logout, list())

	..()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
