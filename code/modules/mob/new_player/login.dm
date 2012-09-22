/mob/new_player/Login()
	update_Login_details()	//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
	if (join_motd)
		src << "<div class=\"motd\">[join_motd]</div>"

	if(!preferences)
		preferences = new
		//cael - hackfix for a (minor) annoying loading bug
		//is there something with cases i'm missing here?
		if(preferences.species == "human")
			preferences.species = "Human"

	if(!mind)
		mind = new /datum/mind(key)
		mind.active = 1
		mind.current = src

	//spawn() Playmusic() // git some tunes up in heeyaa~

	var/starting_loc = pick(newplayer_start)
	if(!starting_loc)	starting_loc = locate(1,1,1)
	loc = starting_loc
	lastarea = starting_loc

	sight |= SEE_TURFS
	player_list |= src

	var/list/watch_locations = list()
	for(var/obj/effect/landmark/landmark in landmarks_list)
		if(landmark.tag == "landmark*new_player")
			watch_locations += landmark.loc

	if(watch_locations.len>0)
		loc = pick(watch_locations)



	spawn(30)
		if(client)
			if(!preferences.savefile_load(src, 0))
				preferences.ShowChoices(src)
				if(!client.changes)
					changes()
			else
				if(client.activeslot != preferences.default_slot)//Loads default slot
					client.activeslot = preferences.default_slot
					preferences.savefile_load(src)
				var/lastchangelog = length('html/changelog.html')
				if(!client.changes && preferences.lastchangelog!=lastchangelog)
					changes()
					preferences.lastchangelog = lastchangelog
					preferences.savefile_save(src)
			handle_privacy_poll()
			new_player_panel()
			if(preferences.lobby_music)
				Playmusic()
			//PDA Resource Initialisation =======================================================>
			/*
			Quick note: local dream daemon instances don't seem to cache images right. Might be
			a local problem with my machine but it's annoying nontheless.
			*/
			//load the PDA iconset into the client
			src << browse_rsc('icons/pda_icons/pda_atmos.png')
			src << browse_rsc('icons/pda_icons/pda_back.png')
			src << browse_rsc('icons/pda_icons/pda_bell.png')
			src << browse_rsc('icons/pda_icons/pda_blank.png')
			src << browse_rsc('icons/pda_icons/pda_boom.png')
			src << browse_rsc('icons/pda_icons/pda_bucket.png')
			src << browse_rsc('icons/pda_icons/pda_crate.png')
			src << browse_rsc('icons/pda_icons/pda_cuffs.png')
			src << browse_rsc('icons/pda_icons/pda_eject.png')
			src << browse_rsc('icons/pda_icons/pda_exit.png')
			src << browse_rsc('icons/pda_icons/pda_flashlight.png')
			src << browse_rsc('icons/pda_icons/pda_honk.png')
			src << browse_rsc('icons/pda_icons/pda_mail.png')
			src << browse_rsc('icons/pda_icons/pda_medical.png')
			src << browse_rsc('icons/pda_icons/pda_menu.png')
			src << browse_rsc('icons/pda_icons/pda_mule.png')
			src << browse_rsc('icons/pda_icons/pda_notes.png')
			src << browse_rsc('icons/pda_icons/pda_power.png')
			src << browse_rsc('icons/pda_icons/pda_rdoor.png')
			src << browse_rsc('icons/pda_icons/pda_reagent.png')
			src << browse_rsc('icons/pda_icons/pda_refresh.png')
			src << browse_rsc('icons/pda_icons/pda_scanner.png')
			src << browse_rsc('icons/pda_icons/pda_signaler.png')
			src << browse_rsc('icons/pda_icons/pda_status.png')
			//Loads icons for SpiderOS into client
			src << browse_rsc('icons/spideros_icons/sos_1.png')
			src << browse_rsc('icons/spideros_icons/sos_2.png')
			src << browse_rsc('icons/spideros_icons/sos_3.png')
			src << browse_rsc('icons/spideros_icons/sos_4.png')
			src << browse_rsc('icons/spideros_icons/sos_5.png')
			src << browse_rsc('icons/spideros_icons/sos_6.png')
			src << browse_rsc('icons/spideros_icons/sos_7.png')
			src << browse_rsc('icons/spideros_icons/sos_8.png')
			src << browse_rsc('icons/spideros_icons/sos_9.png')
			src << browse_rsc('icons/spideros_icons/sos_10.png')
			src << browse_rsc('icons/spideros_icons/sos_11.png')
			src << browse_rsc('icons/spideros_icons/sos_12.png')
			src << browse_rsc('icons/spideros_icons/sos_13.png')
			src << browse_rsc('icons/spideros_icons/sos_14.png')
	//End PDA Resource Initialisation =====================================================>