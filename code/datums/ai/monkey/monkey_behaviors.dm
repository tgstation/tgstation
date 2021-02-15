/datum/ai_behavior/battle_screech/monkey
	screeches = list("roar","screech")

/datum/ai_behavior/monkey_equip
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/monkey_equip/finish_action(datum/ai_controller/controller, success)
	. = ..()

	if(!success) //Don't try again on this item if we failed
		var/list/item_blacklist = controller.blackboard[BB_MONKEY_BLACKLISTITEMS]
		var/obj/item/target = controller.blackboard[BB_MONKEY_PICKUPTARGET]

		item_blacklist[target] = TRUE

	controller.blackboard[BB_MONKEY_PICKUPTARGET] = null

/datum/ai_behavior/monkey_equip/proc/equip_item(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn

	var/obj/item/target = controller.blackboard[BB_MONKEY_PICKUPTARGET]
	var/best_force = controller.blackboard[BB_MONKEY_BEST_FORCE_FOUND]

	if(!target)
		finish_action(controller, FALSE)
		return

	if(target.anchored) //Can't pick it up, so stop trying.
		finish_action(controller, FALSE)
		return

	// Strong weapon
	else if(target.force > best_force)
		living_pawn.put_in_hands(target)
		controller.blackboard[BB_MONKEY_BEST_FORCE_FOUND] = target.force
		finish_action(controller, TRUE)
		return

	else if(target.slot_flags) //Clothing == top priority
		living_pawn.dropItemToGround(target, TRUE)
		living_pawn.update_icons()
		if(!living_pawn.equip_to_appropriate_slot(target))
			finish_action(controller, FALSE)
			return //Already wearing something, in the future this should probably replace the current item but the code didn't actually do that, and I dont want to support it right now.
		finish_action(controller, TRUE)
		return

	// EVERYTHING ELSE
	else if(living_pawn.get_empty_held_index_for_side(LEFT_HANDS) || living_pawn.get_empty_held_index_for_side(RIGHT_HANDS))
		living_pawn.put_in_hands(target)
		finish_action(controller, TRUE)
		return



	finish_action(controller, FALSE)

/datum/ai_behavior/monkey_equip/ground
	required_distance = 0

/datum/ai_behavior/monkey_equip/ground/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	equip_item(controller)

/datum/ai_behavior/monkey_equip/pickpocket

/datum/ai_behavior/monkey_equip/pickpocket/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	if(controller.blackboard[BB_MONKEY_PICKPOCKETING]) //We are pickpocketing, don't do ANYTHING!!!!
		return
	INVOKE_ASYNC(src, .proc/attempt_pickpocket, controller)

/datum/ai_behavior/monkey_equip/pickpocket/proc/attempt_pickpocket(datum/ai_controller/controller)
	var/obj/item/target = controller.blackboard[BB_MONKEY_PICKUPTARGET]

	var/mob/living/victim = target.loc

	var/mob/living/living_pawn = controller.pawn

	victim.visible_message("<span class='warning'>[living_pawn] starts trying to take [target] from [controller.current_movement_target]!</span>", "<span class='danger'>[living_pawn] tries to take [target]!</span>")

	controller.blackboard[BB_MONKEY_PICKPOCKETING] = TRUE

	var/success = FALSE

	if(do_mob(living_pawn, victim, MONKEY_ITEM_SNATCH_DELAY) && target)

		for(var/obj/item/I in victim.held_items)
			if(I == target)
				victim.visible_message("<span class='danger'>[living_pawn] snatches [target] from [victim].</span>", "<span class='userdanger'>[living_pawn] snatched [target]!</span>")
				if(victim.temporarilyRemoveItemFromInventory(target))
					if(!QDELETED(target) && !equip_item(controller))
						target.forceMove(living_pawn.drop_location())
						success = TRUE
						break
				else
					victim.visible_message("<span class='danger'>[living_pawn] tried to snatch [target] from [victim], but failed!</span>", "<span class='userdanger'>[living_pawn] tried to grab [target]!</span>")

	finish_action(controller, success) //We either fucked up or got the item.

/datum/ai_behavior/monkey_equip/pickpocket/finish_action(datum/ai_controller/controller, success)
	. = ..()
	controller.blackboard[BB_MONKEY_PICKPOCKETING] = FALSE
	controller.blackboard[BB_MONKEY_PICKUPTARGET] = null

/datum/ai_behavior/monkey_flee

/datum/ai_behavior/monkey_flee/perform(delta_time, datum/ai_controller/controller)
	. = ..()

	var/mob/living/living_pawn = controller.pawn

	if(living_pawn.health >= MONKEY_FLEE_HEALTH)
		finish_action(controller, TRUE) //we're back in bussiness

	var/mob/living/target = null

	// flee from anyone who attacked us and we didn't beat down
	for(var/mob/living/L in view(living_pawn, MONKEY_FLEE_VISION))
		if(controller.blackboard[BB_MONKEY_ENEMIES][L] && L.stat == CONSCIOUS)
			target = L
			break

	if(target)
		walk_away(living_pawn, target, MONKEY_ENEMY_VISION, 5)
	else
		finish_action(controller, TRUE)

/datum/ai_behavior/monkey_attack_mob
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM //performs to increase frustration

/datum/ai_behavior/monkey_attack_mob/perform(delta_time, datum/ai_controller/controller)
	. = ..()

	var/mob/living/target = controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET]
	var/mob/living/living_pawn = controller.pawn

	if(!target || target.stat != CONSCIOUS)
		finish_action(controller, TRUE) //Target == owned

	if(living_pawn.Adjacent(target) && isturf(target.loc) && !IS_DEAD_OR_INCAP(living_pawn)) // if right next to perp
		// check if target has a weapon
		var/obj/item/W
		for(var/obj/item/I in target.held_items)
			if(!(I.item_flags & ABSTRACT))
				W = I
				break

		// if the target has a weapon, chance to disarm them
		if(W && DT_PROB(MONKEY_ATTACK_DISARM_PROB, delta_time))
			living_pawn.a_intent = INTENT_DISARM
			monkey_attack(controller, target, delta_time)
		else
			living_pawn.a_intent = INTENT_HARM
			monkey_attack(controller, target, delta_time)


/datum/ai_behavior/monkey_attack_mob/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	walk(living_pawn, 0)
	controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET] = null

/// attack using a held weapon otherwise bite the enemy, then if we are angry there is a chance we might calm down a little
/datum/ai_behavior/monkey_attack_mob/proc/monkey_attack(datum/ai_controller/controller, mob/living/target, delta_time)

	var/mob/living/living_pawn = controller.pawn

	if(living_pawn.next_move > world.time)
		return

	living_pawn.changeNext_move(CLICK_CD_MELEE) //We play fair

	var/obj/item/weapon = locate(/obj/item) in living_pawn.held_items

	living_pawn.face_atom(target)

	// attack with weapon if we have one
	if(weapon)
		weapon.melee_attack_chain(living_pawn, target)
	else
		living_pawn.UnarmedAttack(target)
	// no de-aggro
	if(controller.blackboard[BB_MONKEY_AGRESSIVE])
		return

	if(DT_PROB(MONKEY_HATRED_REDUCTION_PROB, delta_time))
		controller.blackboard[BB_MONKEY_ENEMIES][target]--

	// if we are not angry at our target, go back to idle
	if(controller.blackboard[BB_MONKEY_ENEMIES][target] <= 0)
		var/list/enemies = controller.blackboard[BB_MONKEY_ENEMIES]
		enemies.Remove(target)
		if(controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET] == target)
			finish_action(controller, TRUE)

/datum/ai_behavior/disposal_mob
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM //performs to increase frustration

/datum/ai_behavior/disposal_mob/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET] = null //Reset attack target
	controller.blackboard[BB_MONKEY_DISPOSING] = FALSE //No longer disposing
	controller.blackboard[BB_MONKEY_TARGET_DISPOSAL] = null //No target disposal

/datum/ai_behavior/disposal_mob/perform(delta_time, datum/ai_controller/controller)
	. = ..()

	if(controller.blackboard[BB_MONKEY_DISPOSING]) //We are disposing, don't do ANYTHING!!!!
		return

	var/mob/living/target = controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET]
	var/mob/living/living_pawn = controller.pawn

	controller.current_movement_target = target

	if(target.pulledby != living_pawn && !HAS_AI_CONTROLLER_TYPE(target.pulledby, /datum/ai_controller/monkey)) //Dont steal from my fellow monkeys.
		if(living_pawn.Adjacent(target) && isturf(target.loc))
			living_pawn.a_intent = INTENT_GRAB
			target.grabbedby(living_pawn)
		return //Do the rest next turn

	var/obj/machinery/disposal/disposal = controller.blackboard[BB_MONKEY_TARGET_DISPOSAL]
	controller.current_movement_target = disposal

	if(living_pawn.Adjacent(disposal))
		INVOKE_ASYNC(src, .proc/try_disposal_mob, controller) //put him in!
	else //This means we might be getting pissed!
		return

/datum/ai_behavior/disposal_mob/proc/try_disposal_mob(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/mob/living/target = controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET]
	var/obj/machinery/disposal/disposal = controller.blackboard[BB_MONKEY_TARGET_DISPOSAL]

	controller.blackboard[BB_MONKEY_DISPOSING] = TRUE

	if(target && disposal?.stuff_mob_in(target, living_pawn))
		disposal.flush()
	finish_action(controller, TRUE)


/datum/ai_behavior/recruit_monkeys/perform(delta_time, datum/ai_controller/controller)
	. = ..()

	controller.blackboard[BB_MONKEY_RECRUIT_COOLDOWN] = world.time + MONKEY_RECRUIT_COOLDOWN
	var/mob/living/living_pawn = controller.pawn

	for(var/mob/living/L in view(living_pawn, MONKEY_ENEMY_VISION))
		if(!HAS_AI_CONTROLLER_TYPE(L, /datum/ai_controller/monkey))
			continue

		if(!DT_PROB(MONKEY_RECRUIT_PROB, delta_time))
			continue
		var/datum/ai_controller/monkey/monkey_ai = L.ai_controller
		var/atom/your_enemy = controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET]
		var/list/enemies = L.ai_controller.blackboard[BB_MONKEY_ENEMIES]
		enemies[your_enemy] = MONKEY_RECRUIT_HATED_AMOUNT
		monkey_ai.blackboard[BB_MONKEY_RECRUIT_COOLDOWN] = world.time + MONKEY_RECRUIT_COOLDOWN
	finish_action(controller, TRUE)
