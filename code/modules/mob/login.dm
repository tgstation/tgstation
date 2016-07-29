<<<<<<< HEAD
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
	client.click_intercept = null
=======
//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
/mob/proc/update_Login_details()
	//Multikey checks and logging
	lastKnownIP	= client.address
	computer_id	= client.computer_id
	log_access("Login: [key_name(src)] from [lastKnownIP ? lastKnownIP : "localhost"]-[computer_id] || BYOND v[client.byond_version]")
	if(config.log_access)
		for(var/mob/M in player_list)
			if(M == src)	continue
			if( M.key && (M.key != key) )
				var/matches
				if( (M.lastKnownIP == client.address) )
					matches += "IP ([client.address])"
				if( (M.computer_id == client.computer_id) )
					if(matches)	matches += " and "
					matches += "ID ([client.computer_id])"
					spawn() alert("You have logged in already with another key this round, please log out of this one NOW or risk being banned!")
				if(matches)
					if(M.client)
						message_admins("<font color='red'><B>Notice: </B><font color='blue'><A href='?src=\ref[usr];priv_msg=\ref[src]'>[key_name_admin(src)]</A> has the same [matches] as <A href='?src=\ref[usr];priv_msg=\ref[M]'>[key_name_admin(M)]</A>.</font>", 1)
						log_access("Notice: [key_name(src)] has the same [matches] as [key_name(M)].")
					else
						message_admins("<font color='red'><B>Notice: </B><font color='blue'><A href='?src=\ref[usr];priv_msg=\ref[src]'>[key_name_admin(src)]</A> has the same [matches] as [key_name_admin(M)] (no longer logged in). </font>", 1)
						log_access("Notice: [key_name(src)] has the same [matches] as [key_name(M)] (no longer logged in).")

/mob/Login()
	player_list |= src
	update_Login_details()
	world.update_status()

	if(hud_used)	qdel(hud_used)		//remove the hud objects
	client.images = null				//remove the images such as AIs being unable to see runes

	if(spell_masters)
		for(var/obj/screen/movable/spell_master/spell_master in spell_masters)
			spell_master.toggle_open(1)
			client.screen -= spell_master

	client.reset_screen()				//remove hud items just in case
	hud_used = new /datum/hud(src)
	gui_icons = new /datum/ui_icons(src)
	client.screen += catcher //Catcher of clicks

	if(round_end_info == "")
		winset(client, "rpane.round_end", "is-visible=false")

	delayNextMove(0)

	sight |= SEE_SELF

	..()

	reset_view()

	if(flags & HEAR && !(flags & HEAR_ALWAYS)) //Mobs with HEAR_ALWAYS will already have a virtualhearer
		getFromPool(/mob/virtualhearer, src)

	//Clear ability list and update from mob.
	client.verbs -= ability_verbs

	if(abilities)
		client.verbs |= abilities

	if(istype(src,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		if(H.species && H.species.abilities)
			H.verbs |= H.species.abilities

	if(client)
		if(ckey in deadmins)
			client.verbs += /client/proc/readmin

		if(M_FARSIGHT in mutations)
			client.view = max(client.view, world.view+1)
	CallHook("Login", list("client" = src.client, "mob" = src))

	if(spell_masters)
		for(var/obj/screen/movable/spell_master/spell_master in spell_masters)
			client.screen += spell_master
			spell_master.toggle_open(1)

	if (isobj(loc))
		var/obj/location = loc
		location.on_log()

	if(client && client.haszoomed && !client.holder)
		client.view = world.view
		client.haszoomed = 0

	if(bad_changing_colour_ckeys["[client.ckey]"] == 1)
		client.updating_colour = 0
		bad_changing_colour_ckeys["[client.ckey]"] = 0
	update_colour()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
