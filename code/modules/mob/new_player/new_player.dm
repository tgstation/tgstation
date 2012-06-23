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
			output += "<a href='byond://?src=\ref[src];late_join=1'>Join Game!</A><BR>"

		output += "<BR><a href='byond://?src=\ref[src];observe=1'>Observe</A><BR>"

		src << browse(output,"window=playersetup;size=250x210;can_close=0")
		return

	proc/handle_privacy_poll()
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

		var/DBQuery/query = dbcon.NewQuery("SELECT * FROM erro_privacy WHERE ckey='[src.ckey]'")
		query.Execute()
		while(query.NextRow())
			voted = 1
			break

		if(!voted)
			privacy_poll()

		dbcon.Disconnect()

	proc/privacy_poll()
		var/output = "<div align='center'><B>Player poll</B>"
		output +="<hr>"
		output += "<b>We would like to expand our stats gathering.</b>"
		output += "<br>This however involves gathering data about player behavior, play styles, unique player numbers, play times, etc. Data like that cannot be gathered fully anonymously, which is why we're asking you how you'd feel if player-specific data was gathered. Prior to any of this actually happening, a privacy policy will be discussed, but before that can begin, we'd preliminarily like to know how you feel about the concept."
		output +="<hr>"
		output += "How do you feel about the game gathering player-specific statistics? This includes statistics about individual players as well as in-game polling/opinion requests."

		output += "<p><a href='byond://?src=\ref[src];privacy_poll=signed'>Signed stats gathering</A>"
		output += "<br>Pick this option if you think usernames should be logged with stats. This allows us to have personalized stats as well as polls."

		output += "<p><a href='byond://?src=\ref[src];privacy_poll=anonymous'>Anonymous stats gathering</A>"
		output += "<br>Pick this option if you think only hashed (indecipherable) usernames should be logged with stats. This doesn't allow us to have personalized stats, as we can't tell who is who (hashed values aren't readable), we can however have ingame polls."

		output += "<p><a href='byond://?src=\ref[src];privacy_poll=nostats'>No stats gathering</A>"
		output += "<br>Pick this option if you don't want player-specific stats gathered. This does not allow us to have player-specific stats or polls."

		output += "<p><a href='byond://?src=\ref[src];privacy_poll=later'>Ask again later</A>"
		output += "<br>This poll will be brought up again next round."

		output += "<p><a href='byond://?src=\ref[src];privacy_poll=abstain'>Don't ask again</A>"
		output += "<br>Only pick this if you are fine with whatever option wins."

		output += "</div>"

		src << browse(output,"window=privacypoll;size=600x500")
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

		if(href_list["late_join"])
			LateChoices()

		if(href_list["SelectedJob"])

			if(!enter_allowed)
				usr << "\blue There is an administrative lock on entering the game!"
				return

			AttemptLateSpawn(href_list["SelectedJob"])
			return

		if(href_list["privacy_poll"])
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

		var/mob/living/carbon/human/character = create_character()
		var/icon/char_icon = getFlatIcon(character,0)//We're creating out own cache so it's not needed.
		job_master.AssignRole(character, rank, 1)
		job_master.EquipRank(character, rank, 1)
		character.loc = pick(latejoin)
		character.lastarea = get_area(loc)
		AnnounceArrival(character, rank)

		if(character.mind.assigned_role != "Cyborg")
			ManifestLateSpawn(character,char_icon)
			ticker.minds += character.mind//Cyborgs and AIs handle this in the transform proc.
		else
			character.Robotize()
		del(src)


	proc/AnnounceArrival(var/mob/living/carbon/human/character, var/rank)
		if (ticker.current_state == GAME_STATE_PLAYING)
			var/ailist[] = list()
			for (var/mob/living/silicon/ai/A in world)
				if (!A.stat)
					ailist += A
			if (ailist.len)
				var/mob/living/silicon/ai/announcer = pick(ailist)
				if(character.mind)
					if((character.mind.assigned_role != "Cyborg") && (character.mind.special_role != "MODE"))
						announcer.say("[character.real_name] has signed up as [rank].")


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
			else
				G.fields["rank"] = "Unassigned"
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
			M.fields["b_type"] = text("[]", H.b_type)
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
			L.fields["rank"] = H.mind.assigned_role
			L.fields["b_type"] = H.b_type
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
		var/mob/living/carbon/human/new_character = new(loc)
		new_character.lastarea = get_area(loc)

		close_spawn_windows()

		if(ticker.random_players)
			new_character.gender = pick(MALE, MALE, FEMALE)
			preferences.randomize_name()
			preferences.randomize_appearance_for(new_character)
		else
			preferences.copy_to(new_character)

		src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // MAD JAMS cant last forever yo

		new_character.dna.ready_dna(new_character)
		new_character.dna.b_type = preferences.b_type
		if(mind)
			mind.transfer_to(new_character)
			mind.original = new_character

		return new_character


	Move()
		return 0


	proc/close_spawn_windows()
		src << browse(null, "window=latechoices") //closes late choices window
		src << browse(null, "window=playersetup") //closes the player setup window
