client/proc/one_click_antag()
	set name = "Create Antagonist"
	set desc = "Auto-create an antagonist of your choice"
	set category = "Admin"

	if(holder)
		holder.one_click_antag()
	return


/datum/admins/proc/one_click_antag()

	var/dat = {"<B>Quick-Create Antagonist</B><br>
		<a href='?src=\ref[src];makeAntag=1'>Make Traitors</a><br>
		<a href='?src=\ref[src];makeAntag=2'>Make Changelings</a><br>
		<a href='?src=\ref[src];makeAntag=3'>Make Revs</a><br>
		<a href='?src=\ref[src];makeAntag=4'>Make Cult</a><br>
		<a href='?src=\ref[src];makeAntag=5'>Make Malf AI</a><br>
		<a href='?src=\ref[src];makeAntag=11'>Make Blob</a><br>
		<a href='?src=\ref[src];makeAntag=12'>Make Gangsters</a><br>
		<a href='?src=\ref[src];makeAntag=6'>Make Wizard (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=7'>Make Nuke Team (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=13'>Make Centcom Response Team (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=14'>Make Abductor Team (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=15'>Make Revenant (Requires Ghost)</a><br>
		"}
/* These dont work just yet
	Ninja, aliens and deathsquad I have not looked into yet
	Nuke team is getting a null mob returned from makebody() (runtime error: null.mind. Line 272)


		<a href='?src=\ref[src];makeAntag=8'>Make Space Ninja (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=9'>Make Aliens (Requires Ghosts)</a><br>
		"}
*/
	usr << browse(dat, "window=oneclickantag;size=400x400")
	return


/datum/admins/proc/makeMalfAImode()

	var/list/mob/living/silicon/AIs = list()
	var/mob/living/silicon/malfAI = null
	var/datum/mind/themind = null

	for(var/mob/living/silicon/ai/ai in player_list)
		if(ai.client)
			AIs += ai

	if(AIs.len)
		malfAI = pick(AIs)

	if(malfAI)
		themind = malfAI.mind
		themind.make_AI_Malf()
		return 1

	return 0


/datum/admins/proc/makeTraitors()
	var/datum/game_mode/traitor/temp = new

	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	if(config.protect_assistant_from_antagonist)
		temp.restricted_jobs += "Assistant"

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in player_list)
		if(applicant.client.prefs.be_special & BE_TRAITOR)
			if(!applicant.stat)
				if(applicant.mind)
					if (!applicant.mind.special_role)
						if(!jobban_isbanned(applicant, "traitor") && !jobban_isbanned(applicant, "Syndicate"))
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
		if(applicant.client.prefs.be_special & BE_CHANGELING)
			if(!applicant.stat)
				if(applicant.mind)
					if (!applicant.mind.special_role)
						if(!jobban_isbanned(applicant, "changeling") && !jobban_isbanned(applicant, "Syndicate"))
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
		if(applicant.client.prefs.be_special & BE_REV)
			if(applicant.stat == CONSCIOUS)
				if(applicant.mind)
					if(!applicant.mind.special_role)
						if(!jobban_isbanned(applicant, "revolutionary") && !jobban_isbanned(applicant, "Syndicate"))
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
		if(applicant.client.prefs.be_special & BE_CULTIST)
			if(applicant.stat == CONSCIOUS)
				if(applicant.mind)
					if(!applicant.mind.special_role)
						if(!jobban_isbanned(applicant, "cultist") && !jobban_isbanned(applicant, "Syndicate"))
							if(temp.age_check(applicant.client))
								if(!(applicant.job in temp.restricted_jobs))
									candidates += applicant

	if(candidates.len)
		var/numCultists = min(candidates.len, 4)

		for(var/i = 0, i<numCultists, i++)
			H = pick(candidates)
			H.mind.make_Cultist()
			candidates.Remove(H)
			temp.grant_runeword(H)

		return 1

	return 0



/datum/admins/proc/makeNukeTeam()

	var/datum/game_mode/nuclear/temp = new
	var/list/mob/dead/observer/candidates = getCandidates("Do you wish to be considered for a nuke team being sent in?", "operative", temp)
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

		var/obj/effect/landmark/nuke_spawn = locate("landmark*Nuclear-Bomb")
		var/obj/effect/landmark/closet_spawn = locate("landmark*Syndicate-Uplink")
		var/nuke_code = "[rand(10000, 99999)]"

		if(nuke_spawn)
			var/obj/machinery/nuclearbomb/the_bomb = new /obj/machinery/nuclearbomb(nuke_spawn.loc)
			the_bomb.r_code = nuke_code

		if(closet_spawn)
			new /obj/structure/closet/syndicate/nuclear(closet_spawn.loc)

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
	var/list/mob/dead/observer/candidates = getCandidates("Do you wish to be considered for an elite Nanotrasen Strike Team?", "deathsquad", null)
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
			ready_dna(Commando)
			if(numagents == 1) //If Squad Leader
				Commando.real_name = "Officer [pick(commando_names)]"
				equip_deathsquad(Commando, 1)
			else
				Commando.real_name = "Trooper [pick(commando_names)]"
				equip_deathsquad(Commando)
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
		if(applicant.client.prefs.be_special & BE_GANG)
			if(!applicant.stat)
				if(applicant.mind)
					if(!applicant.mind.special_role)
						if(!jobban_isbanned(applicant, "gangster") && !jobban_isbanned(applicant, "Syndicate"))
							if(temp.age_check(applicant.client))
								if(!(applicant.job in temp.restricted_jobs))
									candidates += applicant

	if(candidates.len >= 2)
		H = pick(candidates)
		H.mind.make_Gang("A")
		candidates.Remove(H)
		H = pick(candidates)
		H.mind.make_Gang("B")
		return 1

	return 0

/datum/admins/proc/makeOfficial()
	var/mission = input("Assign a task for the official", "Assign Task", "Conduct a routine preformance review of [station_name()] and its Captain.")
	var/list/mob/dead/observer/candidates = getCandidates("Do you wish to be considered to be a Centcom Official?", "pAI")

	if(candidates.len)
		var/mob/dead/observer/chosen_candidate = pick(candidates)

		//Create the official
		var/mob/living/carbon/human/newmob = new (pick(emergencyresponseteamspawn))
		chosen_candidate.client.prefs.copy_to(newmob)
		ready_dna(newmob)
		newmob.real_name = random_name(newmob.gender)
		newmob.key = chosen_candidate.key
		newmob.mind.assigned_role = "Centcom Official"
		equip_centcomofficial(newmob)

		//Assign antag status and the mission
		ticker.mode.traitors += newmob.mind
		newmob.mind.special_role = "official"
		var/datum/objective/missionobj = new
		missionobj.owner = newmob.mind
		missionobj.explanation_text = mission
		missionobj.completed = 1
		newmob.mind.objectives += missionobj

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
	var/alert = input("Which team should we send?", "Select Response Level") as null|anything in list("Green: Centcom Official", "Blue: Light ERT", "Amber: Full ERT", "Red: Elite ERT", "Delta: Deathsquad")
	if(!alert)
		return
	switch(alert)
		if("Delta: Deathsquad")
			return makeDeathsquad()
		if("Red: Elite ERT")
			alert = "Red"
		if("Amber: Full ERT")
			alert = "Amber"
		if("Blue: Light ERT")
			alert = "Blue"
		if("Green: Centcom Official")
			return makeOfficial()
	var/teamsize = min(7,input("Maximum size of team? (7 max)", "Select Team Size",4) as null|num)
	var/mission = input("Assign a mission to the Emergency Response Team", "Assign Mission", "Assist the station.")
	var/list/mob/dead/observer/candidates = getCandidates("Do you wish to be considered for a Code [alert] Nanotrasen Emergency Response Team?", "deathsquad", null)
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
			ready_dna(ERTOperative)
			switch(numagents)
				if(1)
					ERTOperative.real_name = "Commander [pick(lastname)]"
					equip_emergencyresponsesquad(ERTOperative, "commander",redalert)
				if(2)
					ERTOperative.real_name = "Security Officer [pick(lastname)]"
					equip_emergencyresponsesquad(ERTOperative, "sec",redalert)
				if(3)
					ERTOperative.real_name = "Medical Officer [pick(lastname)]"
					equip_emergencyresponsesquad(ERTOperative, "med",redalert)
				if(4)
					ERTOperative.real_name = "Engineer [pick(lastname)]"
					equip_emergencyresponsesquad(ERTOperative, "eng",redalert)
				if(5)
					ERTOperative.real_name = "Security Officer [pick(lastname)]"
					equip_emergencyresponsesquad(ERTOperative, "sec",redalert)
				if(6)
					ERTOperative.real_name = "Medical Officer [pick(lastname)]"
					equip_emergencyresponsesquad(ERTOperative, "med",redalert)
				if(7)
					ERTOperative.real_name = "Engineer [pick(lastname)]"
					equip_emergencyresponsesquad(ERTOperative, "eng",redalert)
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
	var/list/mob/dead/observer/candidates = getCandidates("Do you wish to be considered for an Abductor Team?", "abductor", null)

	if(candidates.len >= 2)
		//Oh god why we can't have static functions
		var/teams_finished = 0
		if(ticker.mode.config_tag == "abductor")
			var/datum/game_mode/abduction/A = ticker.mode
			teams_finished = A.teams
		else
			teams_finished = round(ticker.mode.abductors.len / 2)
		var/number =  teams_finished + 1

		var/datum/game_mode/abduction/temp
		if(ticker.mode.config_tag == "abductor")
			temp = ticker.mode
		else
			temp = new

		var/agent_mind = pick(candidates)
		candidates -= agent_mind
		var/scientist_mind = pick(candidates)

		var/mob/living/carbon/human/agent=makeBody(agent_mind)
		var/mob/living/carbon/human/scientist=makeBody(scientist_mind)

		agent_mind = agent.mind
		scientist_mind = scientist.mind

		temp.scientists.len = number
		temp.agents.len = number
		temp.abductors.len = 2*number
		temp.team_objectives.len = number
		temp.team_names.len = number
		temp.scientists[number] = scientist_mind
		temp.agents[number] = agent_mind
		temp.abductors |= list(agent_mind,scientist_mind)
		temp.make_abductor_team(number,preset_scientist=scientist_mind,preset_agent=agent_mind)
		temp.post_setup_team(number)
		if(ticker.mode.config_tag == "abductor")
			var/datum/game_mode/abduction/A = ticker.mode
			A.teams += 1
		else
			ticker.mode.abductors |= temp.abductors

		return 1
	else
		return

/datum/admins/proc/makeRevenant()
	var/list/mob/dead/observer/candidates = getCandidates("Do you wish to be considered for becoming a revenant?", "revenant", null)
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

/datum/admins/proc/getCandidates(var/Question, var/jobbanType, var/datum/game_mode/gametypeCheck)
	var/list/mob/dead/observer/candidates = list()
	var/time_passed = world.time
	if (!Question)
		Question = "Would you like to be a special role?"

	for(var/mob/dead/observer/G in player_list)
		if(!G.key || !G.client)
			continue
		if (gametypeCheck)
			if(!gametypeCheck.age_check(G.client))
				continue
		if (jobbanType)
			if(jobban_isbanned(G, jobbanType) || jobban_isbanned(G, "Syndicate"))
				continue
		spawn(0)
			G << 'sound/misc/notice2.ogg' //Alerting them to their consideration
			switch(alert(G,Question,"Please answer in 30 seconds!","Yes","No"))
				if("Yes")
					G << "<span class='notice'>Choice registered: Yes.</span>"
					if((world.time-time_passed)>300)//If more than 30 game seconds passed.
						G << "<span class='danger'>Sorry, you were too late for the consideration!</span>"
						G << 'sound/machines/buzz-sigh.ogg'
						return
					candidates += G
				if("No")
					G << "<span class='danger'>Choice registered: No.</span>"
					return
				else
					return
	sleep(300)

	//Check all our candidates, to make sure they didn't log off during the 30 second wait period.
	for(var/mob/dead/observer/G in candidates)
		if(!G.key || !G.client)
			candidates.Remove(G)

	return candidates

/datum/admins/proc/makeBody(var/mob/dead/observer/G_found) // Uses stripped down and bastardized code from respawn character
	if(!G_found || !G_found.key)	return

	//First we spawn a dude.
	var/mob/living/carbon/human/new_character = new(pick(latejoin))//The mob being spawned.

	G_found.client.prefs.copy_to(new_character)
	ready_dna(new_character)
	new_character.key = G_found.key

	return new_character
