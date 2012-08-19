//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:05

/mob/new_player
	var/datum/preferences/preferences = null
	var/ready = 0
	var/spawning = 0//Referenced when you want to delete the new_player later on in the code.
	var/totalPlayers = 0		 //Player counts for the Lobby tab
	var/totalPlayersReady = 0

	invisibility = 101

	density = 0
	stat = 2
	canmove = 0

	anchored = 1	//  don't get pushed around

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
				if(isnull(observer))
					CRASH("An observer mob could not be created. ( null after var/mob/dead/observer/observer = new() )")

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
				observer.timeofdeath = world.time //So you can't just observe than respawn

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
					G.fields["rank"] = H.mind.role_alt_title ? H.mind.role_alt_title : H.mind.assigned_role
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

			var/minor_dis = null
			if(H.disabilities)
				if(H.disabilities & 1)
					minor_dis += "Myopia, "
				if(H.disabilities & 4)
					minor_dis += "Persistant Cough, "
				if(H.disabilities & 16)
					minor_dis += "Stuttering, "
			if(minor_dis)
				M.fields["mi_dis"] = minor_dis
			else
				M.fields["mi_dis"] = "None"

			M.fields["mi_dis_d"] = "No additional minor disability notes."

			var/major_dis = null
			if(H.disabilities)
				if(H.disabilities & 2)
					major_dis += "Epilepsy, "
				if(H.disabilities & 8)
					major_dis += "Tourette's Syndrome, "
				if(H.disabilities & 32)
					major_dis += "Deafness, "
			if(major_dis)
				M.fields["ma_dis"] = major_dis
			else
				M.fields["ma_dis"] = "None"

			M.fields["ma_dis_d"] = "No additional major disability notes."
			M.fields["alg"] = "None"
			M.fields["alg_d"] = "No additional allergy notes."
			M.fields["cdi"] = "None"
			M.fields["cdi_d"] = "No additional disease notes."

			if(H.med_record && !jobban_isbanned(H, "Records"))
				M.fields["notes"] = H.med_record
			else
				M.fields["notes"] = "No notes found."

			S.fields["criminal"] = "None"
			S.fields["mi_crim"] = "None"
			S.fields["mi_crim_d"] = "No minor crime convictions."
			S.fields["ma_crim"] = "None"
			S.fields["ma_crim_d"] = "No major crime convictions."

			if(H.sec_record && !jobban_isbanned(H, "Records"))
				S.fields["notes"] = H.sec_record
			else
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

		if(emergency_shuttle) //In case NanoTrasen decides reposess CentComm's shuttles.
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
			if((preferences.species == "Soghun") && ((is_alien_whitelisted(src, "Soghun")) || !config.usealienwhitelist)) //This probably shouldn't be here, but I can't think of any other way
				new_character.mutantrace = "lizard"
				new_character.soghun_talk_understand = 1
				new_character.voice_name = "Soghun"
			if((preferences.species == "Skrell") && ((is_alien_whitelisted(src, "Skrell")) || !config.usealienwhitelist))
				new_character.mutantrace = "skrell"
				new_character.skrell_talk_understand = 1
				new_character.voice_name = "Skrell"
			new_character.update_clothing()
			new_character.update_body()
			new_character.update_face() //Hotfix for non-updating sprites.
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

	verb/ShowPreferences()
		set category = "OOC"
		preferences.ShowChoices(src)