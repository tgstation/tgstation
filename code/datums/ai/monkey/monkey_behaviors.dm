/datum/ai_behavior/battle_screech/monkey
	screeches = list("roar","screech")

/datum/ai_behavior/monkey_equip
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/monkey_equip/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/obj/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/monkey_equip/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()

	if(!success) //Don't try again on this item if we failed
		controller.set_blackboard_key_assoc(BB_MONKEY_BLACKLISTITEMS, controller.blackboard[target_key], TRUE)

	controller.clear_blackboard_key(BB_MONKEY_PICKUPTARGET)

/// Equips an item on the monkey
/// Returns TRUE if it works out, FALSE otherwise
/datum/ai_behavior/monkey_equip/proc/equip_item(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn

	var/obj/item/target = controller.blackboard[BB_MONKEY_PICKUPTARGET]
	var/best_force = controller.blackboard[BB_MONKEY_BEST_FORCE_FOUND]
	if(!isturf(living_pawn.loc))
		return FALSE

	if(!target)
		return FALSE

	if(target.anchored) //Can't pick it up, so stop trying.
		return FALSE

	// Strong weapon
	else if(target.force > best_force)
		living_pawn.drop_all_held_items()
		living_pawn.put_in_hands(target)
		controller.set_blackboard_key(BB_MONKEY_BEST_FORCE_FOUND, target.force)
		return TRUE

	else if(target.slot_flags) //Clothing == top priority
		living_pawn.dropItemToGround(target, TRUE)
		living_pawn.update_icons()
		if(!living_pawn.equip_to_appropriate_slot(target))
			return FALSE //Already wearing something, in the future this should probably replace the current item but the code didn't actually do that, and I dont want to support it right now.
		return TRUE

	// EVERYTHING ELSE
	else if(living_pawn.get_empty_held_indexes())
		living_pawn.put_in_hands(target)
		return TRUE

	return FALSE

/datum/ai_behavior/monkey_equip/ground

/datum/ai_behavior/monkey_equip/ground/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	if(equip_item(controller))
		return . | AI_BEHAVIOR_SUCCEEDED
	return . | AI_BEHAVIOR_FAILED

/datum/ai_behavior/monkey_equip/pickpocket

/datum/ai_behavior/monkey_equip/pickpocket/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	if(controller.blackboard[BB_MONKEY_PICKPOCKETING]) //We are pickpocketing, don't do ANYTHING!!!!
		return
	INVOKE_ASYNC(src, PROC_REF(attempt_pickpocket), controller)

/datum/ai_behavior/monkey_equip/pickpocket/proc/attempt_pickpocket(datum/ai_controller/controller)
	var/obj/item/target = controller.blackboard[BB_MONKEY_PICKUPTARGET]
	var/mob/living/victim = target.loc
	var/mob/living/living_pawn = controller.pawn

	if(!istype(victim))
		finish_action(controller, FALSE)
		return

	victim.visible_message(span_warning("[living_pawn] starts trying to take [target] from [victim]!"), span_danger("[living_pawn] tries to take [target]!"))

	controller.set_blackboard_key(BB_MONKEY_PICKPOCKETING, TRUE)

	var/success = FALSE

	if(do_after(living_pawn, MONKEY_ITEM_SNATCH_DELAY, victim) && target && living_pawn.CanReach(victim))

		for(var/obj/item/I in victim.held_items)
			if(I == target)
				victim.visible_message(span_danger("[living_pawn] snatches [target] from [victim]."), span_userdanger("[living_pawn] snatched [target]!"))
				if(victim.temporarilyRemoveItemFromInventory(target))
					if(!QDELETED(target) && !equip_item(controller))
						target.forceMove(living_pawn.drop_location())
						success = TRUE
						break
				else
					victim.visible_message(span_danger("[living_pawn] tried to snatch [target] from [victim], but failed!"), span_userdanger("[living_pawn] tried to grab [target]!"))

	finish_action(controller, success) //We either fucked up or got the item.

/datum/ai_behavior/monkey_equip/pickpocket/finish_action(datum/ai_controller/controller, success)
	. = ..()
	controller.set_blackboard_key(BB_MONKEY_PICKPOCKETING, FALSE)
	controller.clear_blackboard_key(BB_MONKEY_PICKUPTARGET)

/datum/ai_behavior/monkey_flee

/datum/ai_behavior/monkey_flee/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn

	if(living_pawn.health >= MONKEY_FLEE_HEALTH) //we're back in bussiness
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	var/mob/living/target = null

	// flee from anyone who attacked us and we didn't beat down
	for(var/mob/living/L in view(living_pawn, MONKEY_FLEE_VISION))
		if(controller.blackboard[BB_MONKEY_ENEMIES][L] && L.stat == CONSCIOUS)
			target = L
			break

	if(target)
		GLOB.move_manager.move_away(living_pawn, target, max_dist=MONKEY_ENEMY_VISION, delay=5)
		return AI_BEHAVIOR_DELAY
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/monkey_attack_mob
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION //performs to increase frustration

/datum/ai_behavior/monkey_attack_mob/setup(datum/ai_controller/controller, target_key)
	. = ..()
	set_movement_target(controller, controller.blackboard[target_key])

/datum/ai_behavior/monkey_attack_mob/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/target = controller.blackboard[target_key]
	var/mob/living/living_pawn = controller.pawn
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(controller.blackboard[BB_TARGETING_STRATEGY])

	if(QDELETED(target) || !strategy.can_attack(living_pawn, target)) //Target == owned
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	// check if target has a weapon
	var/holding_weapon
	for(var/obj/item/potential_weapon in target.held_items)
		if(!(potential_weapon.item_flags & ABSTRACT))
			holding_weapon = potential_weapon
			break

	var/attack_results = monkey_attack(controller, target, seconds_per_tick, holding_weapon && SPT_PROB(MONKEY_ATTACK_DISARM_PROB, seconds_per_tick), holding_weapon)

	if(!attack_results || controller.blackboard[BB_MONKEY_AGGRESSIVE])
		return AI_BEHAVIOR_DELAY

	//check if we can de-aggro on the enemy...
	var/hatred_value = controller.blackboard[BB_MONKEY_ENEMIES][target]

	if(isnull(hatred_value))
		hatred_value = 1
		controller.set_blackboard_key_assoc(BB_MONKEY_ENEMIES, target, hatred_value)

	if(!SPT_PROB(MONKEY_HATRED_REDUCTION_PROB, seconds_per_tick))
		return AI_BEHAVIOR_DELAY

	//we decrease our hatred value to them by 1
	hatred_value--
	if(hatred_value <= 0)
		controller.remove_thing_from_blackboard_key(BB_MONKEY_ENEMIES, target)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	controller.set_blackboard_key_assoc(BB_MONKEY_ENEMIES, target, hatred_value)
	return AI_BEHAVIOR_DELAY

/datum/ai_behavior/monkey_attack_mob/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/// attack using a held weapon otherwise bite the enemy, then if we are angry there is a chance we might calm down a little
/datum/ai_behavior/monkey_attack_mob/proc/monkey_attack(datum/ai_controller/controller, mob/living/target, seconds_per_tick, disarm, holding_weapon)
	var/mob/living/living_pawn = controller.pawn

	if(living_pawn.next_move > world.time)
		return FALSE

	//are we holding a gun? can we shoot it? if so, FIRE
	var/obj/item/gun/gun_to_shoot = locate() in living_pawn.held_items
	if(gun_to_shoot?.can_shoot())
		if(gun_to_shoot != living_pawn.get_active_held_item())
			living_pawn.swap_hand(living_pawn.get_inactive_hand_index())
		controller.ai_interact(target = target, combat_mode = TRUE)
		return TRUE

	//look for any potential weapons we're holding
	var/obj/item/potential_weapon = locate() in living_pawn.held_items
	if(!living_pawn.CanReach(target, potential_weapon))
		return FALSE

	if(isnull(potential_weapon))
		controller.ai_interact(target = target, modifiers = disarm ? list(RIGHT_CLICK = TRUE) : null, combat_mode = TRUE)
		if(disarm && !isnull(holding_weapon) && controller.blackboard[BB_MONKEY_BLACKLISTITEMS][holding_weapon])
			controller.remove_thing_from_blackboard_key(BB_MONKEY_BLACKLISTITEMS, holding_weapon) //lets try to pickpocket it again!
		return TRUE

	if(potential_weapon != living_pawn.get_active_held_item())
		living_pawn.swap_hand(living_pawn.get_inactive_hand_index())
	controller.ai_interact(target = target, combat_mode = TRUE)
	return TRUE

/datum/ai_behavior/disposal_mob
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM //performs to increase frustration

/datum/ai_behavior/disposal_mob/setup(datum/ai_controller/controller, attack_target_key, disposal_target_key)
	. = ..()
	set_movement_target(controller, controller.blackboard[attack_target_key])

/datum/ai_behavior/disposal_mob/finish_action(datum/ai_controller/controller, succeeded, attack_target_key, disposal_target_key)
	. = ..()
	controller.clear_blackboard_key(attack_target_key) //Reset attack target
	controller.set_blackboard_key(BB_MONKEY_DISPOSING, FALSE) //No longer disposing
	controller.clear_blackboard_key(disposal_target_key) //No target disposal

/datum/ai_behavior/disposal_mob/perform(seconds_per_tick, datum/ai_controller/controller, attack_target_key, disposal_target_key)
	if(controller.blackboard[BB_MONKEY_DISPOSING]) //We are disposing, don't do ANYTHING!!!!
		return AI_BEHAVIOR_DELAY

	var/mob/living/target = controller.blackboard[attack_target_key]
	var/mob/living/living_pawn = controller.pawn

	set_movement_target(controller, target)

	if(!target)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(target.pulledby != living_pawn && !HAS_AI_CONTROLLER_TYPE(target.pulledby, /datum/ai_controller/monkey)) //Dont steal from my fellow monkeys.
		if(living_pawn.Adjacent(target) && isturf(target.loc))
			target.grabbedby(living_pawn)
		return AI_BEHAVIOR_DELAY //Do the rest next turn

	var/obj/machinery/disposal/disposal = controller.blackboard[disposal_target_key]
	set_movement_target(controller, disposal)

	if(!disposal)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(living_pawn.Adjacent(disposal))
		INVOKE_ASYNC(src, PROC_REF(try_disposal_mob), controller, attack_target_key, disposal_target_key) //put him in!
		return AI_BEHAVIOR_DELAY
	//This means we might be getting pissed!
	return AI_BEHAVIOR_DELAY

/datum/ai_behavior/disposal_mob/proc/try_disposal_mob(datum/ai_controller/controller, attack_target_key, disposal_target_key)
	var/mob/living/living_pawn = controller.pawn
	var/mob/living/target = controller.blackboard[attack_target_key]
	var/obj/machinery/disposal/disposal = controller.blackboard[disposal_target_key]

	controller.set_blackboard_key(BB_MONKEY_DISPOSING, TRUE)

	if(target && disposal?.stuff_mob_in(target, living_pawn))
		disposal.flush()
	finish_action(controller, TRUE, attack_target_key, disposal_target_key)


/datum/ai_behavior/recruit_monkeys/perform(seconds_per_tick, datum/ai_controller/controller)
	controller.set_blackboard_key(BB_MONKEY_RECRUIT_COOLDOWN, world.time + MONKEY_RECRUIT_COOLDOWN)
	var/mob/living/living_pawn = controller.pawn

	for(var/mob/living/nearby_monkey in view(living_pawn, MONKEY_ENEMY_VISION))
		if(QDELETED(nearby_monkey) || !HAS_AI_CONTROLLER_TYPE(nearby_monkey, /datum/ai_controller/monkey))
			continue
		if(!SPT_PROB(MONKEY_RECRUIT_PROB, seconds_per_tick))
			continue
		// Recruited a monkey to our side
		controller.set_blackboard_key(BB_MONKEY_RECRUIT_COOLDOWN, world.time + MONKEY_RECRUIT_COOLDOWN)
		// Other monkeys now also hate the guy we're currently targeting
		nearby_monkey.ai_controller.add_blackboard_key_assoc(BB_MONKEY_ENEMIES, controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET], MONKEY_RECRUIT_HATED_AMOUNT)

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/monkey_set_combat_target/perform(seconds_per_tick, datum/ai_controller/controller, set_key, enemies_key)
	var/list/enemies = controller.blackboard[enemies_key]
	var/list/valids = list()
	for(var/mob/living/possible_enemy in view(MONKEY_ENEMY_VISION, controller.pawn))
		if(possible_enemy == controller.pawn)
			continue // don't target ourselves
		if(!enemies[possible_enemy]) //We don't hate this creature! But we might still attack it!
			if(!controller.blackboard[BB_MONKEY_AGGRESSIVE]) //We are not aggressive either, so we won't attack!
				continue
			if(faction_check(possible_enemy.faction, list(FACTION_MONKEY, FACTION_JUNGLE), exact_match = FALSE) && !controller.blackboard[BB_MONKEY_TARGET_MONKEYS]) // do not target your team. includes monkys gorillas etc.
				continue
		// Weighted list, so the closer they are the more likely they are to be chosen as the enemy
		valids[possible_enemy] = CEILING(100 / (get_dist(controller.pawn, possible_enemy) || 1), 1)

	if(!length(valids))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(set_key, pick_weight(valids))
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
