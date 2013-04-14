var/is_gettingdatfukkendiskwithmagic = 0
/datum/game_mode/proc/makeMalfAImode()

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


/datum/game_mode/proc/makeCTratiors()
	var/list/mob/dead/observer/candidates = list()
	var/mob/dead/observer/theghost = null
	var/time_passed = world.time

	for(var/mob/dead/observer/G in player_list)
		if(!jobban_isbanned(G, "wizard") && !jobban_isbanned(G, "Syndicate"))
			spawn(0)
				switch(alert(G, "Your random role is: Traitor","Please answer in 30 seconds!","Become Traitor"))
					if("Become Traitor")
						if((world.time-time_passed)>300)//If more than 30 game seconds passed.
							return
						candidates += G

	sleep(50)

	if(candidates.len)
		shuffle(candidates)
		for(var/mob/i in candidates)
			if(!i || !i.client) continue //Dont bother removing them from the list since we only grab one wizard

			theghost = i
			break

	if(theghost)
		var/mob/living/carbon/human/new_character=makeBody(theghost)
		new_character.mind.make_Tratior()
		return 1

	return 0


/datum/game_mode/proc/makeCChanglings()

	var/list/mob/dead/observer/candidates = list()
	var/mob/dead/observer/theghost = null
	var/time_passed = world.time

	for(var/mob/dead/observer/G in player_list)
		if(!jobban_isbanned(G, "wizard") && !jobban_isbanned(G, "Syndicate"))
			spawn(0)
				switch(alert(G, "Your random role is: Changling","Random Role", "Become Changling"))
					if("Become Changling")
						if((world.time-time_passed)>300)//If more than 30 game seconds passed.
							return
						candidates += G
	sleep(50)

	if(candidates.len)
		shuffle(candidates)
		for(var/mob/i in candidates)
			if(!i || !i.client) continue //Dont bother removing them from the list since we only grab one wizard

			theghost = i
			break

	if(theghost)
		var/mob/living/carbon/human/new_character=makeBody(theghost)
		new_character.mind.make_Changling()
		return 1

	return 0
/datum/game_mode/proc/makeCRevs()
	var/list/mob/dead/observer/candidates = list()
	var/mob/dead/observer/theghost = null
	var/time_passed = world.time

	for(var/mob/dead/observer/G in player_list)
		if(!jobban_isbanned(G, "wizard") && !jobban_isbanned(G, "Syndicate"))
			spawn(0)
				switch(alert(G, "Your random role is: Head Revolutionary.","Random Role","Become Head Revolutionary"))
					if("Become Head Revolutionary")
						if((world.time-time_passed)>300)//If more than 30 game seconds passed.
							return
						candidates += G

	sleep(50)

	if(candidates.len)
		shuffle(candidates)
		for(var/mob/i in candidates)
			if(!i || !i.client) continue //Dont bother removing them from the list since we only grab one wizard

			theghost = i
			break

	if(theghost)
		var/mob/living/carbon/human/new_character=makeBody(theghost)
		new_character.mind.make_Rev()
		return 1

	return 0

/datum/game_mode/proc/makeCWizard()
	var/list/mob/dead/observer/candidates = list()
	var/mob/dead/observer/theghost = null
	var/time_passed = world.time

	for(var/mob/dead/observer/G in player_list)
		if(!jobban_isbanned(G, "wizard") && !jobban_isbanned(G, "Syndicate"))
			spawn(0)
				switch(alert(G, "Your random role is: Space Wizard.","Please answer in 30 seconds!","Become Space Wizard"))
					if("Become Space Wizard")
						is_gettingdatfukkendiskwithmagic = 1
						if((world.time-time_passed)>300)//If more than 30 game seconds passed.
							return
						candidates += G

	sleep(50)

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


/datum/game_mode/proc/makeCCult()
	var/list/mob/dead/observer/candidates = list()
	var/mob/dead/observer/theghost = null
	var/time_passed = world.time

	for(var/mob/dead/observer/G in player_list)
		if(!jobban_isbanned(G, "wizard") && !jobban_isbanned(G, "Syndicate"))
			spawn(0)
				switch(alert(G, "Your random role is: Cultist.","Random Role","Become Cultist"))
					if("Become Head Revolutionary")
						if((world.time-time_passed)>300)//If more than 30 game seconds passed.
							return
						candidates += G

	sleep(50)

	if(candidates.len)
		shuffle(candidates)
		for(var/mob/i in candidates)
			if(!i || !i.client) continue //Dont bother removing them from the list since we only grab one wizard

			theghost = i
			break

	if(theghost)
		var/mob/living/carbon/human/new_character=makeBody(theghost)
		new_character.mind.make_Cultist()
		return 1

	return 0




/datum/game_mode/proc/makeCNukeTeam()

	var/list/mob/dead/observer/candidates = list()
	var/mob/dead/observer/theghost = null
	var/time_passed = world.time

	for(var/mob/dead/observer/G in player_list)
		if(!jobban_isbanned(G, "operative") && !jobban_isbanned(G, "Syndicate"))
			spawn(0)
				switch(alert(G,"Your random role is: Nuclear Operative","Please answer in 30 seconds!","Become Nuke Operative"))
					if("Yes")
						is_gettingdatfukkendiskwithmagic = 1
						if((world.time-time_passed)>300)//If more than 30 game seconds passed.
							return
						candidates += G
					else
						return

	sleep(50)

	if(candidates.len)
		var/numagents = 5
		var/agentcount = 0

		for(var/i = 0, i<numagents,i++)
			shuffle(candidates) //More shuffles means more randoms
			for(var/mob/j in candidates)
				if(!j || !j.client)
					candidates.Remove(j)
					continue

				theghost = candidates
				candidates.Remove(theghost)

				var/mob/living/carbon/human/new_character=makeBody(theghost)
				new_character.mind.make_Nuke()

				agentcount++

		if(agentcount < 1)
			return 0

		var/obj/effect/landmark/nuke_spawn = locate("landmark*Nuclear-Bomb")
		var/obj/effect/landmark/closet_spawn = locate("landmark*Nuclear-Closet")

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
							del(I)

		for(var/datum/mind/synd_mind in ticker.mode.syndicates)
			if(synd_mind.current)
				if(synd_mind.current.client)
					for(var/datum/mind/synd_mind_1 in ticker.mode.syndicates)
						if(synd_mind_1.current)
							var/I = image('icons/mob/mob.dmi', loc = synd_mind_1.current, icon_state = "synd")
							synd_mind.current.client.images += I

		for (var/obj/machinery/nuclearbomb/bomb in world)
			bomb.r_code = nuke_code						// All the nukes are set to this code.

	return 1





/datum/game_mode/proc/makeAliens()
	new /datum/round_event/alien_infestation{spawncount=3}()
	return 1

/datum/game_mode/proc/makeSpaceNinja()
	new /datum/round_event/ninja()
	return 1

/* DEATH SQUADS
/datum/game_mode/proc/makeDeathsquad()
	var/list/mob/dead/observer/candidates = list()
	var/mob/dead/observer/theghost = null
	var/time_passed = world.time
	var/input = "Purify the station."
	if(prob(10))
		input = "Save Runtime and any other cute things on the station."

	var/syndicate_leader_selected = 0 //when the leader is chosen. The last person spawned.

	//Generates a list of commandos from active ghosts. Then the user picks which characters to respawn as the commandos.
	for(var/mob/dead/observer/G in player_list)
		spawn(0)
			switch(alert(G,"Do you wish to be considered for an elite syndicate strike team being sent in?","Please answer in 30 seconds!","Yes","No"))
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


				new_syndicate_commando << "\blue You are an Elite Syndicate. [!syndicate_leader_selected?"commando":"<B>LEADER</B>"] in the service of the Syndicate. \nYour current mission is: \red<B> [input]</B>"

				numagents--
		if(numagents >= 6)
			return 0

		for (var/obj/effect/landmark/L in /area/shuttle/syndicate_elite)
			if (L.name == "Syndicate-Commando-Bomb")
				new /obj/effect/spawner/newbomb/timer/syndicate(L.loc)

	return 1
*/

/datum/game_mode/proc/makeBody(var/mob/dead/observer/G_found) // Uses stripped down and bastardized code from respawn character
	if(!G_found || !G_found.key)	return

	//First we spawn a dude.
	var/mob/living/carbon/human/new_character = new(pick(latejoin))//The mob being spawned.

	new_character.gender = pick(MALE,FEMALE)

	var/datum/preferences/A = new()
	A.copy_to(new_character)

	new_character.dna.ready_dna(new_character)
	new_character.key = G_found.key
	// Here it determins if you are getting dat fukken disk or if you're a wizard, harry, so it can NOT replace essential items with the assigning a job.
	if(is_gettingdatfukkendiskwithmagic == 1)
		is_gettingdatfukkendiskwithmagic = 0
		return new_character
	else
		job_master.GiveRandomJob(new_character)
		job_master.EquipRank(new_character, new_character.mind.assigned_role, 1)
	return new_character
/* DEATH SQUADS
/datum/game_mode/proc/create_syndicate_death_commando(obj/spawn_location, syndicate_leader_selected = 0)
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
	*/