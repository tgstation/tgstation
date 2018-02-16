/client/proc/one_click_antag()
	set name = "Create Antagonist"
	set desc = "Auto-create an antagonist of your choice"
	set category = "Admin"

	if(holder)
		holder.one_click_antag()
	return


/datum/admins/proc/one_click_antag()

	var/dat = {"
		<a href='?src=[REF(src)];[HrefToken()];makeAntag=traitors'>Make Traitors</a><br>
		<a href='?src=[REF(src)];[HrefToken()];makeAntag=changelings'>Make Changelings</a><br>
		<a href='?src=[REF(src)];[HrefToken()];makeAntag=revs'>Make Revs</a><br>
		<a href='?src=[REF(src)];[HrefToken()];makeAntag=cult'>Make Cult</a><br>
		<a href='?src=[REF(src)];[HrefToken()];makeAntag=clockcult'>Make Clockwork Cult</a><br>
		<a href='?src=[REF(src)];[HrefToken()];makeAntag=blob'>Make Blob</a><br>
		<a href='?src=[REF(src)];[HrefToken()];makeAntag=wizard'>Make Wizard (Requires Ghosts)</a><br>
		<a href='?src=[REF(src)];[HrefToken()];makeAntag=nukeops'>Make Nuke Team (Requires Ghosts)</a><br>
		<a href='?src=[REF(src)];[HrefToken()];makeAntag=centcom'>Make CentCom Response Team (Requires Ghosts)</a><br>
		<a href='?src=[REF(src)];[HrefToken()];makeAntag=abductors'>Make Abductor Team (Requires Ghosts)</a><br>
		<a href='?src=[REF(src)];[HrefToken()];makeAntag=revenant'>Make Revenant (Requires Ghost)</a><br>
		"}

	var/datum/browser/popup = new(usr, "oneclickantag", "Quick-Create Antagonist", 400, 400)
	popup.set_content(dat)
	popup.open()

/datum/admins/proc/isReadytoRumble(mob/living/carbon/human/applicant, targetrole, onstation = TRUE, conscious = TRUE)
	if(applicant.mind.special_role)
		return FALSE
	if(!(targetrole in applicant.client.prefs.be_special))
		return FALSE
	if(onstation)
		var/turf/T = get_turf(applicant)
		if(!is_station_level(T.z))
			return FALSE
	if(conscious && applicant.stat) //incase you don't care about a certain antag being unconcious when made, ie if they have selfhealing abilities.
		return FALSE
	if(!considered_alive(applicant.mind) || considered_afk(applicant.mind)) //makes sure the player isn't a zombie, brain, or just afk all together
		return FALSE
	return (!jobban_isbanned(applicant, targetrole) && !jobban_isbanned(applicant, ROLE_SYNDICATE))


/datum/admins/proc/makeTraitors()
	var/datum/game_mode/traitor/temp = new

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		temp.restricted_jobs += temp.protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		temp.restricted_jobs += "Assistant"

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in GLOB.player_list)
		if(isReadytoRumble(applicant, ROLE_TRAITOR, FALSE))
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
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		temp.restricted_jobs += temp.protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		temp.restricted_jobs += "Assistant"

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in GLOB.player_list)
		if(isReadytoRumble(applicant, ROLE_CHANGELING))
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
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		temp.restricted_jobs += temp.protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		temp.restricted_jobs += "Assistant"

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in GLOB.player_list)
		if(isReadytoRumble(applicant, ROLE_REV))
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

	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you wish to be considered for the position of a Wizard Foundation 'diplomat'?", ROLE_WIZARD, null)

	var/mob/dead/observer/selected = pick_n_take(candidates)

	var/mob/living/carbon/human/new_character = makeBody(selected)
	new_character.mind.make_Wizard()
	return TRUE


/datum/admins/proc/makeCult()
	var/datum/game_mode/cult/temp = new
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		temp.restricted_jobs += temp.protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		temp.restricted_jobs += "Assistant"

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in GLOB.player_list)
		if(isReadytoRumble(applicant, ROLE_CULTIST))
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


/datum/admins/proc/makeClockCult()
	var/datum/game_mode/clockwork_cult/temp = new
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		temp.restricted_jobs += temp.protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		temp.restricted_jobs += "Assistant"

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in GLOB.player_list)
		if(isReadytoRumble(applicant, ROLE_SERVANT_OF_RATVAR))
			if(temp.age_check(applicant.client))
				if(!(applicant.job in temp.restricted_jobs))
					candidates += applicant

	if(candidates.len)
		var/numCultists = min(candidates.len, 4)

		for(var/i = 0, i<numCultists, i++)
			H = pick(candidates)
			to_chat(H, "<span class='heavy_brass'>The world before you suddenly glows a brilliant yellow. You hear the whooshing steam and clanking cogs of a billion billion machines, and all at once \
			you see the truth. Ratvar, the Clockwork Justiciar, lies derelict and forgotten in an unseen realm, and he has selected you as one of his harbringers. You are now a servant of \
			Ratvar, and you will bring him back.</span>")
			H.playsound_local(get_turf(H), 'sound/ambience/antag/clockcultalr.ogg', 100, FALSE, pressure_affected = FALSE)
			add_servant_of_ratvar(H, TRUE)
			SSticker.mode.equip_servant(H)
			candidates.Remove(H)

		return 1

	return 0



/datum/admins/proc/makeNukeTeam()
	var/datum/game_mode/nuclear/temp = new
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you wish to be considered for a nuke team being sent in?", ROLE_OPERATIVE, temp)
	var/list/mob/dead/observer/chosen = list()
	var/mob/dead/observer/theghost = null

	if(candidates.len)
		var/numagents = 5
		var/agentcount = 0

		for(var/i = 0, i<numagents,i++)
			shuffle_inplace(candidates) //More shuffles means more randoms
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

		//Let's find the spawn locations
		var/leader_chosen = FALSE
		var/datum/team/nuclear/nuke_team
		for(var/mob/c in chosen)
			var/mob/living/carbon/human/new_character=makeBody(c)
			if(!leader_chosen)
				leader_chosen = TRUE
				var/datum/antagonist/nukeop/N = new_character.mind.add_antag_datum(/datum/antagonist/nukeop/leader)
				nuke_team = N.nuke_team
			else
				new_character.mind.add_antag_datum(/datum/antagonist/nukeop,nuke_team)
		return 1
	else
		return 0





/datum/admins/proc/makeAliens()
	var/datum/round_event/ghost_role/alien_infestation/E = new(FALSE)
	E.spawncount = 3
	// TODO The fact we have to do this rather than just have events start
	// when we ask them to, is bad.
	E.processing = TRUE
	return TRUE

/datum/admins/proc/makeSpaceNinja()
	new /datum/round_event/ghost_role/ninja()
	return 1

// DEATH SQUADS
/datum/admins/proc/makeDeathsquad()
	return makeEmergencyresponseteam(ERT_DEATHSQUAD)

/datum/admins/proc/makeOfficial()
	var/mission = input("Assign a task for the official", "Assign Task", "Conduct a routine preformance review of [station_name()] and its Captain.")
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you wish to be considered to be a CentCom Official?", "deathsquad")

	if(candidates.len)
		var/mob/dead/observer/chosen_candidate = pick(candidates)

		//Create the official
		var/mob/living/carbon/human/newmob = new (pick(GLOB.emergencyresponseteamspawn))
		chosen_candidate.client.prefs.copy_to(newmob)
		newmob.real_name = newmob.dna.species.random_name(newmob.gender,1)
		newmob.dna.update_dna_identity()
		newmob.key = chosen_candidate.key
		newmob.mind.assigned_role = "CentCom Official"
		newmob.equipOutfit(/datum/outfit/centcom_official)

		//Assign antag status and the mission
		newmob.mind.special_role = "official"

		var/datum/objective/missionobj = new
		missionobj.owner = newmob.mind
		missionobj.explanation_text = mission
		missionobj.completed = 1
		newmob.mind.objectives += missionobj

		newmob.mind.add_antag_datum(/datum/antagonist/auto_custom)

		if(CONFIG_GET(flag/enforce_human_authority))
			newmob.set_species(/datum/species/human)

		//Greet the official
		to_chat(newmob, "<B><font size=3 color=red>You are a CentCom Official.</font></B>")
		to_chat(newmob, "<BR>Central Command is sending you to [station_name()] with the task: [mission]")

		//Logging and cleanup
		message_admins("CentCom Official [key_name_admin(newmob)] has spawned with the task: [mission]")
		log_game("[key_name(newmob)] has been selected as a CentCom Official")

		return 1

	return 0

// CENTCOM RESPONSE TEAM
/datum/admins/proc/makeEmergencyresponseteam(alert_type)
	var/alert
	if(!alert_type)
		alert = input("Which team should we send?", "Select Response Level") as null|anything in list("Green: CentCom Official", "Blue: Light ERT (No Armoury Access)", "Amber: Full ERT (Armoury Access)", "Red: Elite ERT (Armoury Access + Pulse Weapons)", "Delta: Deathsquad")
		if(!alert)
			return
	else
		alert = alert_type
	
	var/teamsize = 0
	var/deathsquad = FALSE

	switch(alert)
		if("Delta: Deathsquad")
			alert = ERT_DEATHSQUAD
			teamsize = 5
			deathsquad = TRUE
		if("Red: Elite ERT (Armoury Access + Pulse Weapons)")
			alert = ERT_RED
		if("Amber: Full ERT (Armoury Access)")
			alert = ERT_AMBER
		if("Blue: Light ERT (No Armoury Access)")
			alert = ERT_BLUE
		if("Green: CentCom Official")
			return makeOfficial()
		else
			return
	
	if(!teamsize)
		var/teamcheck = input("Maximum size of team? (7 max)", "Select Team Size",4) as null|num
		if(isnull(teamcheck))
			return
		teamsize = min(7,teamcheck)
	
	
	var/default_mission = deathsquad ? "Leave no witnesses." : "Assist the station."
	var/mission = input("Assign a mission to the Emergency Response Team", "Assign Mission", default_mission) as null|text
	if(!mission)
		return
	
	var/prompt_name = deathsquad ? "an elite Nanotrasen Strike Team" : "a Code [alert] Nanotrasen Emergency Response Team"
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you wish to be considered for [prompt_name] ?", "deathsquad", null)
	var/teamSpawned = 0

	if(candidates.len > 0)
		//Pick the (un)lucky players
		var/numagents = min(teamsize,candidates.len) //How many officers to spawn

		//Create team
		var/datum/team/ert/ert_team = new
		if(deathsquad)
			ert_team.name = "Death Squad"
		
		//Asign team objective
		var/datum/objective/missionobj = new
		missionobj.team = ert_team
		missionobj.explanation_text = mission
		missionobj.completed = 1
		ert_team.objectives += missionobj
		ert_team.mission = missionobj

		//We give these out in order, then back from the start if there's more than 3
		var/list/role_order = list(ERT_SEC,ERT_MED,ERT_ENG)

		var/list/spawnpoints = GLOB.emergencyresponseteamspawn
		while(numagents && candidates.len)
			if (numagents > spawnpoints.len)
				numagents--
				continue // This guy's unlucky, not enough spawn points, we skip him.
			var/spawnloc = spawnpoints[numagents]
			var/mob/dead/observer/chosen_candidate = pick(candidates)
			candidates -= chosen_candidate
			if(!chosen_candidate.key)
				continue

			//Spawn the body
			var/mob/living/carbon/human/ERTOperative = new(spawnloc)
			chosen_candidate.client.prefs.copy_to(ERTOperative)
			ERTOperative.key = chosen_candidate.key
			
			if(CONFIG_GET(flag/enforce_human_authority))
				ERTOperative.set_species(/datum/species/human)

			//Give antag datum
			var/datum/antagonist/ert/ert_antag = new
			ert_antag.high_alert = alert == ERT_RED
			if(numagents == 1)
				ert_antag.role = deathsquad ? DEATHSQUAD_LEADER : ERT_LEADER
			else
				ert_antag.role = deathsquad ? DEATHSQUAD : role_order[WRAP(numagents,1,role_order.len + 1)]
			ERTOperative.mind.add_antag_datum(ert_antag,ert_team)
			
			ERTOperative.mind.assigned_role = ert_antag.name
			
			//Logging and cleanup
			log_game("[key_name(ERTOperative)] has been selected as an [ert_antag.name]")
			numagents--
			teamSpawned++

		if (teamSpawned)
			message_admins("[prompt_name] has spawned with the mission: [mission]")
			
			//Open the Armory doors
			if(alert != ERT_BLUE)
				for(var/obj/machinery/door/poddoor/ert/door in GLOB.airlocks)
					spawn(0)
						door.open()
			return 1
		else
			return 0

	return

//Abductors
/datum/admins/proc/makeAbductorTeam()
	new /datum/round_event/ghost_role/abductor
	return 1

/datum/admins/proc/makeRevenant()
	new /datum/round_event/ghost_role/revenant(TRUE, TRUE)
	return 1
