<<<<<<< HEAD
/client/proc/one_click_antag()
	set name = "Create Antagonist"
	set desc = "Auto-create an antagonist of your choice"
	set category = "Admin"

=======
client/proc/one_click_antag()
	set name = "Create Antagonist"
	set desc = "Auto-create an antagonist of your choice"
	set category = "Admin"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	if(holder)
		holder.one_click_antag()
	return


/datum/admins/proc/one_click_antag()

<<<<<<< HEAD
	var/dat = {"
		<a href='?src=\ref[src];makeAntag=traitors'>Make Traitors</a><br>
		<a href='?src=\ref[src];makeAntag=changelings'>Make Changelings</a><br>
		<a href='?src=\ref[src];makeAntag=revs'>Make Revs</a><br>
		<a href='?src=\ref[src];makeAntag=cult'>Make Cult</a><br>
		<a href='?src=\ref[src];makeAntag=clockcult'>Make Clockwork Cult</a><br>
		<a href='?src=\ref[src];makeAntag=blob'>Make Blob</a><br>
		<a href='?src=\ref[src];makeAntag=gangs'>Make Gangsters</a><br>
		<a href='?src=\ref[src];makeAntag=wizard'>Make Wizard (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=nukeops'>Make Nuke Team (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=centcom'>Make Centcom Response Team (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=abductors'>Make Abductor Team (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=revenant'>Make Revenant (Requires Ghost)</a><br>
		"}

	var/datum/browser/popup = new(usr, "oneclickantag", "Quick-Create Antagonist", 400, 400)
	popup.set_content(dat)
	popup.open()
=======

	var/dat = {"<B>One-click Antagonist</B><br>
		<a href='?src=\ref[src];makeAntag=1'>Make Traitors</a><br>
		<a href='?src=\ref[src];makeAntag=2'>Make Changlings</a><br>
		<a href='?src=\ref[src];makeAntag=3'>Make Revs</a><br>
		<a href='?src=\ref[src];makeAntag=4'>Make Cult</a><br>
		<a href='?src=\ref[src];makeAntag=5'>Make Malf AI</a><br>
		<a href='?src=\ref[src];makeAntag=6'>Make Wizard (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=11'>Make Vox Raiders (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=7'>Make Nuke Team (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=9'>Make Aliens (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=10'>Make Deathsquad (Syndicate) (Requires Ghosts)</a><br>
		"}

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

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/datum/admins/proc/makeTraitors()
	var/datum/game_mode/traitor/temp = new

	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

<<<<<<< HEAD
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

=======
	var/list/mob/living/carbon/human/candidates = list()

	for(var/mob/living/carbon/human/applicant in player_list)
		if(applicant.client.desires_role(ROLE_TRAITOR))
			if(!applicant.stat)
				if(applicant.mind)
					if (!applicant.mind.special_role)
						if(!jobban_isbanned(applicant, "traitor") && !jobban_isbanned(applicant, "Syndicate"))
							if(!(applicant.job in temp.restricted_jobs))
								candidates += applicant

	if (candidates.len)
		candidates = shuffle(candidates)

		var/mob/living/carbon/human/candidate

		for (var/i = 1 to min(candidates.len, 3))
			candidate = pick_n_take(candidates)

			if (candidate)
				var/datum/mind/candidate_mind = candidate.mind

				if (candidate_mind)
					if (candidate_mind.make_traitor())
						log_admin("[key_name(owner)] has traitor'ed [key_name(candidate)] via create antagonist verb.")

		return 1
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	return 0


/datum/admins/proc/makeChanglings()

<<<<<<< HEAD
=======

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/datum/game_mode/changeling/temp = new
	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

<<<<<<< HEAD
	if(config.protect_assistant_from_antagonist)
		temp.restricted_jobs += "Assistant"

=======
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in player_list)
<<<<<<< HEAD
		if(ROLE_CHANGELING in applicant.client.prefs.be_special)
			var/turf/T = get_turf(applicant)
			if(applicant.stat == CONSCIOUS && applicant.mind && !applicant.mind.special_role && T.z == ZLEVEL_STATION)
				if(!jobban_isbanned(applicant, ROLE_CHANGELING) && !jobban_isbanned(applicant, "Syndicate"))
					if(temp.age_check(applicant.client))
						if(!(applicant.job in temp.restricted_jobs))
							candidates += applicant
=======
		if(applicant.client.desires_role(ROLE_CHANGELING))
			if(!applicant.stat)
				if(applicant.mind)
					if (!applicant.mind.special_role)
						if(!jobban_isbanned(applicant, "changeling") && !jobban_isbanned(applicant, "Syndicate"))
							if(!(applicant.job in temp.restricted_jobs))
								candidates += applicant
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	if(candidates.len)
		var/numChanglings = min(candidates.len, 3)

		for(var/i = 0, i<numChanglings, i++)
			H = pick(candidates)
			H.mind.make_Changling()
			candidates.Remove(H)

		return 1

	return 0

/datum/admins/proc/makeRevs()

<<<<<<< HEAD
=======

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/datum/game_mode/revolution/temp = new
	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

<<<<<<< HEAD
	if(config.protect_assistant_from_antagonist)
		temp.restricted_jobs += "Assistant"

=======
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in player_list)
<<<<<<< HEAD
		if(ROLE_REV in applicant.client.prefs.be_special)
			var/turf/T = get_turf(applicant)
			if(applicant.stat == CONSCIOUS && applicant.mind && !applicant.mind.special_role && T.z == ZLEVEL_STATION)
				if(!jobban_isbanned(applicant, ROLE_REV) && !jobban_isbanned(applicant, "Syndicate"))
					if(temp.age_check(applicant.client))
						if(!(applicant.job in temp.restricted_jobs))
							candidates += applicant
=======
		if(!applicant.client) continue
		if(applicant.client.desires_role(ROLE_REV))
			if(applicant.stat == CONSCIOUS)
				if(applicant.mind)
					if(!applicant.mind.special_role)
						if(!jobban_isbanned(applicant, "revolutionary") && !jobban_isbanned(applicant, "Syndicate"))
							if(!(applicant.job in temp.restricted_jobs))
								candidates += applicant
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	if(candidates.len)
		var/numRevs = min(candidates.len, 3)

		for(var/i = 0, i<numRevs, i++)
			H = pick(candidates)
			H.mind.make_Rev()
			candidates.Remove(H)
		return 1

	return 0

/datum/admins/proc/makeWizard()
<<<<<<< HEAD

	var/list/mob/dead/observer/candidates = pollCandidates("Do you wish to be considered for the position of a Wizard Foundation 'diplomat'?", "wizard", null)

	var/mob/dead/observer/selected = popleft(candidates)

	var/mob/living/carbon/human/new_character = makeBody(selected)
	new_character.mind.make_Wizard()
	return TRUE


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
			var/turf/T = get_turf(applicant)
			if(applicant.stat == CONSCIOUS && applicant.mind && !applicant.mind.special_role && T.z == ZLEVEL_STATION)
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

=======
	var/list/mob/dead/observer/candidates = list()
	var/mob/dead/observer/theghost = null

	for(var/mob/dead/observer/G in get_active_candidates(ROLE_WIZARD,poll="Do you wish to be considered for the Space Wizard Federation \"Ambassador\"?"))
		if(!jobban_isbanned(G, "wizard") && !jobban_isbanned(G, "Syndicate"))
			candidates += G

	if(candidates.len)
		shuffle(candidates)
		for(var/mob/i in candidates)
			if(!i || !i.client) continue //Dont bother removing them from the list since we only grab one wizard

			theghost = i
			break

	if(theghost)
		var/mob/living/carbon/human/new_character=makeBody(theghost)
		new_character.mind.make_Wizard()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		return 1

	return 0


<<<<<<< HEAD
/datum/admins/proc/makeClockCult()
	var/datum/game_mode/clockwork_cult/temp = new
	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	if(config.protect_assistant_from_antagonist)
		temp.restricted_jobs += "Assistant"

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in player_list)
		if(ROLE_SERVANT_OF_RATVAR in applicant.client.prefs.be_special)
			var/turf/T = get_turf(applicant)
			if(applicant.stat == CONSCIOUS && applicant.mind && !applicant.mind.special_role && T.z == ZLEVEL_STATION)
				if(!jobban_isbanned(applicant, ROLE_SERVANT_OF_RATVAR) && !jobban_isbanned(applicant, "Syndicate"))
					if(temp.age_check(applicant.client))
=======
/datum/admins/proc/makeCult()


	var/datum/game_mode/cult/temp = new
	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in get_active_candidates(ROLE_CULTIST))
		if(applicant.stat == CONSCIOUS)
			if(applicant.mind)
				if(!applicant.mind.special_role)
					if(!jobban_isbanned(applicant, "cultist") && !jobban_isbanned(applicant, "Syndicate"))
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
						if(!(applicant.job in temp.restricted_jobs))
							candidates += applicant

	if(candidates.len)
		var/numCultists = min(candidates.len, 4)

		for(var/i = 0, i<numCultists, i++)
			H = pick(candidates)
<<<<<<< HEAD
			H << "<span class='heavy_brass'>The world before you suddenly glows a brilliant yellow. You hear the whooshing steam and clanking cogs of a billion billion machines, and all at once \
			you see the truth. Ratvar, the Clockwork Justiciar, lies derelict and forgotten in an unseen realm, and he has selected you as one of his harbringers. You are now a servant of \
			Ratvar, and you will bring him back.</span>"
			add_servant_of_ratvar(H, TRUE)
			ticker.mode.equip_servant(H)
			candidates.Remove(H)
=======
			H.mind.make_Cultist()
			candidates.Remove(H)
			temp.grant_runeword(H)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

		return 1

	return 0



/datum/admins/proc/makeNukeTeam()

<<<<<<< HEAD
	var/datum/game_mode/nuclear/temp = new
	var/list/mob/dead/observer/candidates = pollCandidates("Do you wish to be considered for a nuke team being sent in?", "operative", temp)
	var/list/mob/dead/observer/chosen = list()
	var/mob/dead/observer/theghost = null
=======

	var/list/mob/dead/observer/candidates = list()
	var/mob/dead/observer/theghost = null
	var/list/mob/dead/observer/picked = list()

	for(var/mob/dead/observer/G in get_active_candidates(ROLE_OPERATIVE,poll="Do you wish to be considered for a nuke team being sent in?"))
		if(!jobban_isbanned(G, "operative") && !jobban_isbanned(G, "Syndicate"))
			candidates += G
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

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
<<<<<<< HEAD
				chosen += theghost
				agentcount++
				break
		//Making sure we have atleast 3 Nuke agents, because less than that is kinda bad
		if(agentcount < 3)
			return 0

		var/nuke_code = random_nukecode()

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
=======
/* Seeing if we have enough agents before we make the nuke team
				var/mob/living/carbon/human/new_character=makeBody(theghost)
				new_character.mind.make_Nuke()
*/
				picked += theghost
				agentcount++
				break
//This is so we don't get a nuke team with only 1 or 2 people
		if(agentcount < 3)
			return 0
		else
			for(var/mob/j in picked)
				theghost = j
				var/mob/living/carbon/human/new_character=makeBody(theghost)
				new_character.mind.make_Nuke()

		var/obj/effect/landmark/nuke_spawn = locate("landmark*Nuclear-Bomb")
		var/obj/effect/landmark/closet_spawn = locate("landmark*Syndicate-Uplink")

		var/nuke_code = "[rand(10000, 99999)]"

		if(nuke_spawn)
			var/obj/item/weapon/paper/P = new
			P.info = "Sadly, the Syndicate could not get you a nuclear bomb.  We have, however, acquired the arming code for the station's onboard nuke.  The nuclear authorization code is: <b>[nuke_code]</b>"
			P.name = "nuclear bomb code and instructions"
			P.loc = nuke_spawn.loc

		if(closet_spawn)
			new /obj/structure/closet/syndicate/nuclear(closet_spawn.loc)

		for (var/obj/effect/landmark/A in /area/syndicate_station/start)//Because that's the only place it can BE -Sieve
			if (A.name == "Syndicate-Gear-Closet")
				new /obj/structure/closet/syndicate/personal(A.loc)
				del(A)
				continue

			if (A.name == "Syndicate-Bomb")
				new /obj/effect/spawner/newbomb/timer/syndicate(A.loc)
				del(A)
				continue

		for(var/datum/mind/synd_mind in ticker.mode.syndicates)
			if(synd_mind.current)
				if(synd_mind.current.client)
					for(var/image/I in synd_mind.current.client.images)
						if(I.icon_state == "synd")
							//del(I)
							synd_mind.current.client.images -= I

		for(var/datum/mind/synd_mind in ticker.mode.syndicates)
			if(synd_mind.current)
				if(synd_mind.current.client)
					for(var/datum/mind/synd_mind_1 in ticker.mode.syndicates)
						if(synd_mind_1.current)
							var/I = image('icons/mob/mob.dmi', loc = synd_mind_1.current, icon_state = "synd")
							synd_mind.current.client.images += I

		for (var/obj/machinery/nuclearbomb/bomb in machines)
			bomb.r_code = nuke_code						// All the nukes are set to this code.
	return 1
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488





/datum/admins/proc/makeAliens()
<<<<<<< HEAD
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
			var/turf/T = get_turf(applicant)
			if(applicant.stat == CONSCIOUS && applicant.mind && !applicant.mind.special_role && T.z == ZLEVEL_STATION)
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
	new /datum/round_event/ghost_role/abductor
	return 1

/datum/admins/proc/makeRevenant()
	new /datum/round_event/ghost_role/revenant
	return 1
=======
	alien_infestation(3)
	return 1
/datum/admins/proc/makeDeathsquad()
	var/list/mob/dead/observer/candidates = list()
	var/mob/dead/observer/theghost = null
	var/input = "Purify the station."
	if(prob(10))
		input = "Save Runtime and any other cute things on the station."

	var/syndicate_leader_selected = 0 //when the leader is chosen. The last person spawned.

	//Generates a list of commandos from active ghosts. Then the user picks which characters to respawn as the commandos.
	for(var/mob/dead/observer/G in get_active_candidates(ROLE_COMMANDO, poll="Do you wish to be considered for an elite syndicate strike team being sent in?"))
		if(!jobban_isbanned(G, "operative") && !jobban_isbanned(G, "Syndicate"))
			candidates += G

	for(var/mob/dead/observer/G in candidates)
		if(!G.key)
			candidates.Remove(G)

	if(candidates.len)
		var/numagents = 6
		//Spawns commandos and equips them.
		for (var/obj/effect/landmark/L in /area/syndicate_mothership/elite_squad)
			if(numagents<=0)
				break
			if (L.name == "Syndicate-Commando")
				syndicate_leader_selected = numagents == 1?1:0

				var/mob/living/carbon/human/new_syndicate_commando = create_syndicate_death_commando(L, syndicate_leader_selected)


				while((!theghost || !theghost.client) && candidates.len)
					theghost = pick(candidates)
					candidates.Remove(theghost)

				if(!theghost)
					del(new_syndicate_commando)
					break

				new_syndicate_commando.key = theghost.key
				new_syndicate_commando.internal = new_syndicate_commando.s_store
				new_syndicate_commando.internals.icon_state = "internal1"

				//So they don't forget their code or mission.


				to_chat(new_syndicate_commando, "<span class='notice'>You are an Elite Syndicate. [!syndicate_leader_selected?"commando":"<B>LEADER</B>"] in the service of the Syndicate. \nYour current mission is: <span class='danger'> [input]</span></span>")

				numagents--
		if(numagents >= 6)
			return 0

		for (var/obj/effect/landmark/L in /area/shuttle/syndicate_elite)
			if (L.name == "Syndicate-Commando-Bomb")
				new /obj/effect/spawner/newbomb/timer/syndicate(L.loc)

	return 1


/proc/makeBody(var/mob/dead/observer/G_found) // Uses stripped down and bastardized code from respawn character
	if(!G_found || !G_found.key)	return

	//First we spawn a dude.
	var/mob/living/carbon/human/new_character = new(pick(latejoin))//The mob being spawned.

	new_character.gender = pick(MALE,FEMALE)

	var/datum/preferences/A = new()
	A.randomize_appearance_for(new_character)
	new_character.generate_name()
	new_character.age = rand(17,45)

	new_character.dna.ready_dna(new_character)
	new_character.key = G_found.key

	return new_character

/datum/admins/proc/create_syndicate_death_commando(obj/spawn_location, syndicate_leader_selected = 0)
	var/mob/living/carbon/human/new_syndicate_commando = new(spawn_location.loc)
	var/syndicate_commando_leader_rank = pick("Lieutenant", "Captain", "Major")
	var/syndicate_commando_rank = pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant 1st Class", "Master Sergeant", "Sergeant Major")
	var/syndicate_commando_name = pick(last_names)

	new_syndicate_commando.gender = pick(MALE, FEMALE)

	var/datum/preferences/A = new()//Randomize appearance for the commando.
	A.randomize_appearance_for(new_syndicate_commando)

	new_syndicate_commando.real_name = "[!syndicate_leader_selected ? syndicate_commando_rank : syndicate_commando_leader_rank] [syndicate_commando_name]"
	new_syndicate_commando.name = new_syndicate_commando.real_name
	new_syndicate_commando.age = !syndicate_leader_selected ? rand(23,35) : rand(35,45)

	new_syndicate_commando.dna.ready_dna(new_syndicate_commando)//Creates DNA.

	//Creates mind stuff.
	new_syndicate_commando.mind_initialize()
	new_syndicate_commando.mind.assigned_role = "MODE"
	new_syndicate_commando.mind.special_role = "Syndicate Commando"

	//Adds them to current traitor list. Which is really the extra antagonist list.
	ticker.mode.traitors += new_syndicate_commando.mind
	new_syndicate_commando.equip_syndicate_commando(syndicate_leader_selected)

	return new_syndicate_commando

/datum/admins/proc/makeVoxRaiders()


	var/list/mob/dead/observer/candidates = list()
	var/mob/dead/observer/theghost = null
	var/input = "Disregard shinies, acquire hardware."

	var/leader_chosen = 0 //when the leader is chosen. The last person spawned.

	//Generates a list of candidates from active ghosts.
	for(var/mob/dead/observer/G in get_active_candidates(ROLE_VOXRAIDER, poll="Do you wish to be considered for a vox raiding party arriving on the station?"))
		candidates += G

	for(var/mob/dead/observer/G in candidates)
		if(!G.key)
			candidates.Remove(G)

	if(candidates.len)
		var/max_raiders = 1
		var/raiders = max_raiders
		//Spawns vox raiders and equips them.
		for (var/obj/effect/landmark/L in landmarks_list)
			if(L.name == "voxstart")
				if(raiders<=0)
					break

				var/mob/living/carbon/human/new_vox = create_vox_raider(L, leader_chosen)

				while((!theghost || !theghost.client) && candidates.len)
					theghost = pick(candidates)
					candidates.Remove(theghost)

				if(!theghost)
					del(new_vox)
					break

				new_vox.key = theghost.key
				to_chat(new_vox, "<span class='notice'>You are a Vox Primalis, fresh out of the Shoal. Your ship has arrived at the Tau Ceti system hosting the NSV Exodus... or was it the Luna? NSS? Utopia? Nobody is really sure, but everyong is raring to start pillaging! Your current goal is: <span class='danger'> [input]</span></span>")
				to_chat(new_vox, "<span class='warning'>Don't forget to turn on your nitrogen internals!</span>")

				raiders--
			if(raiders > max_raiders)
				return 0
	else
		return 0
	return 1

/datum/admins/proc/create_vox_raider(obj/spawn_location, leader_chosen = 0)


	var/mob/living/carbon/human/new_vox = new(spawn_location.loc)

	new_vox.setGender(pick(MALE, FEMALE))
	new_vox.h_style = "Short Vox Quills"
	new_vox.regenerate_icons()

	new_vox.age = rand(12,20)

	new_vox.dna.ready_dna(new_vox) // Creates DNA.
	new_vox.dna.mutantrace = "vox"
	new_vox.set_species("Vox") // Actually makes the vox! How about that.
	new_vox.generate_name()
	//new_vox.add_language("Vox-pidgin")
	new_vox.mind_initialize()
	new_vox.mind.assigned_role = "MODE"
	new_vox.mind.special_role = "Vox Raider"
	new_vox.mutations |= M_NOCLONE //Stops the station crew from messing around with their DNA.

	ticker.mode.traitors += new_vox.mind
	new_vox.equip_vox_raider()

	return new_vox
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
