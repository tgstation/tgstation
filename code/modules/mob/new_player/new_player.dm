//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/mob/new_player
	var/ready = 0
	var/spawning = 0//Referenced when you want to delete the new_player later on in the code.
	var/totalPlayers = 0		 //Player counts for the Lobby tab
	var/totalPlayersReady = 0
	universal_speak = 1

	invisibility = 101

	density = 0
	stat = 2
	canmove = 0

	anchored = 1	//  don't get pushed around

	verb/new_player_panel()
		set src = usr
		new_player_panel_proc()


	proc/new_player_panel_proc()
		var/output = "<div align='center'><B>New Player Options</B>"

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\mob\new_player\new_player.dm:28: output +="<hr>"
		output += {"<hr>
			<p><a href='byond://?src=\ref[src];show_preferences=1'>Setup Character</A></p>"}
		// END AUTOFIX
		if(!ticker || ticker.current_state <= GAME_STATE_PREGAME)
			if(!ready)	output += "<p><a href='byond://?src=\ref[src];ready=1'>Declare Ready</A></p>"
			else	output += "<p><b>You are ready</b> (<a href='byond://?src=\ref[src];ready=2'>Cancel</A>)</p>"

		else

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\mob\new_player\new_player.dm:36: output += "<a href='byond://?src=\ref[src];manifest=1'>View the Crew Manifest</A><br><br>"
			output += {"<a href='byond://?src=\ref[src];manifest=1'>View the Crew Manifest</A><br><br>
				<p><a href='byond://?src=\ref[src];late_join=1'>Join Game!</A></p>"}
			// END AUTOFIX

		output += "<p><a href='byond://?src=\ref[src];observe=1'>Observe</A></p>"

		if(!IsGuestKey(src.key))
			establish_db_connection()

			if(dbcon.IsConnected())
				var/isadmin = 0
				if(src.client && src.client.holder)
					isadmin = 1
				var/DBQuery/query = dbcon.NewQuery("SELECT id FROM erro_poll_question WHERE [(isadmin ? "" : "adminonly = false AND")] Now() BETWEEN starttime AND endtime AND id NOT IN (SELECT pollid FROM erro_poll_vote WHERE ckey = \"[ckey]\") AND id NOT IN (SELECT pollid FROM erro_poll_textreply WHERE ckey = \"[ckey]\")")
				query.Execute()
				var/newpoll = 0
				while(query.NextRow())
					newpoll = 1
					break

				if(newpoll)
					output += "<p><b><a href='byond://?src=\ref[src];showpoll=1'>Show Player Polls</A> (NEW!)</b></p>"
				else
					output += "<p><a href='byond://?src=\ref[src];showpoll=1'>Show Player Polls</A></p>"

		output += "</div>"

		src << browse(output,"window=playersetup;size=210x240;can_close=0")
		return

	Stat()
		..()

		statpanel("Status")
		if (client.statpanel == "Status" && ticker)
			if (ticker.current_state != GAME_STATE_PREGAME)
				stat(null, "Station Time: [worldtime2text()]")
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
				for(var/mob/new_player/player in player_list)
					stat("[player.key]", (player.ready)?("(Playing)"):(null))
					totalPlayers++
					if(player.ready)totalPlayersReady++

	Topic(href, href_list[])
		if(usr != src)
			return 0

		if(!client)	return 0

		if(href_list["show_preferences"])
			client.prefs.ShowChoices(src)
			return 1

		if(href_list["ready"])
			ready = !ready

		if(href_list["refresh"])
			src << browse(null, "window=playersetup") //closes the player setup window
			new_player_panel_proc()

		if(href_list["observe"])

			if(alert(src,"Are you sure you wish to observe? You will not be able to play this round!","Player Setup","Yes","No") == "Yes")
				if(!client)	return 1
				var/mob/dead/observer/observer = new()

				spawning = 1
				src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // MAD JAMS cant last forever yo

				observer.started_as_observer = 1
				close_spawn_windows()
				var/obj/O = locate("landmark*Observer-Start")
				src << "\blue Now teleporting."
				observer.loc = O.loc
				observer.timeofdeath = world.time // Set the time of death so that the respawn timer works correctly.

				client.prefs.update_preview_icon(1)
				observer.icon = client.prefs.preview_icon
				observer.alpha = 127

				if(client.prefs.be_random_name)
					client.prefs.real_name = random_name(client.prefs.gender,client.prefs.species)
				observer.real_name = client.prefs.real_name
				observer.name = observer.real_name
				if(!client.holder && !config.antag_hud_allowed)           // For new ghosts we remove the verb from even showing up if it's not allowed.
					observer.verbs -= /mob/dead/observer/verb/toggle_antagHUD        // Poor guys, don't know what they are missing!
				observer.key = key
				del(src)

				return 1

		if(href_list["late_join"])
			if(!ticker || ticker.current_state != GAME_STATE_PLAYING)
				usr << "\red The round is either not ready, or has already finished..."
				return

			if(client.prefs.species != "Human")

				if(!is_alien_whitelisted(src, client.prefs.species) && config.usealienwhitelist)
					src << alert("You are currently not whitelisted to play [client.prefs.species].")
					return 0

			LateChoices()

		if(href_list["manifest"])
			ViewManifest()

		if(href_list["SelectedJob"])

			if(!enter_allowed)
				usr << "\blue There is an administrative lock on entering the game!"
				return

			if(!is_alien_whitelisted(src, client.prefs.species) && config.usealienwhitelist)
				src << alert("You are currently not whitelisted to play [client.prefs.species].")
				return 0

			AttemptLateSpawn(href_list["SelectedJob"])
			return

		if(href_list["privacy_poll"])
			establish_db_connection()
			if(!dbcon.IsConnected())
				return
			var/voted = 0

			//First check if the person has not voted yet.
			var/DBQuery/query = dbcon.NewQuery("SELECT * FROM erro_privacy WHERE ckey='[src.ckey]'")
			query.Execute()
			while(query.NextRow())
				voted = 1
				break

			//This is a safety switch, so only valid options pass through
			var/option = "UNKNOWN"
			switch(href_list["privacy_poll"])
				if("signed")
					option = "SIGNED"
				if("anonymous")
					option = "ANONYMOUS"
				if("nostats")
					option = "NOSTATS"
				if("later")
					usr << browse(null,"window=privacypoll")
					return
				if("abstain")
					option = "ABSTAIN"

			if(option == "UNKNOWN")
				return

			if(!voted)
				var/sql = "INSERT INTO erro_privacy VALUES (null, Now(), '[src.ckey]', '[option]')"
				var/DBQuery/query_insert = dbcon.NewQuery(sql)
				query_insert.Execute()
				usr << "<b>Thank you for your vote!</b>"
				usr << browse(null,"window=privacypoll")

		if(!ready && href_list["preference"])
			if(client)
				client.prefs.process_link(src, href_list)
		else if(!href_list["late_join"])
			new_player_panel()

		if(href_list["showpoll"])

			handle_player_polling()
			return

		if(href_list["pollid"])

			var/pollid = href_list["pollid"]
			if(istext(pollid))
				pollid = text2num(pollid)
			if(isnum(pollid))
				src.poll_player(pollid)
			return

		if(href_list["votepollid"] && href_list["votetype"])
			var/pollid = text2num(href_list["votepollid"])
			var/votetype = href_list["votetype"]
			switch(votetype)
				if("OPTION")
					var/optionid = text2num(href_list["voteoptionid"])
					vote_on_poll(pollid, optionid)
				if("TEXT")
					var/replytext = href_list["replytext"]
					log_text_poll_reply(pollid, replytext)
				if("NUMVAL")
					var/id_min = text2num(href_list["minid"])
					var/id_max = text2num(href_list["maxid"])

					if( (id_max - id_min) > 100 )	//Basic exploit prevention
						usr << "The option ID difference is too big. Please contact administration or the database admin."
						return

					for(var/optionid = id_min; optionid <= id_max; optionid++)
						if(!isnull(href_list["o[optionid]"]))	//Test if this optionid was replied to
							var/rating
							if(href_list["o[optionid]"] == "abstain")
								rating = null
							else
								rating = text2num(href_list["o[optionid]"])
								if(!isnum(rating))
									return

							vote_on_numval_poll(pollid, optionid, rating)
				if("MULTICHOICE")
					var/id_min = text2num(href_list["minoptionid"])
					var/id_max = text2num(href_list["maxoptionid"])

					if( (id_max - id_min) > 100 )	//Basic exploit prevention
						usr << "The option ID difference is too big. Please contact administration or the database admin."
						return

					for(var/optionid = id_min; optionid <= id_max; optionid++)
						if(!isnull(href_list["option_[optionid]"]))	//Test if this optionid was selected
							vote_on_poll(pollid, optionid, 1)

	proc/IsJobAvailable(rank)
		var/datum/job/job = job_master.GetJob(rank)
		if(!job)	return 0
		if((job.current_positions >= job.total_positions) && job.total_positions != -1)	return 0
		if(jobban_isbanned(src,rank))	return 0
		if(!job.player_old_enough(src.client))	return 0
		// assistant limits
		if(config.assistantlimit)
			if(job.title == "Assistant")
				var/count = 0
				var/datum/job/officer = job_master.GetJob("Security Officer")
				var/datum/job/warden = job_master.GetJob("Warden")
				var/datum/job/hos = job_master.GetJob("Head of Security")
				count += (officer.current_positions + warden.current_positions + hos.current_positions)
				if(job.current_positions > (config.assistantratio * count))
					if(count >= 5) // if theres more than 5 security on the station just let assistants join regardless, they should be able to handle the tide
						return 1
					return 0
		if(job.title == "Assistant" && job.current_positions > 5)
			var/datum/job/officer = job_master.GetJob("Security Officer")
			if(officer.current_positions >= officer.total_positions)
				officer.total_positions++
		return 1

	proc/FuckUpGenes(var/mob/living/carbon/human/H)
		// 20% of players have bad genetic mutations.
		if(prob(20))
			H.dna.GiveRandomSE(notflags = GENE_UNNATURAL,genetype = GENETYPE_BAD)
			if(prob(10)) // 10% of those have a good mut.
				H.dna.GiveRandomSE(notflags = GENE_UNNATURAL,genetype = GENETYPE_GOOD)


	proc/AttemptLateSpawn(rank)
		if (src != usr)
			return 0
		if(!ticker || ticker.current_state != GAME_STATE_PLAYING)
			usr << "\red The round is either not ready, or has already finished..."
			return 0
		if(!enter_allowed)
			usr << "\blue There is an administrative lock on entering the game!"
			return 0
		if(!IsJobAvailable(rank))
			src << alert("[rank] is not available. Please try another.")
			return 0

		job_master.AssignRole(src, rank, 1)

		var/mob/living/carbon/human/character = create_character()	//creates the human and transfers vars and mind
		job_master.EquipRank(character, rank, 1)					//equips the human
		EquipCustomItems(character)
		character.loc = pick(latejoin)
		character.lastarea = get_area(loc)

		ticker.mode.latespawn(character)

		//ticker.mode.latespawn(character)

		if(character.mind.assigned_role != "Cyborg")
			data_core.manifest_inject(character)
			ticker.minds += character.mind//Cyborgs and AIs handle this in the transform proc.	//TODO!!!!! ~Carn
			AnnounceArrival(character, rank)
			FuckUpGenes(character)
		else
			character.Robotize()
		del(src)

	proc/AnnounceArrival(var/mob/living/carbon/human/character, var/rank)
		if (ticker.current_state == GAME_STATE_PLAYING)
			var/obj/item/device/radio/intercom/a = new /obj/item/device/radio/intercom(null)// BS12 EDIT Arrivals Announcement Computer, rather than the AI.
			if(character.mind.role_alt_title)
				rank = character.mind.role_alt_title
			a.autosay("[character.real_name],[rank ? " [rank]," : " visitor," ] has arrived on the station.", "Arrivals Announcement Computer")
			del(a)

	proc/LateChoices()
		var/mills = world.time // 1/10 of a second, not real milliseconds but whatever
		//var/secs = ((mills % 36000) % 600) / 10 //Not really needed, but I'll leave it here for refrence.. or something
		var/mins = (mills % 36000) / 600
		var/hours = mills / 36000


		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\mob\new_player\new_player.dm:322: var/dat = "<html><body><center>"
		var/dat = {"<html><body><center>
Round Duration: [round(hours)]h [round(mins)]m<br>"}
		// END AUTOFIX
		if(emergency_shuttle) //In case Nanotrasen decides reposess CentComm's shuttles.
			if(emergency_shuttle.direction == 2) //Shuttle is going to centcomm, not recalled
				dat += "<font color='red'><b>The station has been evacuated.</b></font><br>"
			if(emergency_shuttle.direction == 1 && emergency_shuttle.timeleft() < 300 && emergency_shuttle.alert == 0) // Emergency shuttle is past the point of no recall
				dat += "<font color='red'>The station is currently undergoing evacuation procedures.</font><br>"
			if(emergency_shuttle.direction == 1 && emergency_shuttle.alert == 1) // Crew transfer initiated
				dat += "<font color='red'>The station is currently undergoing crew transfer procedures.</font><br>"

		dat += "Choose from the following open positions:<br>"
		for(var/datum/job/job in job_master.occupations)
			if(job && IsJobAvailable(job.title))
				var/active = 0
				// Only players with the job assigned and AFK for less than 10 minutes count as active
				for(var/mob/M in player_list) if(M.mind && M.client && M.mind.assigned_role == job.title && M.client.inactivity <= 10 * 60 * 10)
					active++
				dat += "<a href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title] ([job.current_positions]) (Active: [active])</a><br>"

		dat += "</center>"
		src << browse(dat, "window=latechoices;size=300x640;can_close=1")


	proc/create_character()
		spawning = 1
		close_spawn_windows()

		var/mob/living/carbon/human/new_character = new(loc)
		new_character.lastarea = get_area(loc)

		var/datum/species/chosen_species
		if(client.prefs.species)
			chosen_species = all_species[client.prefs.species]
		if(chosen_species)
			if(is_alien_whitelisted(src, client.prefs.species) || !config.usealienwhitelist || !(chosen_species.flags & WHITELISTED) || (client.holder.rights & R_ADMIN) )// Have to recheck admin due to no usr at roundstart. Latejoins are fine though.
				new_character.set_species(client.prefs.species)
				if(chosen_species.language)
					new_character.add_language(chosen_species.language)

		var/datum/language/chosen_language
		if(client.prefs.language)
			chosen_language = all_languages[client.prefs.language]
		if(chosen_language)
			if(is_alien_whitelisted(src, client.prefs.language) || !config.usealienwhitelist || !(chosen_language.flags & WHITELISTED))
				new_character.add_language(client.prefs.language)
		if(ticker.random_players || appearance_isbanned(src)) //disabling ident bans for now
			new_character.gender = pick(MALE, FEMALE)
			client.prefs.real_name = random_name(new_character.gender)
			client.prefs.randomize_appearance_for(new_character)
		else
			client.prefs.copy_to(new_character)

		src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // MAD JAMS cant last forever yo

		if(mind)
			mind.active = 0					//we wish to transfer the key manually
			if(mind.assigned_role == "Clown")				//give them a clownname if they are a clown
				new_character.real_name = pick(clown_names)	//I hate this being here of all places but unfortunately dna is based on real_name!
				new_character.rename_self("clown")
			else if(mind.assigned_role == "Mime")
				new_character.rename_self("mime")
			mind.original = new_character
			mind.transfer_to(new_character)					//won't transfer key since the mind is not active

		new_character.name = real_name
		new_character.dna.ready_dna(new_character)
		new_character.dna.b_type = client.prefs.b_type

		if(client.prefs.disabilities & DISABILITY_FLAG_NEARSIGHTED)
			new_character.dna.SetSEState(GLASSESBLOCK,1,1)
			new_character.disabilities |= NEARSIGHTED

		if(client.prefs.disabilities & DISABILITY_FLAG_FAT)
			new_character.mutations += M_FAT
			new_character.overeatduration = 600 // Max overeat

		if(client.prefs.disabilities & DISABILITY_FLAG_EPILEPTIC)
			new_character.dna.SetSEState(EPILEPSYBLOCK,1,1)
			new_character.disabilities |= EPILEPSY

		if(client.prefs.disabilities & DISABILITY_FLAG_DEAF)
			new_character.dna.SetSEState(DEAFBLOCK,1,1)
			new_character.sdisabilities |= DEAF

		new_character.dna.UpdateSE()

		new_character.key = key		//Manually transfer the key to log them in

		return new_character

	proc/ViewManifest()

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\mob\new_player\new_player.dm:410: var/dat = "<html><body>"
		var/dat = {"<html><body>
<h4>Crew Manifest</h4>"}
		// END AUTOFIX
		dat += data_core.get_manifest(OOC = 1)

		src << browse(dat, "window=manifest;size=370x420;can_close=1")

	Move(NewLoc,Dir=0,step_x=0,step_y=0)
		return 0


	proc/close_spawn_windows()
		src << browse(null, "window=latechoices") //closes late choices window
		src << browse(null, "window=playersetup") //closes the player setup window
