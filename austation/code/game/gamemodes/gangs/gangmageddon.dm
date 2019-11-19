/datum/game_mode/hell_march
	name = "Gangmageddon"
	config_tag = "gangmageddon"
	antag_flag = ROLE_GANG
	restricted_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security")
	required_players = 25
	required_enemies = 3
	recommended_enemies = 6
	enemy_minimum_age = 14

	announce_span = "danger"
	announce_text = "A violent turf war has erupted on the station!\n\
	<span class='danger'>Gangsters</span>: Take over the station with a dominator.\n\
	<span class='notice'>Crew</span>: Prevent the gangs from expanding and initiating takeover."
	var/area/target_armory
	var/area/target_brig
	var/area/target_equip
	var/area/target_hos
	var/area/target_captain
	var/area/target_captain2
	var/area/target_science
	var/area/target_science2
	var/area/target_hop
	var/area/target_det
	var/area/target_ward
	var/area/target_atmos
	var/list/datum/mind/gangboss_candidates = list()
	var/gangs_to_create = 2
	var/bosses_per_gang = 1

/datum/game_mode/hell_march/pre_setup()

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	//Spawn more bosses depending on server population
	if(prob(num_players()) && num_players() > 1.5*required_players)
		gangs_to_create++
	if(prob(num_players()) && num_players() > 2*required_players)
		gangs_to_create++
	gangs_to_create = min(gangs_to_create, GLOB.possible_gangs.len)
	bosses_per_gang = CLAMP(FLOOR(antag_candidates.len / 3, 1), 1, 3)

	for(var/i in 1 to gangs_to_create)
		if(!antag_candidates.len)
			break
		for(var/j in 1 to bosses_per_gang)
			if(!antag_candidates.len)
				break
			var/datum/mind/bossman = pick_n_take(antag_candidates)
			antag_candidates -= bossman
			gangboss_candidates += bossman
			bossman.restricted_roles = restricted_jobs

	if(!gangboss_candidates.len)
		return FALSE

	SSjob.DisableJob(/datum/job/captain)
	SSjob.DisableJob(/datum/job/hop)
	SSjob.DisableJob(/datum/job/hos)
	SSjob.DisableJob(/datum/job/warden)
	SSjob.DisableJob(/datum/job/detective)
	SSjob.DisableJob(/datum/job/officer)
	SSjob.DisableJob(/datum/job/lawyer)
	SSjob.DisableJob(/datum/job/ai)
	SSjob.DisableJob(/datum/job/cyborg)

	// For removing problematic items
	target_armory = locate(/area/ai_monitored/security/armory) in GLOB.sortedAreas
	target_hos = locate(/area/crew_quarters/heads/hos) in GLOB.sortedAreas
	target_brig = locate(/area/security/brig) in GLOB.sortedAreas
	target_equip = locate(/area/security/main) in GLOB.sortedAreas
	target_ward = locate(/area/security/warden) in GLOB.sortedAreas
	target_det = locate(/area/security/detectives_office) in GLOB.sortedAreas
	target_captain = locate(/area/crew_quarters/heads/captain/private) in GLOB.sortedAreas
	target_hop = locate(/area/crew_quarters/heads/hop) in GLOB.sortedAreas
	target_science = locate(/area/science/research) in GLOB.sortedAreas
	target_science2 = locate(/area/science/mixing) in GLOB.sortedAreas
	target_atmos = locate(/area/engine/atmos) in GLOB.sortedAreas

	for(var/area/crew_quarters/heads/captain/C in GLOB.sortedAreas)
		if(C != /area/crew_quarters/heads/captain/private)
			target_captain2 = C
			break
	gangpocalypse()
	return TRUE

/datum/game_mode/hell_march/post_setup()
	set waitfor = FALSE
	..()
	var/list/all_gangs = GLOB.possible_gangs.Copy()
	for(var/i in 1 to gangs_to_create)
		if(!gangboss_candidates.len)
			break
		var/gang_type = pick_n_take(all_gangs)
		var/datum/team/gang/passione = new gang_type
		for(var/j in 1 to bosses_per_gang)
			if(!gangboss_candidates.len)
				break
			var/datum/mind/gangstar = pick_n_take(gangboss_candidates)
			passione.leaders += gangstar
			var/datum/antagonist/gang/boss/giorno = new
			gangstar.add_antag_datum(giorno, passione)
			giorno.equip_gang(FALSE, TRUE, TRUE, TRUE)
	for(var/mob/living/M in GLOB.player_list)
		if(!M.mind.has_antag_datum(/datum/antagonist/gang))
			M.mind.add_antag_datum(/datum/antagonist/vigilante)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/priority_announce, "Excessive costs associated with lawsuits from employees injured by Security and Synthetics have compelled us to re-evaluate the personnel budget for new stations. Accordingly, this station will be expected to operate without Security or Synthetic assistance. In the event that criminal enterprises seek to exploit this situation, we have implanted all crew with a device that will assist and incentivize the removal of all contraband and criminals.", "Nanotrasen Board of Directors"), 8 SECONDS)
	addtimer(CALLBACK(src, .proc/vigilante_vengeance), rand(12 MINUTES, 17 MINUTES))

/datum/game_mode/hell_march/proc/cleanup(area/target)
	if(target)
		for(var/turf/T in target.GetAllContents())
			CHECK_TICK
			for(var/obj/item/I in T.GetAllContents())
				if(istype(I, /obj/item/clothing))
					qdel(I)
				if(istype(I, /obj/item/gun))
					qdel(I)
				if(istype(I, /obj/item/transfer_valve))
					qdel(I)
			for(var/obj/machinery/vending/V in T.GetAllContents())
				for(var/datum/data/vending_product/R in (V.product_records + V.coin_records + V.hidden_records))
					if(R.product_path in (typesof(/obj/item/gun) + list(/obj/item/transfer_valve)))
						R.max_amount = 0
						R.amount = 0

/datum/game_mode/hell_march/proc/gangpocalypse()
	set waitfor = FALSE
	cleanup(target_captain)
	cleanup(target_captain2)
	cleanup(target_armory)
	cleanup(target_brig)
	cleanup(target_equip)
	cleanup(target_hos)
	cleanup(target_det)
	cleanup(target_ward)
	cleanup(target_hop)
	cleanup(target_science)
	cleanup(target_science2)
	if(target_atmos)
		for(var/turf/open/floor/engine/plasma/T in target_atmos.GetAllContents())
			CHECK_TICK
			T.ChangeTurf(/turf/open/floor/engine/airless)
			new /obj/structure/barricade/wooden(T)
		for(var/turf/open/floor/engine/n2o/T in target_atmos.GetAllContents())
			CHECK_TICK
			T.ChangeTurf(/turf/open/floor/engine/airless)
			new /obj/structure/barricade/wooden(T)
		for(var/turf/open/floor/engine/co2/T in target_atmos.GetAllContents())
			CHECK_TICK
			T.ChangeTurf(/turf/open/floor/engine/airless)
			new /obj/structure/barricade/wooden(T)


/datum/game_mode/hell_march/proc/vigilante_vengeance()
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Would you like be a part of a Vigilante posse?", ROLE_PAI, null, FALSE, 100)
	var/list/mob/dead/observer/finalists = list()
	var/posse_size = 1+round(GLOB.joined_player_list.len * 0.05)+round(world.time/5000)
	if(candidates.len)
		for(var/n in 1 to min(candidates.len,posse_size))
			finalists += pick_n_take(candidates)
	else
		message_admins("No ghosts were willing to join the posse")
		addtimer(CALLBACK(src, .proc/vigilante_vengeance), rand(3 MINUTES, 5 MINUTES))
		return
	for(var/i in 1 to finalists.len)
		var/mob/living/carbon/human/character = new(src)
		var/equip = SSjob.EquipRank(character, "Assistant", 1)
		character = equip
		SSjob.SendToLateJoin(character)
		GLOB.data_core.manifest_inject(character)
		SSshuttle.arrivals.QueueAnnounce(character, "Vigilante")
		GLOB.joined_player_list += character.ckey
		var/mob/dead/observer/spoo = pick_n_take(finalists)
		character.key = spoo.key
		character.mind.add_antag_datum(/datum/antagonist/vigilante)
		character.put_in_l_hand(new /obj/item/flashlight/flare/torch(character))
		character.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest/alt(character), ITEM_SLOT_OCLOTHING)
	addtimer(CALLBACK(src, .proc/vigilante_vengeance), rand(12 MINUTES, 17 MINUTES))

/obj/item/soap/vigilante
	name = "cleaning rag"
	desc = "All great things start with a little elbow grease."
	icon = 'icons/obj/toy.dmi'
	icon_state = "rag"
	cleanspeed = 35

/obj/item/soap/vigilante/ComponentInitialize()
	return // no slippery
