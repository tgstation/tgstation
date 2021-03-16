
/datum/round_event_control/undead
	name = "Raise Dead"
	typepath = /datum/round_event/ghost_role/undead
	weight = 10

/datum/round_event/ghost_role/undead
	minimum_required = 1
	role_name = "friendly zombie"
	var/spawns = 3
	fakeable = TRUE

/datum/round_event/ghost_role/undead/announce(fake)
	var/source = pick("a powerful spell from a far away wizard", "a strange anomalous enegy", "the influence of a high level necromancer", "the power of love", "the will of an omnipotent God", "\[REDACTED\]")
	var/purpose = pick("party like there's no tomorrow", "seek employment", "partake in the democratic process", "fulfill their new year's promises", "have an after-life crysis", "preach about their new religion", "answer your questions about life, the universe, and everything", "persuade you not to treat them like their brain eating counterparts", "repair their past mistakes", "\[REDACTED\]")

	priority_announce("Your station has been subjected to [source]. Some dead bodies have come back to life to [purpose]. On behalf of Nanotrasen, please welcome these former employees as your new coworkers!","[command_name()] Medium-Priority Update")

/datum/round_event/ghost_role/undead/spawn_role()
	var/list/mob/dead/observer/candidates = get_candidates(ROLE_LAVALAND, null, ROLE_LAVALAND)
	
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS
	
	var/list/dead_bodies = list()
	
	//Search for living human bodies
	for(var/mob/living/carbon/human/body in GLOB.dead_mob_list) //look for any dead bodies
	
		if (istype(body) && body.getBruteLoss() + body.getFireLoss() < 300 && body.getorgan(/obj/item/organ/heart) && body.getorgan(/obj/item/organ/brain) && !body.get_ghost(FALSE))
			var/turf/T = get_turf(body)
			//check if they are on the station level
			if(T && is_station_level(T.z))
				//check if they fit the conditions	
				LAZYADD(dead_bodies,body)			
	
	if(!dead_bodies.len)
		return WAITING_FOR_SOMETHING

	//Coprses have been found, start giving them life
	var/revived_zeds = min(spawns,candidates.len,dead_bodies.len)
	while(revived_zeds > 0)
		var/mob/living/carbon/human/zombie = popleft(dead_bodies)
		var/mob/dead/observer/ghost = pick_n_take(candidates)

		revived_zeds--
		zombie.key = ghost.key
		zombie.grab_ghost()
				
		//Zombify
		zombie.set_species(/datum/species/zombie)

		zombie.revive(full_heal = TRUE, admin_revive = FALSE)
		zombie.regenerate_organs()

		LAZYADD(spawned_mobs, zombie)

		//Flavortext
		to_chat(zombie, "<span class='userdanger'>Welcome back!</span>")
		to_chat(zombie, "<span class='warning'>An unknown source of energy, be it magic or science, has put you back into your body! You have no memory of your past life, but others may have memory of you! You are not an antagonist, and shouldn't act as such.</span>")

	return SUCCESSFUL_SPAWN
