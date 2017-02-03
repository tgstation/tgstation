//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
/mob/proc/update_Login_details()
	//Multikey checks and logging
	lastKnownIP	= client.address
	computer_id	= client.computer_id
	log_access("Login: [key_name(src)] from [lastKnownIP ? lastKnownIP : "localhost"]-[computer_id] || BYOND v[client.byond_version]")
	if(config.log_access)
		for(var/mob/M in player_list)
			if(M == src)
				continue
			if( M.key && (M.key != key) )
				var/matches
				if( (M.lastKnownIP == client.address) )
					matches += "IP ([client.address])"
				if( (M.computer_id == client.computer_id) )
					if(matches)
						matches += " and "
					matches += "ID ([client.computer_id])"
					spawn() alert("You have logged in already with another key this round, please log out of this one NOW or risk being banned!")
				if(matches)
					if(M.client)
						message_admins("<font color='red'><B>Notice: </B><font color='blue'>[key_name_admin(src)] has the same [matches] as [key_name_admin(M)].</font>")
						log_access("Notice: [key_name(src)] has the same [matches] as [key_name(M)].")
					else
						message_admins("<font color='red'><B>Notice: </B><font color='blue'>[key_name_admin(src)] has the same [matches] as [key_name_admin(M)] (no longer logged in). </font>")
						log_access("Notice: [key_name(src)] has the same [matches] as [key_name(M)] (no longer logged in).")

/mob/Login()
	player_list |= src
	update_Login_details()
	world.update_status()
	client.screen = list()				//remove hud items just in case
	client.images = list()

	if(!hud_used)
		create_mob_hud()
	if(hud_used)
		hud_used.show_hud(hud_used.hud_version)

	next_move = 1

	..()
	if (key != client.key)
		key = client.key
	reset_perspective(loc)

	if(isobj(loc))
		var/obj/Loc=loc
		Loc.on_log()

	//readd this mob's HUDs (antag, med, etc)
	reload_huds()

	reload_fullscreen() // Reload any fullscreen overlays this mob has.

	if(ckey in deadmins)
		verbs += /client/proc/readmin

	add_click_catcher()

	sync_mind()

	client.sethotkeys() //set mob specific hotkeys

	if(viewing_alternate_appearances && viewing_alternate_appearances.len)
		for(var/aakey in viewing_alternate_appearances)
			for(var/aa in viewing_alternate_appearances[aakey])
				var/datum/alternate_appearance/AA = aa
				AA.display_to(list(src))

	update_client_colour()
	if(client)
		client.click_intercept = null
		client.view = world.view // Resets the client.view in case it was changed.