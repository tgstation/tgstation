
/// Monkey's battle screech variant  louder and on a 5 second cooldown
/datum/bt_node/ai_behavior/battle_screech/monkey
	time_between_perform = 5 SECONDS
	screeches = list("roar", "screech")


/// Base equip behavior; handles blacklist updates and key cleanup on finish
/datum/bt_node/ai_behavior/monkey_equip
	var/target_key

/datum/bt_node/ai_behavior/monkey_equip/finish_action(datum/ai_controller/controller, success)
	. = ..()
	if(!success) // Don't try to pick this item up again
		controller.set_blackboard_key_assoc(BB_MONKEY_BLACKLISTITEMS, controller.blackboard[target_key], TRUE)
	controller.clear_blackboard_key(BB_MONKEY_PICKUPTARGET)
	controller.clear_blackboard_key(BB_MONKEY_PICKUP_IS_PICKPOCKET)

/// Equip a weapon off the ground
/datum/bt_node/ai_behavior/monkey_equip/ground

/datum/bt_node/ai_behavior/monkey_equip/ground/setup(datum/ai_controller/controller)
	var/obj/item/target = controller.blackboard[target_key]
	return !QDELETED(target)

/datum/bt_node/ai_behavior/monkey_equip/ground/perform(seconds_per_tick, datum/ai_controller/controller)
	var/async_flags = handle_async()
	if(async_flags)
		return async_flags

	return start_async()

/datum/bt_node/ai_behavior/monkey_equip/ground/perform_async(datum/ai_controller/controller)
	var/result = equip_item(controller)
	if(!async_still_valid())
		return
	finish_async(result ? AI_BEHAVIOR_SUCCEEDED : AI_BEHAVIOR_FAILED)

/// Pickpocket a weapon from a mob
/datum/bt_node/ai_behavior/monkey_equip/pickpocket

/datum/bt_node/ai_behavior/monkey_equip/pickpocket/setup(datum/ai_controller/controller)
	var/obj/item/target = controller.blackboard[target_key]
	return !QDELETED(target)

/datum/bt_node/ai_behavior/monkey_equip/pickpocket/perform(seconds_per_tick, datum/ai_controller/controller)
	if(controller.blackboard[BB_MONKEY_PICKPOCKETING]) // mid-snatch; wait
		return AI_BEHAVIOR_DELAY
	INVOKE_ASYNC(src, PROC_REF(attempt_pickpocket), controller)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/monkey_equip/pickpocket/proc/attempt_pickpocket(datum/ai_controller/controller)
	var/obj/item/target = controller.blackboard[BB_MONKEY_PICKUPTARGET]
	var/mob/living/victim = target?.loc
	var/mob/living/living_pawn = controller.pawn

	if(!istype(victim))
		finish_action(controller, FALSE)
		return

	victim.visible_message(span_warning("[living_pawn] starts trying to take [target] from [victim]!"), span_danger("[living_pawn] tries to take [target]!"))
	controller.set_blackboard_key(BB_MONKEY_PICKPOCKETING, TRUE)

	var/success = FALSE

	if(do_after(living_pawn, MONKEY_ITEM_SNATCH_DELAY, victim) && target && victim.IsReachableBy(living_pawn))
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

	finish_action(controller, success)

/datum/bt_node/ai_behavior/monkey_equip/pickpocket/finish_action(datum/ai_controller/controller, success)
	. = ..()
	controller.set_blackboard_key(BB_MONKEY_PICKPOCKETING, FALSE)

/// Shared item equip proc
/datum/bt_node/ai_behavior/monkey_equip/proc/equip_item(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/obj/item/target = controller.blackboard[BB_MONKEY_PICKUPTARGET]
	var/best_force = controller.blackboard[BB_MONKEY_BEST_FORCE_FOUND]

	if(!isturf(living_pawn.loc))
		return FALSE
	if(!target)
		return FALSE
	if(target.anchored)
		return FALSE

	if(target.force > best_force) // better weapon
		living_pawn.drop_all_held_items()
		living_pawn.put_in_hands(target)
		controller.set_blackboard_key(BB_MONKEY_BEST_FORCE_FOUND, target.force)
		return TRUE

	if(target.slot_flags) // wearable
		living_pawn.dropItemToGround(target, TRUE)
		living_pawn.update_icons()
		if(!living_pawn.equip_to_appropriate_slot(target))
			return FALSE
		return TRUE

	if(living_pawn.get_empty_held_indexes()) // any free hand
		living_pawn.put_in_hands(target)
		return TRUE

	return FALSE

/// Gathers weapon upgrade candidates: nearby ground items, then held items of nearby humans.
/datum/target_source/monkey_weapon_upgrade

/datum/target_source/monkey_weapon_upgrade/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	var/list/candidates = list()
	for(var/obj/item/ground_item in oview(range, pawn))
		candidates += ground_item
	for(var/mob/living/carbon/human/nearby_human in oview(range, pawn))
		candidates += nearby_human.held_items
	return candidates

/// Weapon upgrade candidate: not two-handed, not blacklisted, and hits harder than our bite.
/datum/targeting_strategy/monkey_weapon_upgrade

/datum/targeting_strategy/monkey_weapon_upgrade/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/candidate = target
	if(HAS_TRAIT(candidate, TRAIT_NEEDS_TWO_HANDS) || controller.blackboard[BB_MONKEY_BLACKLISTITEMS][candidate])
		return FALSE
	if(candidate.force < 2) // our bite already does ~2 damage
		return FALSE
	return TRUE

/// Scans nearby items and mobs for a better weapon and sets BB_MONKEY_PICKUPTARGET
/datum/bt_node/ai_behavior/acquire_target/update_interaction_target/monkey_find_weapon

/datum/bt_node/ai_behavior/acquire_target/update_interaction_target/monkey_find_weapon/can_search(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	if(!(locate(/obj/item) in living_pawn.held_items))
		controller.set_blackboard_key(BB_MONKEY_BEST_FORCE_FOUND, 0)
	if(controller.blackboard[BB_MONKEY_GUN_NEURONS_ACTIVATED] && (locate(/obj/item/gun) in living_pawn.held_items))
		return FALSE // already have a gun
	return ..()

/// Prefers any gun once gun neurons are activated, else the strongest candidate that beats our current best held item.
/datum/bt_node/ai_behavior/acquire_target/update_interaction_target/monkey_find_weapon/pick_final_target(datum/ai_controller/controller, list/filtered_targets)
	var/mob/living/living_pawn = controller.pawn

	if(controller.blackboard[BB_MONKEY_GUN_NEURONS_ACTIVATED])
		for(var/obj/item/candidate as anything in filtered_targets)
			if(isgun(candidate))
				return candidate

	var/top_force = 0
	for(var/obj/item/held in living_pawn.held_items)
		if(HAS_TRAIT(held, TRAIT_NEEDS_TWO_HANDS) || controller.blackboard[BB_MONKEY_BLACKLISTITEMS][held])
			continue
		top_force = max(top_force, held.force)

	var/obj/item/best
	for(var/obj/item/candidate as anything in filtered_targets)
		if(candidate.force <= top_force)
			continue
		best = candidate
		top_force = candidate.force
	return best

/datum/bt_node/ai_behavior/acquire_target/update_interaction_target/monkey_find_weapon/on_target_found(datum/ai_controller/controller, atom/target, datum/targeting_strategy/strategy)
	controller.set_blackboard_key(BB_MONKEY_PICKUP_IS_PICKPOCKET, ismob(target.loc) ? TRUE : null)


/// Selects a target from BB_MONKEY_ENEMIES or picks any visible mob if aggressive.  This should be ported to new targetting but its so fkn bespoke
/datum/bt_node/ai_behavior/monkey_set_combat_target
	var/attack_target_key
	var/enemies_key

/datum/bt_node/ai_behavior/monkey_set_combat_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/list/enemies = controller.blackboard[enemies_key]

	if(HAS_TRAIT(living_pawn, TRAIT_PACIFISM) || (!length(enemies) && !controller.blackboard[BB_MONKEY_AGGRESSIVE]))
		living_pawn.set_combat_mode(FALSE)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/list/valids = list()
	for(var/mob/living/possible_enemy in view(MONKEY_ENEMY_VISION, living_pawn))
		if(possible_enemy == living_pawn)
			continue
		if(!enemies[possible_enemy])
			if(!controller.blackboard[BB_MONKEY_AGGRESSIVE])
				continue
			if(possible_enemy.has_faction(list(FACTION_MONKEY, FACTION_JUNGLE)) && !controller.blackboard[BB_MONKEY_TARGET_MONKEYS])
				continue
			if(IS_DEAD_OR_INCAP(possible_enemy)) // Dont bother, theyre fucked.
				continue
		valids[possible_enemy] = CEILING(100 / (get_dist(living_pawn, possible_enemy) || 1), 1)

	if(!length(valids))
		living_pawn.set_combat_mode(FALSE)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/mob/living/target = pick_weight(valids)

	EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_TARGETING, "[living_pawn] has selected [target] as a target for blackboard key [attack_target_key]! Behavior: [src]", get_turf(target), "Target: [target]")
	EVLOG_LINES(controller, EVLOG_CATEGORY_AI_TARGETING, "Line to target", get_turf(living_pawn), get_turf(target))

	living_pawn.set_combat_mode(TRUE)
	controller.set_blackboard_key(attack_target_key, target)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED


/// Attacks the target mob; SUCCEEDED when target is gone, FAILED when target goes down (Which lets us flush the fucker instead)
/datum/bt_node/ai_behavior/monkey_attack_mob
	var/target_key
	/// seconds_per_tick from the perform() that kicked off the current async attack.
	VAR_PRIVATE/attack_seconds_per_tick = 0
	/// Weapon snapshot from the perform() that kicked off the current async attack.
	VAR_PRIVATE/obj/item/attack_holding_weapon

/datum/bt_node/ai_behavior/monkey_attack_mob/perform(seconds_per_tick, datum/ai_controller/controller)
	var/async_flags = handle_async()
	if(async_flags)
		return async_flags

	var/mob/living/target = controller.blackboard[target_key]
	var/mob/living/living_pawn = controller.pawn
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(controller.blackboard[BB_TARGETING_STRATEGY])

	if(QDELETED(target) || !strategy.is_valid_target(living_pawn, target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/obj/item/holding_weapon
	for(var/obj/item/potential_weapon in target.held_items)
		if(!(potential_weapon.item_flags & ABSTRACT))
			holding_weapon = potential_weapon
			break

	attack_seconds_per_tick = seconds_per_tick
	attack_holding_weapon = holding_weapon
	return start_async()

/datum/bt_node/ai_behavior/monkey_attack_mob/perform_async(datum/ai_controller/controller)
	var/mob/living/target = controller.blackboard[target_key]
	var/seconds_per_tick = attack_seconds_per_tick
	var/obj/item/holding_weapon = attack_holding_weapon
	var/attack_results = monkey_attack(controller, target, seconds_per_tick, holding_weapon && SPT_PROB(MONKEY_ATTACK_DISARM_PROB, seconds_per_tick), holding_weapon)
	if(!async_still_valid())
		return
	var/succeeded = FALSE
	if(attack_results && !controller.blackboard[BB_MONKEY_AGGRESSIVE])
		succeeded = TRUE
		if(prob(MONKEY_HATRED_REDUCTION_PROB))
			var/hatred_value = controller.blackboard[BB_MONKEY_ENEMIES][target] - 1
			if(hatred_value <= 0)
				controller.remove_thing_from_blackboard_key(BB_MONKEY_ENEMIES, target)
			else
				controller.set_blackboard_key_assoc(BB_MONKEY_ENEMIES, target, hatred_value)
	finish_async(succeeded ? AI_BEHAVIOR_SUCCEEDED : AI_BEHAVIOR_FAILED)

/datum/bt_node/ai_behavior/monkey_attack_mob/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	attack_seconds_per_tick = 0
	attack_holding_weapon = null

/// Attack with held weapon or bite; try to disarm if target is holding something
/datum/bt_node/ai_behavior/monkey_attack_mob/proc/monkey_attack(datum/ai_controller/controller, mob/living/target, seconds_per_tick, disarm, holding_weapon)
	var/mob/living/living_pawn = controller.pawn

	if(living_pawn.next_move > world.time)
		return FALSE

	living_pawn.face_atom(target)

	var/obj/item/potential_weapon = locate(/obj/item) in living_pawn.held_items

	if(target.IsReachableBy(living_pawn, potential_weapon?.reach))
		if(isnull(potential_weapon))
			controller.ai_interact(target = target, modifiers = disarm ? list(RIGHT_CLICK = TRUE) : null, combat_mode = TRUE)
			if(disarm && !isnull(holding_weapon) && controller.blackboard[BB_MONKEY_BLACKLISTITEMS][holding_weapon])
				controller.remove_thing_from_blackboard_key(BB_MONKEY_BLACKLISTITEMS, holding_weapon)
		else
			if(potential_weapon != living_pawn.get_active_held_item())
				living_pawn.swap_hand(living_pawn.get_inactive_hand_index())
			controller.ai_interact(target = target, combat_mode = TRUE)
		controller.override_blackboard_key(BB_MONKEY_GUN_WORKED, TRUE)
		return TRUE

	if(!potential_weapon)
		return FALSE

	// target out of melee reach — try ranged or throw
	var/atom/real_target = target
	if(prob(10)) // artificial miss
		real_target = pick(oview(2, target))

	var/obj/item/gun/gun = locate(/obj/item/gun) in living_pawn.held_items
	var/can_shoot = gun?.can_shoot() || FALSE
	if(gun && controller.blackboard[BB_MONKEY_GUN_WORKED] && prob(95))
		if(gun != living_pawn.get_active_held_item())
			living_pawn.swap_hand(living_pawn.get_inactive_hand_index())
		controller.ai_interact(target = real_target, combat_mode = TRUE)
		controller.override_blackboard_key(BB_MONKEY_GUN_WORKED, can_shoot ? TRUE : prob(80))
		if(can_shoot)
			controller.override_blackboard_key(BB_MONKEY_GUN_NEURONS_ACTIVATED, TRUE)
	else
		living_pawn.throw_item(real_target)
		controller.override_blackboard_key(BB_MONKEY_GUN_WORKED, TRUE)
	return TRUE

/// Rallies nearby monkeys against the current attack target
/datum/bt_node/ai_behavior/recruit_monkeys
	var/target_key

/datum/bt_node/ai_behavior/recruit_monkeys/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/mob/living/attack_target = controller.blackboard[target_key]

	for(var/mob/living/nearby_monkey in view(living_pawn, MONKEY_ENEMY_VISION))
		if(QDELETED(nearby_monkey) || !HAS_AI_CONTROLLER_TYPE(nearby_monkey, /datum/ai_controller/monkey))
			continue
		if(prob(MONKEY_RECRUIT_PROB))
			continue
		nearby_monkey.ai_controller.add_blackboard_key_assoc(BB_MONKEY_ENEMIES, attack_target, MONKEY_RECRUIT_HATED_AMOUNT)

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED


/// Scans nearby humans for patrons to serve; fails if bartender present or fewer than 1 patron found
/datum/bt_node/ai_behavior/monkey_find_patrons
	var/patrons_key
	var/give_target_key

/datum/bt_node/ai_behavior/monkey_find_patrons/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/list/nearby_patrons = list()

	for(var/mob/living/carbon/human/human_mob in oview(5, living_pawn))
		if(istype(human_mob.mind?.assigned_role, /datum/job/bartender))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED // my boss is on duty!
		if(human_mob.stat != CONSCIOUS || ismonkey(human_mob))
			continue
		if(!human_mob.get_empty_held_indexes())
			continue
		nearby_patrons += human_mob

	if(!length(nearby_patrons))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.override_blackboard_key(patrons_key, nearby_patrons)
	controller.blackboard[give_target_key] ||= pick(nearby_patrons)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED


/// Gathers press targets: filtered to BB_MONKEY_PRESS_TYPEPATH's type if set, else any nearby obj.
/datum/target_source/monkey_press_target

/datum/target_source/monkey_press_target/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	var/locate_path = controller.blackboard[BB_MONKEY_PRESS_TYPEPATH]
	var/list/candidates = list()
	for(var/obj/potential_candidate in oview(range, pawn))
		if(locate_path)
			if(istype(potential_candidate, locate_path))
				candidates += potential_candidate
				break //found a bell fuck everything else
		candidates += potential_candidate
	return candidates

/// Idle wander/emote behavior. Reads emote lists from BB_MONKEY_IDLE_COMMON_EMOTES and BB_MONKEY_IDLE_RARE_EMOTES.
/datum/bt_node/ai_behavior/monkey_idle

/datum/bt_node/ai_behavior/monkey_idle/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	if(SPT_PROB(25, seconds_per_tick) && (living_pawn.mobility_flags & MOBILITY_MOVE) && isturf(living_pawn.loc) && !living_pawn.pulledby)
		var/move_dir = pick(GLOB.alldirs)
		living_pawn.Move(get_step(living_pawn, move_dir), move_dir)
	else if(SPT_PROB(5, seconds_per_tick))
		INVOKE_ASYNC(living_pawn, TYPE_PROC_REF(/mob, emote), pick(controller.blackboard[BB_MONKEY_IDLE_COMMON_EMOTES]))
	else if(SPT_PROB(1, seconds_per_tick))
		INVOKE_ASYNC(living_pawn, TYPE_PROC_REF(/mob, emote), pick(controller.blackboard[BB_MONKEY_IDLE_RARE_EMOTES]))
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

///monkey trees

/datum/bt_node/subtree/monkey_combat
	behavior_tree_json = "code/datums/ai/monkey/monkey_combat.bt.json"

/datum/bt_node/subtree/monkey_find_weapon
	behavior_tree_json = "code/datums/ai/monkey/monkey_find_weapon.bt.json"

/datum/bt_node/subtree/monkey_shenanigans
	behavior_tree_json = "code/datums/ai/monkey/monkey_shenanigans.bt.json"

/datum/bt_node/subtree/monkey_serve_food
	behavior_tree_json = "code/datums/ai/monkey/monkey_serve_food.bt.json"
