/mob/new_player/Login()
	update_Login_details()	//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
	if (join_motd)
		src << "<div class=\"motd\">[join_motd]</div>"

	if(!preferences)
		preferences = new

	if(!mind)
		mind = new
		mind.key = key
		mind.current = src

	var/starting_loc = pick(newplayer_start)
	if(!starting_loc)	starting_loc = locate(1,1,1)
	loc = starting_loc
	lastarea = starting_loc

	sight |= SEE_TURFS

	var/list/watch_locations = list()
	for(var/obj/effect/landmark/landmark in world)
		if(landmark.tag == "landmark*new_player")
			watch_locations += landmark.loc

	if(watch_locations.len>0)
		loc = pick(watch_locations)

	if(!preferences.savefile_load(src, 1))
		preferences.ShowChoices(src)
		if(!client.changes)
			changes()
	else
		var/lastchangelog = length('changelog.html')
		if(!client.changes && preferences.lastchangelog!=lastchangelog)
			changes()
			preferences.lastchangelog = lastchangelog
			preferences.savefile_save(src, 1)

	if(preferences.pregame_music)
		spawn() Playmusic() // git some tunes up in heeyaa~

	if(client.has_news())
		src << "<b><font color=blue>There are some unread <a href='?src=\ref[news_topic_handler];client=\ref[client];action=show_news'>news</a> for you! Please make sure to read all news, as they may contain important updates about roleplay rules or canon.</font></b>"

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