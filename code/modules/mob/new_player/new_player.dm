//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

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

	verb/new_player_panel()
		set src = usr
		new_player_panel_proc()


	proc/new_player_panel_proc()
		//no db for now
		/*var/user = sqlfdbklogin
		var/pass = sqlfdbkpass
		var/db = sqlfdbkdb
		var/address = sqladdress
		var/port = sqlport*/

		var/output = "<B>New Player Options</B>"
		output +="<hr>"
		output += "<br><a href='byond://?src=\ref[src];show_preferences=1'>Setup Character</A><br><br>"

		if(!ticker || ticker.current_state <= GAME_STATE_PREGAME)
			if(!ready)
				output += "<a href='byond://?src=\ref[src];ready=1'>Declare Ready</A><br><br>"
			else
				output += "<b>You are ready</b> (<a href='byond://?src=\ref[src];ready=2'>Cancel</A>)<br><br>"

		else
			output += "<a href='byond://?src=\ref[src];manifest=1'>View the Crew Manifest</A><br><br>"
			output += "<a href='byond://?src=\ref[src];late_join=1'>Join Game!</A><br><br>"

		output += "<a href='byond://?src=\ref[src];observe=1'>Observe</A><br><br>"
		output += "<a href='byond://?src=\ref[src];pregame_music=1'>Lobby Music</A>"

		/*if(!IsGuestKey(src.key))
			var/DBConnection/dbcon = new()
			dbcon.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")

			if(dbcon.IsConnected())
				var/isadmin = 0
				if(src.client && src.client.holder)
					isadmin = 1
				var/DBQuery/query = dbcon.NewQuery("SELECT id FROM erro_poll_question WHERE [(isadmin ? "" : "adminonly = false AND")] Now() BETWEEN starttime AND endtime AND id NOT IN (SELECT pollid FROM erro_poll_vote WHERE ckey = \"[ckey]\")")
				query.Execute()
				var/newpoll = 0
				while(query.NextRow())
					newpoll = 1
					break

				if(newpoll)
					output += "<p><b><a href='byond://?src=\ref[src];showpoll=1'>Show Player Polls</A> (NEW!)</b></p>"
				else
					output += "<p><a href='byond://?src=\ref[src];showpoll=1'>Show Player Polls</A></p>"
			dbcon.Disconnect()*/

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

		//shh ;)
		var/music = ticker.login_music
		if(ckey == "cajoes")
			music = 'sound/music/dangerzone.ogg'
		else if(ckey == "duntada")
			music = 'sound/music/you_are_likely_to_be_eaten.ogg'
		else if(ckey == "misterbook")
			music = 'sound/music/dinosaur.ogg'
		else if(ckey == "chinsky")
			music = 'sound/music/soviet_anthem.ogg'
		else if(ckey == "abi79")
			music = 'sound/music/spinmeround.ogg'
		else if(ckey == "mloc")
			music = 'sound/music/cantina1_short.ogg'
		else if(ckey == "applemaster")
			music = 'sound/music/elektronik_supersonik.ogg'
		else if(ckey == "wrongnumber")
			music = 'sound/music/greenthumb.ogg'
		src << sound(music, repeat = 0, wait = 0, volume = 85, channel = 1)	//MAD JAMZ

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
				for(var/mob/new_player/player in player_list)
					stat("[player.key]", (player.ready)?("(Playing)"):(null))
					totalPlayers++
					if(player.ready)totalPlayersReady++

	Topic(href, href_list[])
		if(!client)	return 0

		if(href_list["show_preferences"])
			preferences.ShowChoices(src)
			return 1

		if(href_list["ready"])
			var/num_old_slots = GetAvailableAlienPlayerSlots()
			var/new_slots = num_old_slots
			if(!ready)
				if(num_old_slots >= 1 || preferences.species == "Human")
					ready = 1
					new_slots = GetAvailableAlienPlayerSlots()
				else
					src << "\red Unable to declare ready. Too many players have already elected to play as aliens."
			else
				ready = 0
				new_slots = GetAvailableAlienPlayerSlots()

			if(num_old_slots < 1 && new_slots >= 1)
				for(var/mob/new_player/N in world)
					N << "\blue A new alien player slot has opened."
			else if(num_old_slots >= 1 && new_slots < 1)
				for(var/mob/new_player/N in world)
					N << "\red New alien players can no longer enter the game."

		if(href_list["refresh"])
			src << browse(null, "window=playersetup") //closes the player setup window
			new_player_panel_proc()

		if(href_list["observe"])

			if(alert(src,"Are you sure you wish to observe? You will not be able to play this round!","Player Setup","Yes","No") == "Yes")
				var/mob/dead/observer/observer = new()

				spawning = 1
				src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // MAD JAMS cant last forever yo

				observer.started_as_observer = 1
				close_spawn_windows()
				var/obj/O = locate("landmark*Observer-Start")
				src << "\blue Now teleporting."
				observer.loc = O.loc
				observer.key = key
				if(preferences.be_random_name)
					preferences.randomize_name()
				observer.name = preferences.real_name
				observer.real_name = observer.name

				observer.timeofdeath = world.time //So you can't just observe than respawn

				preferences.copy_to_observer(observer)

				del(src)
				return 1

		if(href_list["late_join"])
			if(!ticker || ticker.current_state != GAME_STATE_PLAYING)
				usr << "\red The round is either not ready, or has already finished..."
				return

			if(preferences.species != "Human")
				if(!is_alien_whitelisted(src, preferences.species) && config.usealienwhitelist)
					src << alert("You are currently not whitelisted to play [preferences.species].")
					return 0
				else if(GetAvailableAlienPlayerSlots() < 1)
					src << "\red Unable to join game. Too many players have already joined as aliens."
					return 0

			LateChoices()

		if(href_list["manifest"])
			ViewManifest()

		if(href_list["SelectedJob"])

			if(!enter_allowed)
				usr << "\blue There is an administrative lock on entering the game!"
				return

			AttemptLateSpawn(href_list["SelectedJob"])
			return

		if(href_list["pregame_music"])
			preferences.pregame_music = !preferences.pregame_music


			if(preferences.pregame_music)
				Playmusic()
			else
				Stopmusic()
			// only save this 1 pref, so current slot doesn't get saved w/o user's knowledge
			var/savefile/F = new(preferences.savefile_path(src))
			F["pregame_music"] << preferences.pregame_music

		if(href_list["privacy_poll"])
			usr << "\red DB usage has been disabled and that option should not have been available."
			return

			var/user = sqlfdbklogin
			var/pass = sqlfdbkpass
			var/db = sqlfdbkdb
			var/address = sqladdress
			var/port = sqlport

			var/DBConnection/dbcon = new()

			dbcon.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
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

			dbcon.Disconnect()

		if(!ready && href_list["preference"])
			preferences.process_link(src, href_list)
		else if(!href_list["late_join"])
			new_player_panel()

		if(href_list["priv_msg"])
			..()	//pass PM calls along to /mob/Topic
			return

		if(href_list["showpoll"])
			usr << "\red DB usage has been disabled and that option should not have been available."
			return

			handle_player_polling()
			return

		if(href_list["pollid"])
			usr << "\red DB usage has been disabled and that option should not have been available."
			return

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

		var/num_old_slots = GetAvailableAlienPlayerSlots()
		var/new_slots = num_old_slots
		if(preferences.species != "Human")
			if(!is_alien_whitelisted(src, preferences.species) && config.usealienwhitelist)
				src << alert("You are currently not whitelisted to play [preferences.species].")
				return 0
			else if(num_old_slots < 1)
				src << "\red Unable to join game. Too many players have already joined as aliens."
				return 0

		job_master.AssignRole(src, rank, 1)

		var/mob/living/carbon/human/character = create_character()	//creates the human and transfers vars and mind
		job_master.EquipRank(character, rank, 1)					//equips the human
		character.loc = pick(latejoin)
		character.lastarea = get_area(loc)

		if(character.client)
			character.client.be_syndicate = preferences.be_special

		ticker.mode.latespawn(character)

		if(character.mind.assigned_role != "Cyborg")
			data_core.manifest_inject(character)
			ticker.minds += character.mind//Cyborgs and AIs handle this in the transform proc.	//TODO!!!!! ~Carn
			AnnounceArrival(character, rank)

			new_slots = GetAvailableAlienPlayerSlots()
			if(num_old_slots < 1 && new_slots >= 1)
				for(var/mob/new_player/N in world)
					N << "\blue A new alien player slot has opened."
			else if(num_old_slots >= 1 && new_slots < 1)
				for(var/mob/new_player/N in world)
					N << "\red New alien players can no longer enter the game."

		else
			character.Robotize()
		del(src)

	proc/AnnounceArrival(var/mob/living/carbon/human/character, var/rank)
		if (ticker.current_state == GAME_STATE_PLAYING)
			var/mob/living/silicon/ai/announcer = new (null)
			var/obj/item/device/radio/intercom/a = new /obj/item/device/radio/intercom(null)// BS12 EDIT Arrivals Announcement Computer, rather than the AI.
			announcer.name = "Arrivals Announcement Computer"
			announcer.real_name = "Arrivals Announcement Computer"
			a.autosay("\"[character.real_name],[character.wear_id.assignment ? " [character.wear_id.assignment]," : "" ] has arrived on the station.\"", announcer)
			del(a)
			del(announcer)

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
				dat += "<a href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title] ([job.current_positions])</a><br>"

		dat += "</center>"
		src << browse(dat, "window=latechoices;size=300x640;can_close=1")


	proc/create_character()
		spawning = 1
		close_spawn_windows()

		var/mob/living/carbon/human/new_character = new(loc)
		new_character.lastarea = get_area(loc)

		if(preferences.species == "Tajaran") //This is like the worst, but it works, so meh. - Erthilo
			if(is_alien_whitelisted(src, "Tajaran") || !config.usealienwhitelist)
				new_character.dna.mutantrace = "tajaran"
				new_character.tajaran_talk_understand = 1
		if(preferences.species == "Soghun")
			if(is_alien_whitelisted(src, "Soghun") || !config.usealienwhitelist)
				new_character.dna.mutantrace = "lizard"
				new_character.soghun_talk_understand = 1
		if(preferences.species == "Skrell")
			if(is_alien_whitelisted(src, "Skrell") || !config.usealienwhitelist)
				new_character.dna.mutantrace = "skrell"
				new_character.skrell_talk_understand = 1

		if(ticker.random_players)
			new_character.gender = pick(MALE, FEMALE)
			preferences.randomize_name()
			preferences.randomize_appearance_for(new_character)
		else
			preferences.copy_to(new_character)

		src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // MAD JAMS cant last forever yo

		if(mind)
			mind.active = 0					//we wish to transfer the key manually
			if(mind.assigned_role == "Clown")				//give them a clownname if they are a clown
				new_character.real_name = pick(clown_names)	//I hate this being here of all places but unfortunately dna is based on real_name!
				new_character.rename_self("clown")
			mind.original = new_character
			mind.transfer_to(new_character)					//won't transfer key since the mind is not active

		new_character.name = real_name
		new_character.dna.ready_dna(new_character)
		new_character.dna.b_type = preferences.b_type

		new_character.key = key		//Manually transfer the key to log them in

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

//limits the number of alien players in a game
/proc/GetAvailableAlienPlayerSlots()
	if(!config.limitalienplayers)
		return 9999

	var/num_players = 0

	//check new players
	for(var/mob/new_player/N in world)
		if(N.preferences && N.ready)
			num_players++

	//check players already spawned, only count humans or aliens
	for(var/mob/living/carbon/human/H in world)
		if(H.ckey)
			num_players++

	return round(num_players * (config.alien_to_human_ratio / 100))
