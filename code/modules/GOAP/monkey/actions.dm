/datum/goap_action/monkey/throwitem
	name = "Throw item"
	cost = 1
	cooldown = 20

/datum/goap_action/monkey/throwitem/New()
	..()
	preconditions = list()
	preconditions["GrabbedWeapon"] = TRUE
	preconditions["HasItem"] = TRUE
	preconditions["HasHumanItem"] = TRUE
	preconditions["GUN"] = FALSE // don't throw your gun!!
	effects = list()
	effects["ReplaceItem"] = TRUE

/datum/goap_action/monkey/throwitem/AdvancedPreconditions(mob/living/carbon/monkey/C, list/worldstate)
	var/obj/item/X = locate() in C.held_items
	if(!X)
		return FALSE
	for(var/mob/living/H in view(5, C))
		if(H.stat) // don't throw stuff at unconscious people
			continue
		if(C.should_target(H))
			target = H
			break
	if(!target)
		target = get_ranged_target_turf(C, C.dir, 10)
	return (target != null)

/datum/goap_action/monkey/throwitem/RequiresInRange(atom/agent)
	return FALSE

/datum/goap_action/monkey/throwitem/Perform(mob/living/carbon/monkey/C)
	var/obj/item/X = locate() in C.held_items
	if(X)
		X.forceMove(get_turf(C))
		X.throw_at(target, 10, 1, C)
		C.best_force = 0
		action_done = TRUE
	else
		action_done = TRUE
		return FALSE
	return ..()

/datum/goap_action/monkey/throwitem/CheckDone(atom/agent)
	return action_done

/datum/goap_action/monkey/GetItem
	name = "Grab an item"
	cost = 2

/datum/goap_action/monkey/GetItem/New()
	..()
	preconditions = list()
	preconditions["HasItem"] = FALSE
	effects = list()
	effects["HasItem"] = TRUE

/datum/goap_action/monkey/GetItem/AdvancedPreconditions(mob/living/carbon/monkey/C, list/worldstate)
	if(C.IsDeadOrIncap() || C.restrained())
		return FALSE
	for(var/obj/item/I in oview(4, C))
		if(!PATH_CHECK(src, I))
			continue
		if(!C.blacklistItems[I] && !HAS_TRAIT(I, TRAIT_NODROP))
			if(isgun(I))
				var/obj/item/gun/G = I
				if(!G.chambered || !G.chambered.BB)
					continue
				target = G
				break
			else if(I.force > C.best_force)
				C.best_force = I.force
				target = I
	return (target != null)

/datum/goap_action/monkey/GetItem/RequiresInRange(atom/agent)
	return TRUE

/datum/goap_action/monkey/GetItem/Perform(mob/living/carbon/monkey/C)
	C.drop_all_held_items() // who cares about these items, i want that one!
	C.equip_item(target)
	action_done = TRUE
	return ..()

/datum/goap_action/monkey/GetItem/PathingFailed(turf/failed, turf/current) // blacklist the item they couldn't get to
	. = ..()
	var/mob/living/carbon/monkey/C = locate() in current
	if(target)
		C.blacklistItems += target


/datum/goap_action/monkey/GetItem/CheckDone(atom/agent)
	return action_done

/datum/goap_action/monkey/pickpocket
	name = "Pickpocket Item"
	cost = 1

/datum/goap_action/monkey/pickpocket/New()
	..()
	preconditions = list()
	preconditions["HasHumanItem"] = FALSE
	preconditions["enemyAttack"] = FALSE
	effects = list()
	effects["HasHumanItem"] = TRUE

/datum/goap_action/monkey/pickpocket/AdvancedPreconditions(mob/living/carbon/monkey/C, list/worldstate)
	if(C.IsDeadOrIncap() || C.restrained())
		return FALSE
	for(var/mob/living/carbon/human/H in oview(4, C))
		if(!PATH_CHECK(src, H))
			continue
		for(var/obj/item/I in H.held_items)
			if(I && !C.blacklistItems[I] && I.force > C.best_force)
				target = H
				C.pickupTarget = I
				break
	return (C.pickupTarget != null)

/datum/goap_action/monkey/pickpocket/RequiresInRange(atom/agent)
	return TRUE

/datum/goap_action/monkey/pickpocket/Perform(mob/living/carbon/monkey/C)
	C.drop_all_held_items() // who cares about these items, i want that one!
	var/mob/M = target
	M.visible_message("<span class='warning'>[C] starts trying to take [C.pickupTarget] from [M]!</span>", "<span class='danger'>[C] tries to take [C.pickupTarget]!</span>")
	C.pickpocket(M)
	action_done = TRUE
	return ..()

/datum/goap_action/monkey/pickpocket/CheckDone(atom/agent)
	return action_done

/datum/goap_action/monkey/disarm
	name = "Disarm"
	cost = 2 // don't disarm if you can grab a weapon and attack with it
	cooldown = 20

/datum/goap_action/monkey/disarm/New()
	. = ..()
	preconditions = list()
	preconditions["AttackEnemy"] = FALSE
	preconditions["GrabbedWeapon"] = FALSE
	preconditions["DisarmAvailable"] = TRUE
	effects = list()
	effects["AttackEnemy"] = TRUE

/datum/goap_action/monkey/disarm/AdvancedPreconditions(mob/living/carbon/monkey/C, list/worldstate)
	if(!length(C.enemies))
		return FALSE
	var/list/around = view(MONKEY_ENEMY_VISION, C)
	for(var/mob/living/L in around)
		if(!C.should_target(L))
			continue
		if(L.stat || !L.held_items || !PATH_CHECK(src, L)) // unconscious or not holding anything
			continue
		target = L
		for(var/obj/item/I in L.held_items)
			if(!(I.item_flags & ABSTRACT))
				C.pickupTarget = I
		break
	return (target != null)

/datum/goap_action/monkey/disarm/RequiresInRange(atom/agent)
	return TRUE

/datum/goap_action/monkey/disarm/Perform(mob/living/carbon/monkey/C)
	C.a_intent = INTENT_DISARM
	C.monkey_attack(target)
	action_done = TRUE
	return ..()

/datum/goap_action/monkey/disarm/CheckDone(atom/agent)
	return action_done

/datum/goap_action/monkey/harm
	name = "Harm"
	cost = 3
	cooldown = 8

/datum/goap_action/monkey/harm/New()
	..()
	preconditions = list()
	preconditions["AttackEnemy"] = FALSE
	effects = list()
	effects["AttackEnemy"] = TRUE

/datum/goap_action/monkey/harm/AdvancedPreconditions(mob/living/carbon/monkey/C, list/worldstate)
	if(!length(C.enemies))
		return FALSE
	var/list/around = view(MONKEY_ENEMY_VISION, C)
	for(var/mob/living/L in around)
		if(!C.should_target(L))
			continue
		if(!L.stat && L.held_items && PATH_CHECK(src, L)) // conscious
			target = L
			break
	return (target != null)

/datum/goap_action/monkey/harm/RequiresInRange(atom/agent)
	return TRUE

/datum/goap_action/monkey/harm/Perform(mob/living/carbon/monkey/C)
	var/obj/item/Weapon = locate(/obj/item) in C.held_items
	var/mob/living/S = target
	C.a_intent = INTENT_HARM
	if(istype(Weapon, /obj/item/melee/classic_baton) && !S.incapacitated(TRUE, TRUE, FALSE, TRUE))
		var/obj/item/melee/classic_baton/B = Weapon
		if(!B.on)
			B.attack_self(C)
		C.a_intent = INTENT_HELP // stun em instead
	C.monkey_attack(target)
	action_done = TRUE
	return ..()

/datum/goap_action/monkey/harm/CheckDone(atom/agent)
	return action_done

/datum/goap_action/monkey/shoot
	name = "Oh crap monkeys got a gun!"
	cost = 1

/datum/goap_action/monkey/shoot/New()
	. = ..()
	preconditions = list()
	preconditions["AttackEnemy"] = FALSE
	preconditions["GUN"] = TRUE
	effects = list()
	effects["AttackEnemy"] = TRUE

/datum/goap_action/monkey/shoot/AdvancedPreconditions(mob/living/carbon/monkey/C, list/worldstate)
	var/obj/item/gun/G = locate() in C.held_items
	if(!G || !length(C.enemies))
		return FALSE
	var/list/around = view(MONKEY_ENEMY_VISION, C)
	for(var/mob/living/L in around)
		if(C.should_target(L))
			if(!L.stat) // conscious
				target = L
				break
	return (target != null)

/datum/goap_action/monkey/shoot/RequiresInRange(atom/agent)
	return FALSE

/datum/goap_action/monkey/shoot/Perform(mob/living/carbon/monkey/C)
	var/obj/item/gun/G = locate() in C.held_items
	C.battle_screech()
	if(!G.process_fire(target, C)) // it didn't work, we don't want it anymore!
		G.forceMove(get_turf(C))
		G.throw_at(target, 10, 1, C)
		C.blacklistItems += G
	action_done = TRUE
	return ..()

/datum/goap_action/monkey/shoot/CheckDone(atom/agent)
	return action_done

/datum/goap_action/monkey/grab
	name = "Grab corpse"
	cost = 1

/datum/goap_action/monkey/grab/New()
	..()
	preconditions = list()
	preconditions["EnemyGrabbed"] = FALSE
	effects = list()
	effects["EnemyGrabbed"] = TRUE

/datum/goap_action/monkey/grab/AdvancedPreconditions(mob/living/carbon/monkey/C, list/worldstate)
	var/list/around = view(MONKEY_ENEMY_VISION, C)
	for(var/mob/living/L in around)
		if(L.stat && L != C && PATH_CHECK(src, L)) // unconscious
			target = L
			break
	return (target != null)

/datum/goap_action/monkey/grab/RequiresInRange(atom/agent)
	return TRUE

/datum/goap_action/monkey/grab/Perform(mob/living/carbon/monkey/C)
	C.a_intent = INTENT_GRAB
	var/mob/living/M = target
	M.grabbedby(C)
	action_done = TRUE
	return ..()

/datum/goap_action/monkey/grab/CheckDone(atom/agent)
	return action_done


/datum/goap_action/monkey/disposal
	name = "Disposal body"
	cost = 1

/datum/goap_action/monkey/disposal/New()
	..()
	preconditions = list()
	preconditions["EnemyGrabbed"] = TRUE
	preconditions["DisposeEnemy"] = FALSE
	effects = list()
	effects["DisposeEnemy"] = TRUE

/datum/goap_action/monkey/disposal/AdvancedPreconditions(mob/living/carbon/monkey/C, list/worldstate)
	var/obj/machinery/disposal/D = locate() in view(MONKEY_ENEMY_VISION, C)
	target = D
	return (target != null)

/datum/goap_action/monkey/disposal/RequiresInRange(atom/agent)
	return TRUE

/datum/goap_action/monkey/disposal/Perform(mob/living/carbon/monkey/C)
	if(!C.pulling)
		action_done = TRUE
		return FALSE
	var/obj/machinery/disposal/D = target
	D.stuff_mob_in(C.pulling, C)
	action_done = TRUE
	return ..()

/datum/goap_action/monkey/disposal/CheckDone(atom/agent)
	return action_done

/datum/goap_action/monkey/flee
	name = "Flee"
	cost = 1

/datum/goap_action/monkey/flee/New()
	preconditions = list()
	preconditions["Flee"] = FALSE
	effects = list()
	effects["Flee"] = TRUE

/datum/goap_action/monkey/flee/AdvancedPreconditions(mob/living/carbon/monkey/C, list/worldstate)
	var/list/around = view(C, MONKEY_FLEE_VISION)
	// flee from anyone who attacked us and we didn't beat down
	for(var/mob/living/L in around)
		if(C.enemies[L] && !L.stat)
			target = L
	return (target != null)

/datum/goap_action/monkey/flee/RequiresInRange(atom/agent)
	return FALSE

/datum/goap_action/monkey/flee/Perform(atom/agent)
	walk_away(agent, target, MONKEY_ENEMY_VISION, 5)
	addtimer(VARSET_CALLBACK(src, action_done, TRUE), 20)
	return ..()

/datum/goap_action/monkey/flee/CheckDone(atom/agent)
	if(action_done)
		walk(agent, 0)
		return TRUE



















