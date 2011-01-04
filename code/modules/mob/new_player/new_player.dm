mob/new_player
	anchored = 1

	var/datum/preferences/preferences
	var/ready = 0

	invisibility = 101

	density = 0
	stat = 2
	canmove = 0

	anchored = 1	//  don't get pushed around

	Login()
		..()

		if(!preferences)
			preferences = new

		if(!mind)
			mind = new
			mind.key = key
			mind.current = src

		new_player_panel()
		var/starting_loc = pick(newplayer_start)
		src.loc = starting_loc
		src.sight |= SEE_TURFS
		var/list/watch_locations = list()
		for(var/obj/landmark/landmark in world)
			if(landmark.tag == "landmark*new_player")
				watch_locations += landmark.loc

		if(watch_locations.len>0)
			loc = pick(watch_locations)

		if(!preferences.savefile_load(src, 0))
			preferences.ShowChoices(src)
			if (src.client.changes)
				src.changes()
		else
			var/lastchangelog = length('changelog.html')
			if (!src.client.changes && preferences.lastchangelog!=lastchangelog)
				src.changes()
				preferences.lastchangelog = lastchangelog
				preferences.savefile_save(src)
		//PDA Resource Initialisation =======================================================>


		if (client) //load the PDA iconset into the client
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

		//End PDA Resource Initialisation =====================================================>


	Logout()
		ready = 0
		..()
		return

	verb
		new_player_panel()
			set src = usr

			var/output = "<HR><B>New Player Options</B><BR>"
			output += "<HR><br><a href='byond://?src=\ref[src];show_preferences=1'>Setup Character</A><BR><BR>"
			//if(istester(src.key))
			if(!ticker || ticker.current_state <= GAME_STATE_PREGAME)
				if(!ready)
					output += "<a href='byond://?src=\ref[src];ready=1'>Declare Ready</A><BR>"
				else
					output += "You are ready.<BR>"
			else
				output += "<a href='byond://?src=\ref[src];late_join=1'>Join Game!</A><BR>"

			output += "<BR><a href='byond://?src=\ref[src];observe=1'>Observe</A><BR>"

			src << browse(output,"window=playersetup;size=250x210;can_close=0")

	Stat()
		..()

		statpanel("Game")
		if(client.statpanel=="Game" && ticker)
			if(ticker.hide_mode)
				stat("Game Mode:", "Secret")
			else
				stat("Game Mode:", "[master_mode]")

			if(ticker.current_state == GAME_STATE_PREGAME)
				stat("Time To Start:", ticker.pregame_timeleft)

		statpanel("Lobby")
		if(client.statpanel=="Lobby" && ticker)
			if(ticker.current_state == GAME_STATE_PREGAME)
				for(var/mob/new_player/player in world)
					stat("[player.key]", (player.ready)?("(Playing)"):(null))

	Topic(href, href_list[])
		if(href_list["show_preferences"])
			preferences.ShowChoices(src)
			return 1

		if(href_list["ready"])
			if (!usr.client.authenticated)
				src << "You are not authorized to enter the game."
				return

			if(!ready)
				if(alert(src,"Are you sure you are ready? This will lock-in your preferences.","Player Setup","Yes","No") == "Yes")
					ready = 1

		if(href_list["observe"])
			if (!usr.client.authenticated)
				src << "You are not authorized to enter the game."
				return

			if(alert(src,"Are you sure you wish to observe? You will not be able to play this round!","Player Setup","Yes","No") == "Yes")
				var/mob/dead/observer/observer = new()

				close_spawn_windows()
				var/obj/O = locate("landmark*Observer-Start")
				src << "\blue Now teleporting."
				observer.loc = O.loc
				observer.key = key
				if(preferences.be_random_name)
					preferences.randomize_name()
				observer.name = preferences.real_name
				observer.real_name = observer.name

				del(src)
				return 1

		if(href_list["late_join"])
			LateChoices()

		if(href_list["SelectedJob"])
			if (!usr.client.authenticated)
				src << "You are not authorized to enter the game."
				return

			if (!enter_allowed)
				usr << "\blue There is an administrative lock on entering the game!"
				return

			switch(href_list["SelectedJob"])
				if ("1")
					AttemptLateSpawn("Captain", captainMax)
				if ("2")
					AttemptLateSpawn("Head of Security", hosMax)
				if ("3")
					AttemptLateSpawn("Head of Personnel", hopMax)
				if ("4")
					AttemptLateSpawn("Station Engineer", engineerMax)
				if ("5")
					AttemptLateSpawn("Barman", barmanMax)
				if ("6")
					AttemptLateSpawn("Scientist", scientistMax)
				if ("7")
					AttemptLateSpawn("Chemist", chemistMax)
				if ("8")
					AttemptLateSpawn("Geneticist", geneticistMax)
				if ("9")
					AttemptLateSpawn("Security Officer", securityMax)
				if ("10")
					AttemptLateSpawn("Medical Doctor", doctorMax)
				if ("11")
					AttemptLateSpawn("Atmospheric Technician", atmosMax)
				if ("12")
					AttemptLateSpawn("Detective", detectiveMax)
				if ("13")
					AttemptLateSpawn("Chaplain", chaplainMax)
				if ("14")
					AttemptLateSpawn("Janitor", janitorMax)
				if ("15")
					AttemptLateSpawn("Clown", clownMax)
				if ("16")
					AttemptLateSpawn("Chef", chefMax)
				if ("17")
					AttemptLateSpawn("Roboticist", roboticsMax)
				if ("18")
					AttemptLateSpawn("Assistant", 10000)
				if ("19")
					AttemptLateSpawn("Quartermaster", cargoMax)
				if ("20")
					AttemptLateSpawn("Research Director", directorMax)
				if ("21")
					AttemptLateSpawn("Chief Engineer", chiefMax)
				if ("22")
					AttemptLateSpawn("Botanist", hydroponicsMax)
				if ("23")
					AttemptLateSpawn("Librarian", librarianMax)
				if ("24")
					AttemptLateSpawn("Virologist", viroMax)
				if ("25")
					AttemptLateSpawn("Lawyer", lawyerMax)
				if ("26")
					AttemptLateSpawn("Cargo Technician", cargotechMax)
				if ("27")
					AttemptLateSpawn("Chief Medical Officer", cmoMax)
				if ("28")
					AttemptLateSpawn("Warden", wardenMax)

		if(!ready && href_list["preferences"])
			preferences.process_link(src, href_list)
		else if(!href_list["late_join"])
			new_player_panel()

	proc/IsJobAvailable(rank, maxAllowed)
		if(countJob(rank) < maxAllowed && !jobban_isbanned(src,rank))
			return 1
		else
			return 0

	proc/AttemptLateSpawn(rank, maxAllowed)
		if(IsJobAvailable(rank, maxAllowed))
			var/mob/living/carbon/human/character = create_character()
			if (character)
				character.Equip_Rank(rank, joined_late=1)

			//add to manifest -- Commented out in favor of ManifestLateSpawn() -- TLE
			//for(var/datum/data/record/t in data_core.general)
			//	if((t.fields["name"] == character.real_name) && (t.fields["rank"] == "Unassigned"))
			//		t.fields["rank"] = rank

				ManifestLateSpawn(character)
				if(ticker)
					if (ticker.current_state == GAME_STATE_PLAYING)
						var/list/mob/living/silicon/ai/ailist = list()
						for (var/mob/living/silicon/ai/A in world)
							if (!A.stat && A.name != "Inactive AI")
								ailist += A
						if (ailist.len)
							var/mob/living/silicon/ai/announcer = pick(ailist)
							announcer.say("[character.real_name] has signed up as [rank].")

					var/starting_loc = pick(latejoin)
					character.loc = starting_loc
					del(src)

		else
			src << alert("[rank] is not available. Please try another.")


	proc/ManifestLateSpawn(var/mob/living/carbon/human/H) // Attempted fix to add late joiners to various databases -- TLE
		// This is basically ripped wholesale from the normal code for adding people to the databases during a fresh round
		if (!isnull(H.mind) && (H.mind.assigned_role != "MODE"))
			var/datum/data/record/G = new /datum/data/record(  )
			var/datum/data/record/M = new /datum/data/record(  )
			var/datum/data/record/S = new /datum/data/record(  )
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
			if (H.gender == FEMALE)
				G.fields["sex"] = "Female"
			else
				G.fields["sex"] = "Male"
			G.fields["age"] = text("[]", H.age)
			G.fields["fingerprint"] = text("[]", md5(H.dna.uni_identity))
			G.fields["p_stat"] = "Active"
			G.fields["m_stat"] = "Stable"
			M.fields["b_type"] = text("[]", H.b_type)
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
			data_core.general += G
			data_core.medical += M
			data_core.security += S
		return

// This fxn creates positions for assistants based on existing positions. This could be more elgant.
	proc/LateChoices()
		var/dat = "<html><body>"
		dat += "Choose from the following open positions:<br>"
		if (IsJobAvailable("Captain",captainMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=1'>Captain</a><br>"

		if (IsJobAvailable("Head of Security",hosMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=2'>Head of Security</a><br>"

		if (IsJobAvailable("Head of Personnel",hopMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=3'>Head of Personnel</a><br>"

		if (IsJobAvailable("Research Director",directorMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=20'>Research Director</a><br>"

		if (IsJobAvailable("Chief Engineer",chiefMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=21'>Chief Engineer</a><br>"

		if (IsJobAvailable("Station Engineer",engineerMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=4'>Station Engineer</a><br>"

		if (IsJobAvailable("Barman",barmanMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=5'>Barman</a><br>"

		if (IsJobAvailable("Scientist",scientistMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=6'>Scientist</a><br>"

		if (IsJobAvailable("Chemist",chemistMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=7'>Chemist</a><br>"

		if (IsJobAvailable("Geneticist",geneticistMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=8'>Geneticist</a><br>"

		if (IsJobAvailable("Security Officer",securityMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=9'>Security Officer</a><br>"

		if (IsJobAvailable("Medical Doctor",doctorMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=10'>Medical Doctor</a><br>"

		if (IsJobAvailable("Atmospheric Technician",atmosMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=11'>Atmospheric Technician</a><br>"

		if (IsJobAvailable("Detective",detectiveMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=12'>Detective</a><br>"

		if (IsJobAvailable("Chaplain",chaplainMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=13'>Chaplain</a><br>"

		if (IsJobAvailable("Janitor",janitorMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=14'>Janitor</a><br>"

		if (IsJobAvailable("Clown",clownMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=15'>Clown</a><br>"

		if (IsJobAvailable("Chef",chefMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=16'>Chef</a><br>"

		if (IsJobAvailable("Roboticist",roboticsMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=17'>Roboticist</a><br>"

		if (IsJobAvailable("Quartermaster",cargoMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=19'>Quartermaster</a><br>"

		if (IsJobAvailable("Botanist",hydroponicsMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=22'>Botanist</a><br>"
		if (IsJobAvailable("Librarian",librarianMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=23'>Librarian</a><br>"
		if (IsJobAvailable("Virologist",viroMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=24'>Virologist</a><br>"
		if (IsJobAvailable("Lawyer",lawyerMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=25'>Lawyer</a><br>"
		if (IsJobAvailable("Cargo Technician",cargotechMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=26'>Cargo Technician</a><br>"
		if (IsJobAvailable("Chief Medical Officer",cmoMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=27'>Chief Medical Officer</a><br>"
		if (IsJobAvailable("Warden", wardenMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=28'>Warden</a><br>"
		if (!jobban_isbanned(src,"Assistant"))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=18'>Assistant</a><br>"

		src << browse(dat, "window=latechoices;size=300x640;can_close=0")

	proc/create_character()
		var/mob/living/carbon/human/new_character = new(src.loc)

		close_spawn_windows()

		preferences.copy_to(new_character)
		new_character.dna.ready_dna(new_character)
		if(mind)
			mind.transfer_to(new_character)


		return new_character

	Move()
		return 0


	proc/close_spawn_windows()
		src << browse(null, "window=latechoices") //closes late choices window
		src << browse(null, "window=playersetup") //closes the player setup window

/*
/obj/begin/verb/enter()
	log_game("[usr.key] entered as [usr.real_name]")

	if (ticker)
		for (var/mob/living/silicon/ai/A in world)
			if (!A.stat)
				A.say("[usr.real_name] has arrived on the station!")
				break

		usr << "<B>Game mode is [master_mode].</B>"

	var/mob/living/carbon/human/H = usr

//find spawn points for normal game modes

	if(!(ticker && ticker.mode.name == "ctf"))
		var/list/L = list()
		var/area/A = locate(/area/arrival/start)
		for(var/turf/T in A)
			L += T

		while(!L.len)
			usr << "\blue <B>You were unable to enter because the arrival shuttle has been destroyed! The game will reattempt to spawn you in 30 seconds!</B>"
			sleep(300)
			for(var/turf/T in A)
				L += T
		H << "\blue Now teleporting."
		H.loc = pick(L)

//for capture the flag

	else if(ticker && ticker.mode.name == "ctf")
		if(H.client.team == "Red")
			var/obj/R = locate("landmark*Red-Spawn")
			H << "\blue Now teleporting."
			H.loc = R.loc
		else if(H.client.team == "Green")
			var/obj/G = locate("landmark*Green-Spawn")
			H << "\blue Now teleporting."
			H.loc = G.loc

//error check

	else
		usr << "Invalid start please report this to the admins"

//add to manifest

	if(ticker)
		//add to manifest
		var/datum/data/record/G = new /datum/data/record(  )
		var/datum/data/record/M = new /datum/data/record(  )
		var/datum/data/record/S = new /datum/data/record(  )
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
		if (H.gender == "female")
			G.fields["sex"] = "Female"
		else
			G.fields["sex"] = "Male"
		G.fields["age"] = text("[]", H.age)
		G.fields["fingerprint"] = text("[]", md5(H.dna.uni_identity))
		G.fields["p_stat"] = "Active"
		G.fields["m_stat"] = "Stable"
		M.fields["b_type"] = text("[]", H.b_type)
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
		S.fields["ma_crim_d"] = "No minor crime convictions."
		S.fields["notes"] = "No notes."
		for(var/obj/datacore/D in world)
			D.general += G
			D.medical += M
			D.security += S
//DNA!
		reg_dna[H.dna.unique_enzymes] = H.real_name
//Other Stuff
		if(ticker.mode.name == "sandbox")
			H.CanBuild()

*/
/*
	say(var/message)
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

		if (!message)
			return

		log_say("[src.key] : [message]")

		if (src.muted)
			return

		. = src.say_dead(message)
*/