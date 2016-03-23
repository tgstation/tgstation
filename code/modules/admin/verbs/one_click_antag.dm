/client/proc/one_click_antag()
	set name = "Create Antagonist"
	set desc = "Auto-create an antagonist of your choice"
	set category = "Admin"

	if(holder)
		holder.one_click_antag()
	return


/datum/admins/proc/one_click_antag()

	var/dat = {"
		<a href='?src=\ref[src];makeAntag=1'>Make Traitors</a><br>
		<a href='?src=\ref[src];makeAntag=2'>Make Changelings</a><br>
		<a href='?src=\ref[src];makeAntag=3'>Make Revs</a><br>
		<a href='?src=\ref[src];makeAntag=4'>Make Cult</a><br>
		<a href='?src=\ref[src];makeAntag=11'>Make Blob</a><br>
		<a href='?src=\ref[src];makeAntag=12'>Make Gangsters</a><br>
		<a href='?src=\ref[src];makeAntag=16'>Make Shadowling</a><br>
		<a href='?src=\ref[src];makeAntag=6'>Make Wizard (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=7'>Make Nuke Team (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=13'>Make Centcom Response Team (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=14'>Make Abductor Team (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=15'>Make Revenant (Requires Ghost)</a><br>
		<a href='?src=\ref[src];makeAntag=16'>Make ERP Squad (Requires Sexy Ghosts)</a><br>
		"}

	var/datum/browser/popup = new(usr, "oneclickantag", "Quick-Create Antagonist", 400, 400)
	popup.set_content(dat)
	popup.open()

/datum/admins/proc/makeTraitors()
	var/datum/game_mode/traitor/temp = new

	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	if(config.protect_assistant_from_antagonist)
		temp.restricted_jobs += "Assistant"

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in player_list)
		if(ROLE_TRAITOR in applicant.client.prefs.be_special)
			if(!applicant.stat)
				if(applicant.mind)
					if (!applicant.mind.special_role)
						if(!jobban_isbanned(applicant, ROLE_TRAITOR) && !jobban_isbanned(applicant, "Syndicate"))
							if(temp.age_check(applicant.client))
								if(!(applicant.job in temp.restricted_jobs))
									candidates += applicant

	if(candidates.len)
		var/numTraitors = min(candidates.len, 3)

		for(var/i = 0, i<numTraitors, i++)
			H = pick(candidates)
			H.mind.make_Traitor()
			candidates.Remove(H)

		return 1


	return 0


/datum/admins/proc/makeChanglings()

	var/datum/game_mode/changeling/temp = new
	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	if(config.protect_assistant_from_antagonist)
		temp.restricted_jobs += "Assistant"

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in player_list)
		if(ROLE_CHANGELING in applicant.client.prefs.be_special)
			if(!applicant.stat)
				if(applicant.mind)
					if (!applicant.mind.special_role)
						if(!jobban_isbanned(applicant, ROLE_CHANGELING) && !jobban_isbanned(applicant, "Syndicate"))
							if(temp.age_check(applicant.client))
								if(!(applicant.job in temp.restricted_jobs))
									candidates += applicant

	if(candidates.len)
		var/numChanglings = min(candidates.len, 3)

		for(var/i = 0, i<numChanglings, i++)
			H = pick(candidates)
			H.mind.make_Changling()
			candidates.Remove(H)

		return 1

	return 0

/datum/admins/proc/makeRevs()

	var/datum/game_mode/revolution/temp = new
	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	if(config.protect_assistant_from_antagonist)
		temp.restricted_jobs += "Assistant"

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in player_list)
		if(ROLE_REV in applicant.client.prefs.be_special)
			if(applicant.stat == CONSCIOUS)
				var/turf/T = get_turf(applicant)
				if(T.z == ZLEVEL_STATION)
					if(applicant.mind)
						if(!applicant.mind.special_role)
							if(!jobban_isbanned(applicant, ROLE_REV) && !jobban_isbanned(applicant, "Syndicate"))
								if(temp.age_check(applicant.client))
									if(!(applicant.job in temp.restricted_jobs))
										candidates += applicant

	if(candidates.len)
		var/numRevs = min(candidates.len, 3)

		for(var/i = 0, i<numRevs, i++)
			H = pick(candidates)
			H.mind.make_Rev()
			candidates.Remove(H)
		return 1

	return 0

/datum/admins/proc/makeWizard()
	var/datum/game_mode/wizard/temp = new
	var/list/mob/dead/observer/candidates = list()
	var/mob/dead/observer/theghost = null
	var/time_passed = world.time

	for(var/mob/dead/observer/G in player_list)
		if(!jobban_isbanned(G, "wizard") && !jobban_isbanned(G, "Syndicate"))
			if(temp.age_check(G.client))
				spawn(0)
					switch(alert(G, "Do you wish to be considered for the position of Space Wizard Foundation 'diplomat'?","Please answer in 30 seconds!","Yes","No"))
						if("Yes")
							if((world.time-time_passed)>300)//If more than 30 game seconds passed.
								return
							candidates += G
						if("No")
							return
						else
							return

	sleep(300)

	if(candidates.len)
		shuffle(candidates)
		for(var/mob/i in candidates)
			if(!i || !i.client) continue //Dont bother removing them from the list since we only grab one wizard

			theghost = i
			break

	if(theghost)
		var/mob/living/carbon/human/new_character=makeBody(theghost)
		new_character.mind.make_Wizard()
		return 1

	return 0


/datum/admins/proc/makeCult()
	var/datum/game_mode/cult/temp = new
	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	if(config.protect_assistant_from_antagonist)
		temp.restricted_jobs += "Assistant"

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in player_list)
		if(ROLE_CULTIST in applicant.client.prefs.be_special)
			if(applicant.stat == CONSCIOUS)
				if(applicant.mind)
					if(!applicant.mind.special_role)
						if(!jobban_isbanned(applicant, ROLE_CULTIST) && !jobban_isbanned(applicant, "Syndicate"))
							if(temp.age_check(applicant.client))
								if(!(applicant.job in temp.restricted_jobs))
									candidates += applicant

	if(candidates.len)
		var/numCultists = min(candidates.len, 4)

		for(var/i = 0, i<numCultists, i++)
			H = pick(candidates)
			H.mind.make_Cultist()
			candidates.Remove(H)

		return 1

	return 0



/datum/admins/proc/makeNukeTeam()

	var/datum/game_mode/nuclear/temp = new
	var/list/mob/dead/observer/candidates = pollCandidates("Do you wish to be considered for a nuke team being sent in?", "operative", temp)
	var/list/mob/dead/observer/chosen = list()
	var/mob/dead/observer/theghost = null

	if(candidates.len)
		var/numagents = 5
		var/agentcount = 0

		for(var/i = 0, i<numagents,i++)
			shuffle(candidates) //More shuffles means more randoms
			for(var/mob/j in candidates)
				if(!j || !j.client)
					candidates.Remove(j)
					continue

				theghost = j
				candidates.Remove(theghost)
				chosen += theghost
				agentcount++
				break
		//Making sure we have atleast 3 Nuke agents, because less than that is kinda bad
		if(agentcount < 3)
			return 0

		var/nuke_code = "[rand(10000, 99999)]"

		var/obj/machinery/nuclearbomb/nuke = locate("syndienuke") in nuke_list
		if(nuke)
			nuke.r_code = nuke_code

		//Let's find the spawn locations
		var/list/turf/synd_spawn = list()
		for(var/obj/effect/landmark/A in landmarks_list)
			if(A.name == "Syndicate-Spawn")
				synd_spawn += get_turf(A)
				continue

		var/leader_chosen
		var/spawnpos = 1 //Decides where they'll spawn. 1=leader.

		for(var/mob/c in chosen)
			if(spawnpos > synd_spawn.len)
				spawnpos = 2 //Ran out of spawns. Let's loop back to the first non-leader position
			var/mob/living/carbon/human/new_character=makeBody(c)
			if(!leader_chosen)
				leader_chosen = 1
				new_character.mind.make_Nuke(synd_spawn[spawnpos],nuke_code,1)
			else
				new_character.mind.make_Nuke(synd_spawn[spawnpos],nuke_code)
			spawnpos++
		return 1
	else
		return 0





/datum/admins/proc/makeAliens()
	new /datum/round_event/alien_infestation{spawncount=3}()
	return 1

/datum/admins/proc/makeSpaceNinja()
	new /datum/round_event/ninja()
	return 1

// DEATH SQUADS
/datum/admins/proc/makeDeathsquad()
	var/mission = input("Assign a mission to the deathsquad", "Assign Mission", "Leave no witnesses.")
	var/list/mob/dead/observer/candidates = pollCandidates("Do you wish to be considered for an elite Nanotrasen Strike Team?", "deathsquad", null)
	var/squadSpawned = 0

	if(candidates.len >= 2) //Minimum 2 to be considered a squad
		//Pick the lucky players
		var/numagents = min(5,candidates.len) //How many commandos to spawn
		var/list/spawnpoints = emergencyresponseteamspawn
		while(numagents && candidates.len)
			if (numagents > spawnpoints.len)
				numagents--
				continue // This guy's unlucky, not enough spawn points, we skip him.
			var/spawnloc = spawnpoints[numagents]
			var/mob/dead/observer/chosen_candidate = pick(candidates)
			candidates -= chosen_candidate
			if(!chosen_candidate.key)
				continue

			//Spawn and equip the commando
			var/mob/living/carbon/human/Commando = new(spawnloc)
			chosen_candidate.client.prefs.copy_to(Commando)
			if(numagents == 1) //If Squad Leader
				Commando.real_name = "Officer [pick(commando_names)]"
				Commando.equipOutfit(/datum/outfit/death_commando/officer)
			else
				Commando.real_name = "Trooper [pick(commando_names)]"
				Commando.equipOutfit(/datum/outfit/death_commando)
			Commando.dna.update_dna_identity()
			Commando.key = chosen_candidate.key
			Commando.mind.assigned_role = "Death Commando"
			for(var/obj/machinery/door/poddoor/ert/door in airlocks)
				spawn(0)
					door.open()

			//Assign antag status and the mission
			ticker.mode.traitors += Commando.mind
			Commando.mind.special_role = "deathsquad"
			var/datum/objective/missionobj = new
			missionobj.owner = Commando.mind
			missionobj.explanation_text = mission
			missionobj.completed = 1
			Commando.mind.objectives += missionobj

			//Greet the commando
			Commando << "<B><font size=3 color=red>You are the [numagents==1?"Deathsquad Officer":"Death Commando"].</font></B>"
			var/missiondesc = "Your squad is being sent on a mission to [station_name()] by Nanotrasen's Security Division."
			if(numagents == 1) //If Squad Leader
				missiondesc += " Lead your squad to ensure the completion of the mission. Board the shuttle when your team is ready."
			else
				missiondesc += " Follow orders given to you by your squad leader."
			missiondesc += "<BR><B>Your Mission</B>: [mission]"
			Commando << missiondesc

			if(config.enforce_human_authority)
				Commando.set_species(/datum/species/human)

			//Logging and cleanup
			if(numagents == 1)
				message_admins("The deathsquad has spawned with the mission: [mission].")
			log_game("[key_name(Commando)] has been selected as a Death Commando")
			numagents--
			squadSpawned++

		if (squadSpawned)
			return 1
		else
			return 0

	return


/datum/admins/proc/makeGangsters()

	var/datum/game_mode/gang/temp = new
	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	if(config.protect_assistant_from_antagonist)
		temp.restricted_jobs += "Assistant"

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in player_list)
		if(ROLE_GANG in applicant.client.prefs.be_special)
			if(!applicant.stat)
				if(applicant.mind)
					if(!applicant.mind.special_role)
						if(!jobban_isbanned(applicant, ROLE_GANG) && !jobban_isbanned(applicant, "Syndicate"))
							if(temp.age_check(applicant.client))
								if(!(applicant.job in temp.restricted_jobs))
									candidates += applicant

	if(candidates.len >= 2)
		for(var/needs_assigned=2,needs_assigned>0,needs_assigned--)
			H = pick(candidates)
			if(gang_colors_pool.len)
				var/datum/gang/newgang = new()
				ticker.mode.gangs += newgang
				H.mind.make_Gang(newgang)
				candidates.Remove(H)
			else if(needs_assigned == 2)
				return 0
		return 1

	return 0


/datum/admins/proc/makeOfficial()
	var/mission = input("Assign a task for the official", "Assign Task", "Conduct a routine preformance review of [station_name()] and its Captain.")
	var/list/mob/dead/observer/candidates = pollCandidates("Do you wish to be considered to be a Centcom Official?", "deathsquad")

	if(candidates.len)
		var/mob/dead/observer/chosen_candidate = pick(candidates)

		//Create the official
		var/mob/living/carbon/human/newmob = new (pick(emergencyresponseteamspawn))
		chosen_candidate.client.prefs.copy_to(newmob)
		newmob.real_name = newmob.dna.species.random_name(newmob.gender,1)
		newmob.dna.update_dna_identity()
		newmob.key = chosen_candidate.key
		newmob.mind.assigned_role = "Centcom Official"
		newmob.equipOutfit(/datum/outfit/centcom_official)

		//Assign antag status and the mission
		ticker.mode.traitors += newmob.mind
		newmob.mind.special_role = "official"
		var/datum/objective/missionobj = new
		missionobj.owner = newmob.mind
		missionobj.explanation_text = mission
		missionobj.completed = 1
		newmob.mind.objectives += missionobj

		if(config.enforce_human_authority)
			newmob.set_species(/datum/species/human)

		//Greet the official
		newmob << "<B><font size=3 color=red>You are a Centcom Official.</font></B>"
		newmob << "<BR>Central Command is sending you to [station_name()] with the task: [mission]"

		//Logging and cleanup
		message_admins("Centcom Official [key_name_admin(newmob)] has spawned with the task: [mission]")
		log_game("[key_name(newmob)] has been selected as a Centcom Official")

		return 1

	return 0

// CENTCOM RESPONSE TEAM
/datum/admins/proc/makeEmergencyresponseteam()
	var/alert = input("Which team should we send?", "Select Response Level") as null|anything in list("Green: Centcom Official", "Blue: Light ERT (No Armoury Access)", "Amber: Full ERT (Armoury Access)", "Red: Elite ERT (Armoury Access + Pulse Weapons)", "Delta: Deathsquad")
	if(!alert)
		return
	switch(alert)
		if("Delta: Deathsquad")
			return makeDeathsquad()
		if("Red: Elite ERT (Armoury Access + Pulse Weapons)")
			alert = "Red"
		if("Amber: Full ERT (Armoury Access)")
			alert = "Amber"
		if("Blue: Light ERT (No Armoury Access)")
			alert = "Blue"
		if("Green: Centcom Official")
			return makeOfficial()
	var/teamsize = min(7,input("Maximum size of team? (7 max)", "Select Team Size",4) as null|num)
	var/mission = input("Assign a mission to the Emergency Response Team", "Assign Mission", "Assist the station.")
	var/list/mob/dead/observer/candidates = pollCandidates("Do you wish to be considered for a Code [alert] Nanotrasen Emergency Response Team?", "deathsquad", null)
	var/teamSpawned = 0

	if(candidates.len > 0)
		//Pick the (un)lucky players
		var/numagents = min(teamsize,candidates.len) //How many officers to spawn
		var/redalert //If the ert gets super weapons
		if (alert == "Red")
			numagents = min(teamsize,candidates.len)
			redalert = 1
		var/list/spawnpoints = emergencyresponseteamspawn
		while(numagents && candidates.len)
			if (numagents > spawnpoints.len)
				numagents--
				continue // This guy's unlucky, not enough spawn points, we skip him.
			var/spawnloc = spawnpoints[numagents]
			var/mob/dead/observer/chosen_candidate = pick(candidates)
			candidates -= chosen_candidate
			if(!chosen_candidate.key)
				continue

			//Spawn and equip the officer
			var/mob/living/carbon/human/ERTOperative = new(spawnloc)
			var/list/lastname = last_names
			chosen_candidate.client.prefs.copy_to(ERTOperative)
			var/ertname = pick(lastname)
			switch(numagents)
				if(1)
					ERTOperative.real_name = "Commander [ertname]"
					ERTOperative.equipOutfit(redalert ? /datum/outfit/ert/commander/alert : /datum/outfit/ert/commander)
				if(2)
					ERTOperative.real_name = "Security Officer [ertname]"
					ERTOperative.equipOutfit(redalert ? /datum/outfit/ert/security/alert : /datum/outfit/ert/security)
				if(3)
					ERTOperative.real_name = "Medical Officer [ertname]"
					ERTOperative.equipOutfit(redalert ? /datum/outfit/ert/medic/alert : /datum/outfit/ert/medic)
				if(4)
					ERTOperative.real_name = "Engineer [ertname]"
					ERTOperative.equipOutfit(redalert ? /datum/outfit/ert/engineer/alert : /datum/outfit/ert/engineer)
				if(5)
					ERTOperative.real_name = "Security Officer [ertname]"
					ERTOperative.equipOutfit(redalert ? /datum/outfit/ert/security/alert : /datum/outfit/ert/security)
				if(6)
					ERTOperative.real_name = "Medical Officer [ertname]"
					ERTOperative.equipOutfit(redalert ? /datum/outfit/ert/medic/alert : /datum/outfit/ert/medic)
				if(7)
					ERTOperative.real_name = "Engineer [ertname]"
					ERTOperative.equipOutfit(redalert ? /datum/outfit/ert/engineer/alert : /datum/outfit/ert/engineer)
			ERTOperative.dna.update_dna_identity()
			ERTOperative.key = chosen_candidate.key
			ERTOperative.mind.assigned_role = "ERT"

			//Open the Armory doors
			if(alert != "Blue")
				for(var/obj/machinery/door/poddoor/ert/door in airlocks)
					spawn(0)
						door.open()

			//Assign antag status and the mission
			ticker.mode.traitors += ERTOperative.mind
			ERTOperative.mind.special_role = "ERT"
			var/datum/objective/missionobj = new
			missionobj.owner = ERTOperative.mind
			missionobj.explanation_text = mission
			missionobj.completed = 1
			ERTOperative.mind.objectives += missionobj

			//Greet the commando
			ERTOperative << "<B><font size=3 color=red>You are [numagents==1?"the Emergency Response Team Commander":"an Emergency Response Officer"].</font></B>"
			var/missiondesc = "Your squad is being sent on a Code [alert] mission to [station_name()] by Nanotrasen's Security Division."
			if(numagents == 1) //If Squad Leader
				missiondesc += " Lead your squad to ensure the completion of the mission. Avoid civilian casualites when possible. Board the shuttle when your team is ready."
			else
				missiondesc += " Follow orders given to you by your commander. Avoid civilian casualites when possible."
			missiondesc += "<BR><B>Your Mission</B>: [mission]"
			ERTOperative << missiondesc

			if(config.enforce_human_authority)
				ERTOperative.set_species(/datum/species/human)

			//Logging and cleanup
			if(numagents == 1)
				message_admins("A Code [alert] emergency response team has spawned with the mission: [mission]")
			log_game("[key_name(ERTOperative)] has been selected as an Emergency Response Officer")
			numagents--
			teamSpawned++

		if (teamSpawned)
			return 1
		else
			return 0

	return

//Abductors
/datum/admins/proc/makeAbductorTeam()
	new /datum/round_event/abductor
	return 1

/datum/admins/proc/makeERPsquad()
	var/list/mob/dead/observer/candidates = list()
	var/time_passed = world.time

	//Generates a list of ERPers from active ghosts.
	for(var/mob/dead/observer/G in player_list)
		spawn(0)
			switch(alert(G,"Do you wish to be considered for an elite Nanotrasen ERP Squad being sent in?","Please answer in 30 seconds!","Yes","No"))
				if("Yes")
					if((world.time-time_passed)>300)//If more than 30 game seconds passed.
						return
					candidates += G
				if("No")
					return
				else
					return
	sleep(300)

	for(var/mob/dead/observer/G in candidates)
		if(!G.key)
			candidates.Remove(G)

	if(candidates.len >= 3) //Minimum 3 to be considered a squad
		//Pick the unlucky players
		var/numerps = min(5,candidates.len) //How many erpers to spawn
		var/list/spawnpoints = deathsquadspawn
		while(numerps && spawnpoints.len && candidates.len)
			var/spawnloc = spawnpoints[1]
			var/mob/dead/observer/chosen_candidate = pick(candidates)
			candidates -= chosen_candidate
			if(!chosen_candidate.key)
				continue

			//Spawn and equip the erper
			var/mob/living/carbon/human/ERPOperative = new(spawnloc)
			var/list/the_big_list_of_hookers = list("Abriana","Aira","Africa","Alabama","Alana","Alaya","Alecia","Alicia","Alex","Alexis","Alexa","Alexandra","Alexandria","Alison","Allura","Ally","Alpha","Alyssa","Amanda","Amaze","Amber","Amelia","Amethyst","Analis","Anastasia","Andra","Andrea","Andromeda","Angel","Angela","Angelique","Angie","Anise","Anisette","Anna","Annabella","Annie","Annika","Antoinette","Aphrodite","April","Ariel","Aries","Ashlee","Ashley","Ashlyn","Asia","Athena","Atlanta","Aubra","Aubrey","Audra","Aura","Aurora","Austin","Autumn","Ava","Azrael","Baby","Bailey","Bambi","Barbie","Beau","Beautiful","Becky","Bede","Belinda","Belle","Berry","Bethany","Bianca","Bindi","Bird","Bo","Bolero","Blade","Blake","Blanca","Blaze","Blondie","Blossom","Blue","Blush","Bobbie","Bordeaux","Bountiful","Brandy","Brandi","Breeze","Breezy","Brianna","Bridget","Brie","Brilliant","Brita","Britain","Brittany","Bronte","Bubbles","Buffy","Bunny","Burgundie","Butterfly","Callie","Cameo","Camille","Candi","Candice","Candy","Candee","Carmel","Carmela","Carmen","Carrie","Cashmere","Champagne","Chance","Chanel","Chantal","Chantelle","Chantilly","Chantiqua","Chaos","Charity","Charlie","Charlotte","Chastity","Cherie","Cherry","Cheyenne","China","Chloe","Chocolate","Chrissy","Christian","Christi","Lynn","Christy","Christine","Chynna","Cecilia","Cinder","Cinnamon","CJ","Cleo","Cleopatra","Clover","Coco","Cody","Constance","Contessa","Cookie","Crystal","Cuddles","Cynara","Cynder","Cyndi","Dagny","Dahlia","Daisy","Dakota","Dallas","Damiana","Dana","Danger","Danielle","Danni","Daphne","Darby","Darkness","Darla","Dawn","Decadence","Dee","Ann","Deidre","Deja","Delicious","Delight","Delilah","Delta","Deluxe","Denver","Desert","Rose","Desire","Desiree","Destiny","Devon","Devyn","Dharma","Diablo","Diamond","Diana","Dido","Diva","Divine","Divinity","Dixie","Dolly","Dominique","Dream","Duchess","Dusty","Dylan","Ebony","Echo","Ecstasy","Eden","Elan","Ella","Elle","Electra","Eli","Eliza","Elizabeth","Elvira","Elyse","Ember","Emerald","Emergency","Emily","Empress","Envy","Epiphany","Erotica","Esme","Eva","Evie","Eve","Fable","Fabulous","Faith","Fallon","Fame","Fantasia","Fantasy","Farrah","Fate","Fawn","Fawna","Fawnia","Feather","Felicia","Felicity","Felony","Ferrari","Fern","Fetish","Fiona","Fire","Francesca","Flame","Foxxxy","Frankie","Frosty","Gabrielle","Gabriella","Gaia","Gem","Gemma","Gemini","Genie","Gentle","Georgia","Gia","Giggles","Gigi","Gillian","Ginger","Giselle","Glamour","Glitter","Glory","Godiva","Grace","Gracious","Gypsy","Hanna","Harley","Harlow","Harmony","Heather","Heaven","Heavenleigh","Heavenly","Helena","Hillary","Holiday","Holly","Honey","Hope","Houston","Hyacinth","Ianna","Ice","Iesha","Illusion","Imagine","India","Indigo","Inferno","Infinity","Ireland","Irene","Isabel","Isabella","Isis","Ivory","Ivy","Izzy","Jade","Jaguar","Jamie","Janelle","Jasmine","Jasmyn","Jeanette","Jeanie","Jenna","Jenny","Jessica","Jessie","Jewel","Jewels","Jezebel","Jill","Jinx","JJ","Joetta","Joelle","Jolene","Jordan","Journey","Joy","Juicy","Julia","Julie","Juliet","June","Juno","Kaia","Kailli","Kara","Karla","Kashmir","Kat","Kathleen","Kayla","Kelli","Kenya","Karma","Kira","Kitten","Kitty","Krista","Kristen","Kristi","Krystal","Kylie","Kyra","Lace","Lacy","Lainie","Lakota","Lana","Latifah","Laura","Layla","Leah","Leather","Leggs","Leia","Leigh","Lexie","Licorice","Lightning","Lila","Lilith","Lily","Lindsey","Lisa","Lita","Liza","Logan","Lola","London","Loni","Lori","Love","Lucinda","Lucky","Lucretia","Lumina","Luna","Luscious","Luxury","Luxxie","Macy","Madeline","Madison","Magdalene","Magenta","Maggie","Magic","Magnolia","Malia","Malibu","Malice","Mandy","Manhattan","Margot","Maria","Mariah","Mariana","Marilyn","Marina","Marla","Marlena","Marti","Mary","Ann","Mary","Jane","Maxxx","May","McKenzie","Medusa","Megan","Melano","Melanie","Melinda","Melody","Melonie","Mercury","Merlot","Merlyn","Michelle","Mikhaila","Mikki","Mindee","Mindy","Mink","Mistress","Misty","Mercedes","Mercy","Midnight","Miracle","Mocha","Molly","Mona","Monaco","Monica","Monique","Montana","Morgan","Muse","Music","Mystery","Mystique","Nadia","Nanette","Nastasia","Nasty","Natalia","Natalie","Natasha","Nica","Nicole","Nikita","Nikki","Niko","Nina","Nixie","Noel","Nola","Norah","Notorious","Octavia","Olive","Olivia","Olympia","Omega","Opal","Ophelia","Paige","Pallas","Pamela","Pandemonium","Pandora","Pansy","Panther","Paradise","Paris","Passion","Paula","Peaches","Peanut","Pearl","Pebbles","Penelope","Penny","Pepper","Persephone","Petal","Peyton","Phoenix","Piper","Pisces","Pixie","Poison","Porsche","Power","Precious","Princess","Puppy","Queen","Quinn","Rachel","Rain","Ramona","Raven","Reba","Rebecca","Red","Renee","Rhiannon","Ria","Rio","Rita","River","Robyn","Rocki","Roma","Rose","Rosemary","Rosie","Roxanna","Roxanne","Ruby","Sable","Sabrina","Sachet","Saffron","Sage","Salome","Samantha","Sandi","Sapphire","Sarah","Sarasota","Saraya","Sasha","Sashay","Sassparilla","Sassy","Satan","Satin","Sativa","Savannah","Scandal","Scarlet","Selena","September","Septiva","Serena","Serenity","Seven","Shana","Shane","Shannon","Shawna","Shay","Shea","Shelby","Shelly","Sheree","Sherri","Sherry","Shine","Siam","Siena","Sierra","Silk","Silky","Silver","Sin","Simone","Siren","Skye","Sloane","Smoky","Soleil","Sonia","Song","Sorority","Spice","Spider","Spring","Staci","Stacia","Starr","Stevie","Storm","Stormy","Strawberry","Suavecita","Sublime","Sugar","Summer","Sundae","Sundance","Sunday","Sunni","Sunny","Sunshine","Sunset","Susanna","Suzanne","Swallow","Sweet","Sweetness","Tabitha","Taffy","Talia","Tallulah","Tamar","Tamara","Tammi","Tane","Tanya","Tara","Tasha","Tasty","Tatiana","Tawni","Taylor","Temper","Tempest","Temptation","Terra","Terror","Tess","Tessa","Texxxas","Thai","Thia","Thumper","Thyme","Tia","Tickle","Tiffany","Tiger","Tigra","Tika","Time","Tina","Tinker","Tisha","Toffee","Tommy","Toni","Topaz","Tori","Traci","Tracy","Tricia","Trinity","Trip","Tristana","Trixie","Trouble","Tuesday","Tyffany","Tyler","Tyra","Unique","Utopia","Valentina","Valentine","Vandal","Vanessa","Vanity","Velvet","Venus","Veronica","Viagra","Victoria","Victory","Viola","Violet","Viper","Virginia","Virgo","Vision","Vivienne","Vixen","Vonda","Wanda","Wednesday","Wendy","Whimsy","Whisky","Whisper","Willow","Windy","Winter","Wish","Wyndi","Xanadu","Xanthe","Xaviera","Xena","Xiola","Xtase","Yasmin","Yolanda","Yvette","Yvonne","Zena","Zenith","Zinnia","Zoe","Zoey","Zora")
			chosen_candidate.client.prefs.copy_to(ERPOperative)
			ERPOperative.gender = FEMALE
			ERPOperative.hair_style = "Floorlength Braid"
			ERPOperative.facial_hair_style = "Shaved"
			ERPOperative.underwear = "Ladies Kinky"
			ERPOperative.socks = "Nude"
			ERPOperative.undershirt = "Nude"
			ERPOperative.lip_style = pick("red", "purple", "jade", "black")
			ready_dna(ERPOperative)
			ERPOperative.update_body()
			ERPOperative.update_hair()
			ERPOperative.real_name = "[pick(the_big_list_of_hookers)] [pick(last_names)]"
			ERPOperative.key = chosen_candidate.key
			ERPOperative.mind.assigned_role = "ERP"

			//Assign antag status and the mission
			ticker.mode.traitors += ERPOperative.mind
			ERPOperative.mind.special_role = "ert"
			var/datum/objective/missionobj = new
			missionobj.owner = ERPOperative.mind
			missionobj.explanation_text = "Titillate the crew."
			missionobj.completed = 1
			ERPOperative.mind.objectives += missionobj
			var/datum/objective/dontgetbanned/banana = new
			banana.owner = ERPOperative.mind
			ERPOperative.mind.objectives += banana

			//Greet the ERPer
			ERPOperative << "<B><font size=3 color=red>You are an ERP squadmate.</font></B>"
			var/missiondesc = "Your squad is being sent on a goodwill mission to [station_name()]."
			missiondesc += " Work hard, play hard. Don't break the server rules. Avoid civilian casualites when possible."
			missiondesc += "<BR><B>Your Mission</B>:"
			var/obj_count = 1
			for(var/datum/objective/objective in ERPOperative.mind.objectives)
				missiondesc += "<BR><B>Objective #[obj_count]</B>: [objective.explanation_text]"
				obj_count++
			ERPOperative << missiondesc

			//Logging and cleanup
			if(numerps == 1)
				message_admins("The ERP Squad has spawned. You asked for this.")
			log_game("[key_name(ERPOperative)] has been selected as an ERP Squadmate")
			spawnpoints -= spawnloc
			numerps--

		return 1

	return

/datum/admins/proc/makeBody(var/mob/dead/observer/G_found) // Uses stripped down and bastardized code from respawn character
	if(!G_found || !G_found.key)	return

/datum/admins/proc/makeRevenant()
	var/list/mob/dead/observer/candidates = pollCandidates("Do you wish to be considered for becoming a revenant?", "revenant", null)
	if(candidates.len >= 1)
		var/spook_op = pick(candidates)
		var/mob/dead/observer/O = spook_op
		candidates -= spook_op
		var/mob/living/simple_animal/revenant/revvie = new /mob/living/simple_animal/revenant(get_turf(O))
		revvie.key = O.key
		revvie.mind.assigned_role = "revenant"
		revvie.mind.special_role = "Revenant"
		return 1
	else
		return

//Shadowling
/datum/admins/proc/makeShadowling()
	var/datum/game_mode/shadowling/temp = new
	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs
	if(config.protect_assistant_from_antagonist)
		temp.restricted_jobs += "Assistant"
	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null
	for(var/mob/living/carbon/human/applicant in player_list)
		if(ROLE_SHADOWLING in applicant.client.prefs.be_special)
			if(!applicant.stat)
				if(applicant.mind)
					if(!applicant.mind.special_role)
						if(!jobban_isbanned(applicant, "shadowling") && !jobban_isbanned(applicant, "Syndicate"))
							if(temp.age_check(applicant.client))
								if(!(applicant.job in temp.restricted_jobs))
									if(!(is_shadow_or_thrall(applicant)))
										candidates += applicant

	if(candidates.len)
		H = pick(candidates)
		ticker.mode.shadows += H.mind
		H.mind.special_role = "shadowling"
		H << "<span class='shadowling'><b><i>Something stirs in the space between worlds. A red light floods your mind, and suddenly you understand. Your human disguise has served you well, but it \
		is time you cast it away. You are a shadowling, and you are to ascend at all costs.</b></i></span>"
		ticker.mode.finalize_shadowling(H.mind)
		message_admins("[H] has been made into a shadowling.")
		candidates.Remove(H)
		return 1
	return 0
