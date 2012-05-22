/mob/new_player
	var
		datum/preferences/preferences = null
		ready = 0
		spawning = 0//Referenced when you want to delete the new_player later on in the code.
		totalPlayers = 0		 //Player counts for the Lobby tab
		totalPlayersReady = 0

	invisibility = 101

	density = 0
	stat = 2
	canmove = 0

	anchored = 1	//  don't get pushed around

	Login()
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


	Logout()
		ready = 0
		..()
		if(!spawning)//Here so that if they are spawning and log out, the other procs can play out and they will have a mob to come back to.
			key = null//We null their key before deleting the mob, so they are properly kicked out.
			del(src)
		return

	verb/new_player_panel()
		set src = usr
		new_player_panel_proc()


	proc/new_player_panel_proc()
		var/output = "<B>New Player Options</B>"
		output +="<hr>"
		output += "<br><a href='byond://?src=\ref[src];show_preferences=1'>Setup Character</A><BR><BR>"

		if(!ticker || ticker.current_state <= GAME_STATE_PREGAME)
			if(!ready)	output += "<a href='byond://?src=\ref[src];ready=1'>Declare Ready</A><BR>"
			else	output += "<b>You are ready</b> (<a href='byond://?src=\ref[src];ready=2'>Cancel</A>)<BR>"

		else
			output += "<a href='byond://?src=\ref[src];manifest=1'>View the Crew Manifest</A><BR><BR>"
			output += "<a href='byond://?src=\ref[src];late_join=1'>Join Game!</A><BR>"

		output += "<BR><a href='byond://?src=\ref[src];observe=1'>Observe</A><BR>"

		output += "<BR><a href='byond://?src=\ref[src];pregame_music=1'>Lobby Music</A><BR>"

		src << browse(output,"window=playersetup;size=250x258;can_close=0")
		return

	proc/Playmusic()
		while(!ticker) // wait for ticker to be created
			sleep(1)

		var/waits = 0
		var/maxwaits = 100
		while(!ticker.login_music)
			sleep(2)

			waits++ // prevents DDoSing the server via badminery
			if(waits >= maxwaits)
				break

		src << sound(ticker.login_music, repeat = 0, wait = 0, volume = 85, channel = 1) // MAD JAMS

	proc/Stopmusic()
		src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // stop the jamsz

	Stat()
		..()

		statpanel("Lobby")
		if(client.statpanel=="Lobby" && ticker)
			if(ticker.hide_mode)
				stat("Game Mode:", "Secret")
			else
				stat("Game Mode:", "[master_mode]")

			if((ticker.current_state == GAME_STATE_PREGAME) && going)
				stat("Time To Start:", ticker.pregame_timeleft)
			if((ticker.current_state == GAME_STATE_PREGAME) && !going)
				stat("Time To Start:", "DELAYED")

			if(ticker.current_state == GAME_STATE_PREGAME)
				stat("Players: [totalPlayers]", "Players Ready: [totalPlayersReady]")
				totalPlayers = 0
				totalPlayersReady = 0
				for(var/mob/new_player/player in world)
					stat("[player.key]", (player.ready)?("(Playing)"):(null))
					totalPlayers++
					if(player.ready)totalPlayersReady++

	Topic(href, href_list[])
		if(!client)	return 0

		if(href_list["show_preferences"])
			preferences.ShowChoices(src)
			return 1

		if(href_list["ready"])
			if(!ready)
				ready = 1
			else
				ready = 0

		if(href_list["refresh"])
			src << browse(null, "window=playersetup") //closes the player setup window
			new_player_panel_proc()

		if(href_list["observe"])

			if(alert(src,"Are you sure you wish to observe? You will not be able to play this round!","Player Setup","Yes","No") == "Yes")
				var/mob/dead/observer/observer = new()

				spawning = 1
				src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // MAD JAMS cant last forever yo

				close_spawn_windows()
				var/obj/O = locate("landmark*Observer-Start")
				src << "\blue Now teleporting."
				observer.loc = O.loc
				observer.key = key
				if(preferences.be_random_name)
					preferences.randomize_name()
				observer.name = preferences.real_name
				observer.real_name = observer.name
				observer.original_name = observer.name //Original name is only used in ghost chat! It is not to be edited by anything!

				preferences.copy_to_observer(observer)

				del(src)
				return 1

		if(href_list["pregame_music"])
			preferences.pregame_music = !preferences.pregame_music
			if(preferences.pregame_music)
				Playmusic()
			else
				Stopmusic()
			// only save this 1 pref, so current slot doesn't get saved w/o user's knowledge
			var/savefile/F = new(preferences.savefile_path(src))
			F["pregame_music"] << preferences.pregame_music

		if(href_list["late_join"])
			LateChoices()

		if(href_list["manifest"])
			ViewManifest()

		if(href_list["SelectedJob"])

			if(!enter_allowed)
				usr << "\blue There is an administrative lock on entering the game!"
				return

			AttemptLateSpawn(href_list["SelectedJob"])
			return

		if(!ready && href_list["preferences"])
			preferences.process_link(src, href_list)
		else if(!href_list["late_join"])
			new_player_panel()

		if(href_list["priv_msg"])
			..()	//pass PM calls along to /mob/Topic
			return

	proc/IsJobAvailable(rank)
		var/datum/job/job = job_master.GetJob(rank)
		if(!job)	return 0
		if((job.current_positions >= job.total_positions) && job.total_positions != -1)	return 0
		if(jobban_isbanned(src,rank))	return 0
		return 1


	proc/AttemptLateSpawn(rank)
		if(!IsJobAvailable(rank))
			src << alert("[rank] is not available. Please try another.")
			return 0

		job_master.AssignRole(src, rank, 1)
		var/mob/living/carbon/human/character = create_character()
		var/icon/char_icon = getFlatIcon(character,0)//We're creating out own cache so it's not needed.
		job_master.EquipRank(character, rank, 1)
		EquipCustomItems(character)
		character.loc = pick(latejoin)
		character.lastarea = get_area(loc)
		if(character.client)
			character.client.be_syndicate = preferences.be_special
		ticker.mode.latespawn(character)
		AnnounceArrival(character, rank)

		if(character.mind.assigned_role != "Cyborg")
			ManifestLateSpawn(character,char_icon)
			ticker.minds += character.mind//Cyborgs and AIs handle this in the transform proc.
		else
			character.Robotize()
		del(src)


	proc/AnnounceArrival(var/mob/living/carbon/human/character, var/rank)
		if (ticker.current_state == GAME_STATE_PLAYING)
			var/obj/item/device/radio/intercom/a = new /obj/item/device/radio/intercom(null)
			a.autosay("\"[character.real_name],[character.wear_id.assignment ? " [character.wear_id.assignment]," : "" ] has arrived on the station.\"", "Arrivals Announcement Computer")
			del(a)


	proc/ManifestLateSpawn(var/mob/living/carbon/human/H, icon/H_icon) // Attempted fix to add late joiners to various databases -- TLE
		// This is basically ripped wholesale from the normal code for adding people to the databases during a fresh round
		if (!isnull(H.mind) && (H.mind.assigned_role != "MODE"))
			var/datum/data/record/G = new()
			var/datum/data/record/M = new()
			var/datum/data/record/S = new()
			var/datum/data/record/L = new()
			var/obj/item/weapon/card/id/C = H.wear_id
			if (C)
				G.fields["rank"] = C.assignment
				G.fields["real_rank"] = H.mind.assigned_role
			else
				if(H.mind && H.mind.assigned_role)
					G.fields["rank"] = H.mind.assigned_role
					G.fields["real_rank"] = H.mind.assigned_role
				else
					G.fields["rank"] = "Unassigned"
					G.fields["real_rank"] = G.fields["rank"]
			G.fields["name"] = H.real_name
			G.fields["id"] = text("[]", add_zero(num2hex(rand(1, 1.6777215E7)), 6))
			M.fields["name"] = G.fields["name"]
			M.fields["id"] = G.fields["id"]
			S.fields["name"] = G.fields["name"]
			S.fields["id"] = G.fields["id"]
			if(H.gender == FEMALE)
				G.fields["sex"] = "Female"
			else
				G.fields["sex"] = "Male"
			G.fields["age"] = text("[]", H.age)
			G.fields["fingerprint"] = text("[]", md5(H.dna.uni_identity))
			G.fields["p_stat"] = "Active"
			G.fields["m_stat"] = "Stable"
			M.fields["b_type"] = text("[]", H.dna.b_type)
			M.fields["b_dna"] = H.dna.unique_enzymes
			M.fields["mi_dis"] = "None"
			M.fields["mi_dis_d"] = "No minor disabilities have been declared."
			M.fields["ma_dis"] = "None"
			M.fields["ma_dis_d"] = "No major disabilities have been diagnosed."
			M.fields["alg"] = "None"
			M.fields["alg_d"] = "No allergies have been detected in this patient."
			M.fields["cdi"] = "None"
			M.fields["cdi_d"] = "No diseases have been diagnosed at the moment."
			M.fields["notes"] = "No notes."
			S.fields["criminal"] = "None"
			S.fields["mi_crim"] = "None"
			S.fields["mi_crim_d"] = "No minor crime convictions."
			S.fields["ma_crim"] = "None"
			S.fields["ma_crim_d"] = "No major crime convictions."
			S.fields["notes"] = "No notes."

			//Begin locked reporting
			L.fields["name"] = H.real_name
			L.fields["sex"] = H.gender
			L.fields["age"] = H.age
			L.fields["id"] = md5("[H.real_name][H.mind.assigned_role]")
			L.fields["rank"] = H.mind.role_alt_title ? H.mind.role_alt_title : H.mind.assigned_role
			L.fields["real_rank"] = H.mind.assigned_role
			L.fields["b_type"] = H.dna.b_type
			L.fields["b_dna"] = H.dna.unique_enzymes
			L.fields["enzymes"] = H.dna.struc_enzymes
			L.fields["identity"] = H.dna.uni_identity
			L.fields["image"] = H_icon//What the person looks like. Naked, in this case.
			//End locked reporting

			data_core.general += G
			data_core.medical += M
			data_core.security += S
			data_core.locked += L
		return


	proc/LateChoices()
		var/mills = world.time // 1/10 of a second, not real milliseconds but whatever
		//var/secs = ((mills % 36000) % 600) / 10 //Not really needed, but I'll leave it here for refrence.. or something
		var/mins = (mills % 36000) / 600
		var/hours = mills / 36000

		var/dat = "<html><body><center>"
		dat += "Round Duration: [round(hours)]h [round(mins)]m<br>"

		if(emergency_shuttle) //In case Nanotrasen decides reposess CentComm's shuttles.
			if(emergency_shuttle.direction == 2) //Shuttle is going to centcomm, not recalled
				dat += "<font color='red'><b>The station has been evacuated.</b></font><br>"
			if(emergency_shuttle.direction == 1 && emergency_shuttle.timeleft() < 300) //Shuttle is past the point of no recall
				dat += "<font color='red'>The station is currently undergoing evacuation procedures.</font><br>"

		dat += "Choose from the following open positions:<br>"
		for(var/datum/job/job in job_master.occupations)
			if(job && IsJobAvailable(job.title))
				dat += "<a href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title]</a><br>"

		dat += "</center>"
		src << browse(dat, "window=latechoices;size=300x640;can_close=1")


	proc/create_character()
		spawning = 1
		var/mob/living/carbon/human/new_character //	var/path/to/object/varname
		if((preferences.species == "Tajaran") && (is_alien_whitelisted(src, "Tajaran")))
			new_character = new /mob/living/carbon/human/tajaran(loc)	//	varname = new /path/to/object(location_to_spawn_at)
		else
			new_character = new /mob/living/carbon/human(loc)
		new_character.lastarea = get_area(loc)

		close_spawn_windows()

		if(ticker.random_players)
			new_character.gender = pick(MALE, MALE, FEMALE)
			preferences.randomize_name()
			preferences.randomize_appearance_for(new_character)
		else
			preferences.copy_to(new_character)
			if((preferences.species == "Soghun") && (is_alien_whitelisted(src, "Soghun"))) //This probably shouldn't be here, but I can't think of any other way
				new_character.mutantrace = "lizard"
		src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1)

		new_character.dna.ready_dna(new_character)
		preferences.copydisabilities(new_character)
		if(mind)
			mind.transfer_to(new_character)
			mind.original = new_character

		return new_character

	proc/ViewManifest()
		var/dat = "<html><body>"
		dat += "<h4>Crew Manifest</h4>"
		dat += data_core.get_manifest()

		src << browse(dat, "window=manifest;size=300x420;can_close=1")

	Move()
		return 0


	proc/close_spawn_windows()
		src << browse(null, "window=latechoices") //closes late choices window
		src << browse(null, "window=playersetup") //closes the player setup window
