/mob/Login()
	player_list |= src
	lastKnownIP	= client.address
	computer_id	= client.computer_id
	log_access("Mob Login: [key_name(src)] was assigned to a [type]")
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