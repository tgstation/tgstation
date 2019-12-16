/datum/goap_info_provider/monkey/GetWorldState(datum/goap_agent/agent)
	. = list()
	.["GUN"] = FALSE
	.["attackEnemy"] = FALSE
	.["disposeEnemy"] = FALSE
	.["Flee"] = FALSE
	.["disarmAvailable"] = FALSE
	.["enemyGrabbed"] = FALSE
	.["replaceItem"] = FALSE
	var/mob/living/carbon/monkey/C = AGENT
	var/obj/item/W = locate() in C.held_items
	if(W)
		.["hasItem"] = TRUE
		.["hasHumanItem"] = TRUE
		.["grabbedWeapon"] = TRUE
		if(isgun(W))
			var/obj/item/gun/G = W
			if(G && G.chambered && G.chambered.BB) // we got a loaded gun!
				.["GUN"] = TRUE
	else
		C.best_force = 0
		.["hasItem"] = FALSE
		.["hasHumanItem"] = FALSE
		.["grabbedWeapon"] = FALSE
	if(C.pulling)
		.["enemyGrabbed"] = TRUE
	var/mob/living/carbon/T = locate(/mob/living/carbon) in view(4, AGENT)
	if(T && T.held_items)
		if(prob(MONKEY_ATTACK_DISARM_PROB)) // this runs more than monkeys handle_combat did
			.["disarmAvailable"] = TRUE

/datum/goap_info_provider/monkey/GetGoal(datum/goap_agent/agent)
	. = list()
	var/mob/living/carbon/monkey/C = AGENT
	var/obj/item/W = locate() in C.held_items
	var/itemobtainable = FALSE
	if(length(C.enemies))
		var/list/around = view(MONKEY_ENEMY_VISION, C)
		for(var/mob/living/L in around)
			if(!C.should_target(L))
				continue
			if(!L.stat) // conscious
				if(C.health < MONKEY_FLEE_HEALTH)
					.["Flee"] = TRUE
					return // we don't care about any goals other than this
				.["attackEnemy"] = TRUE // we have a target
				break
			else if(locate(/obj/machinery/disposal) in around)
				if(!L.pulledby || C == L.pulledby) // we're not holding them and nobody else has got rid of them and we're not in combat
					.["disposeEnemy"] = TRUE // they're not conscious, lets trash them will automatically grab
					return // don't worry about getting items if we're just disposalling someone
	if(W && isgun(W)) // we have an item and its a gun
		return
	var/list/itemview = oview(4, AGENT)
	if(!W) // we aren't holding something already
		for(var/obj/item/I in itemview)
			if(I && !C.blacklistItems[I] && I.force)
				if(agent.has_action(/datum/goap_action/monkey/GetItem))
					itemobtainable = TRUE
					.["hasItem"] = TRUE
					break
		var/mob/living/carbon/human/H = locate(/mob/living/carbon/human) in itemview
		if(H && agent.has_action(/datum/goap_action/monkey/pickpocket) && !itemobtainable)
			for(var/obj/item/G in H.held_items)
				if(G && !C.blacklistItems[G] && G.force > C.best_force)
					itemobtainable = TRUE
					.["hasHumanItem"] = TRUE
					break
	else if(!isgun(W))
		for(var/obj/item/V in itemview)
			if(V && !C.blacklistItems[V] && V.force > W.force || isgun(V))
				if(agent.has_action(/datum/goap_action/monkey/throwitem))
					.["replaceItem"] = TRUE
					break
