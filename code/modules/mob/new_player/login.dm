/mob/new_player/Login()
	update_Login_details()	//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
	if (join_motd)
		src << "<div class=\"motd\">[join_motd]</div>"

	if(!preferences)
		preferences = new

	if(!mind)
		mind = new /datum/mind(key)
		mind.active = 1
		mind.current = src

	spawn() Playmusic() // git some tunes up in heeyaa~

	var/starting_loc = pick(newplayer_start)
	if(!starting_loc)	starting_loc = locate(1,1,1)
	loc = starting_loc
	lastarea = starting_loc

	sight |= SEE_TURFS
	player_list |= src

	var/list/watch_locations = list()
	for(var/obj/effect/landmark/landmark in world)
		if(landmark.tag == "landmark*new_player")
			watch_locations += landmark.loc

	if(watch_locations.len>0)
		loc = pick(watch_locations)



	spawn(60)
		if(client)
			if(!preferences.savefile_load(src, 0))
				preferences.ShowChoices(src)
				if(!client.changes)
					changes()
			else
				if(client.activeslot != preferences.default_slot)//Loads default slot
					client.activeslot = preferences.default_slot
					preferences.savefile_load(src)
				var/lastchangelog = length('changelog.html')
				if(!client.changes && preferences.lastchangelog!=lastchangelog)
					changes()
					preferences.lastchangelog = lastchangelog
					preferences.savefile_save(src)
			handle_privacy_poll()
			new_player_panel()
	//PDA Resource Initialisation =======================================================>
	/*
	Quick note: local dream daemon instances don't seem to cache images right. Might be
	a local problem with my machine but it's annoying nontheless.
	*/
	if(client)
		//load the PDA iconset into the client
		src << browse_rsc('pda_atmos.png')
		src << browse_rsc('pda_back.png')
		src << browse_rsc('pda_bell.png')
		src << browse_rsc('pda_blank.png')
		src << browse_rsc('pda_boom.png')
		src << browse_rsc('pda_bucket.png')
		src << browse_rsc('pda_crate.png')
		src << browse_rsc('pda_cuffs.png')
		src << browse_rsc('pda_eject.png')
		src << browse_rsc('pda_exit.png')
		src << browse_rsc('pda_flashlight.png')
		src << browse_rsc('pda_honk.png')
		src << browse_rsc('pda_mail.png')
		src << browse_rsc('pda_medical.png')
		src << browse_rsc('pda_menu.png')
		src << browse_rsc('pda_mule.png')
		src << browse_rsc('pda_notes.png')
		src << browse_rsc('pda_power.png')
		src << browse_rsc('pda_rdoor.png')
		src << browse_rsc('pda_reagent.png')
		src << browse_rsc('pda_refresh.png')
		src << browse_rsc('pda_scanner.png')
		src << browse_rsc('pda_signaler.png')
		src << browse_rsc('pda_status.png')
		//Loads icons for SpiderOS into client
		src << browse_rsc('sos_1.png')
		src << browse_rsc('sos_2.png')
		src << browse_rsc('sos_3.png')
		src << browse_rsc('sos_4.png')
		src << browse_rsc('sos_5.png')
		src << browse_rsc('sos_6.png')
		src << browse_rsc('sos_7.png')
		src << browse_rsc('sos_8.png')
		src << browse_rsc('sos_9.png')
		src << browse_rsc('sos_10.png')
		src << browse_rsc('sos_11.png')
		src << browse_rsc('sos_12.png')
		src << browse_rsc('sos_13.png')
		src << browse_rsc('sos_14.png')
	//End PDA Resource Initialisation =====================================================>