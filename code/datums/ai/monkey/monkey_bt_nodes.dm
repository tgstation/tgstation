// Monkey-specific BT behavior nodes

/// Monkey's battle screech variant — louder and on a 5 second cooldown
/datum/bt_node/ai_behavior/battle_screech/monkey
	time_between_perform = 5 SECONDS
	screeches = list("roar", "screech")

// --- Equip behaviors ---

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
	if(equip_item(controller))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

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

// --- Weapon finding ---

/// Scans nearby items and mobs for a better weapon and sets BB_MONKEY_PICKUPTARGET
/datum/bt_node/ai_behavior/monkey_find_weapon

/datum/bt_node/ai_behavior/monkey_find_weapon/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn

	if(!(locate(/obj/item) in living_pawn.held_items))
		controller.set_blackboard_key(BB_MONKEY_BEST_FORCE_FOUND, 0)

	if(controller.blackboard[BB_MONKEY_GUN_NEURONS_ACTIVATED] && (locate(/obj/item/gun) in living_pawn.held_items))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED // already have a gun

	for(var/obj/item/item in living_pawn.held_items) // drop weak items
		if(item.force < 2)
			living_pawn.dropItemToGround(item)

	var/list/nearby_items = list()
	for(var/obj/item/item in oview(2, living_pawn))
		nearby_items += item

	var/obj/item/weapon = GetBestWeapon(controller, nearby_items, living_pawn.held_items)

	var/pickpocket = FALSE
	for(var/mob/living/carbon/human/human in oview(5, living_pawn))
		var/obj/item/held_weapon = GetBestWeapon(controller, human.held_items + weapon, living_pawn.held_items)
		if(held_weapon == weapon)
			continue
		pickpocket = TRUE
		weapon = held_weapon

	if(!weapon || (weapon in living_pawn.held_items))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(weapon.force < 2) // our bite already does ~2 damage
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(BB_MONKEY_PICKUPTARGET, weapon)
	controller.set_blackboard_key(BB_MONKEY_PICKUP_IS_PICKPOCKET, pickpocket ? TRUE : null)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

// --- Combat target selection ---

/// Selects a target from BB_MONKEY_ENEMIES or picks any visible mob if aggressive
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
			if(possible_enemy.stat != SOFT_CRIT) // Dont bother, theyre fucked.
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

// --- Attack ---

/// Attacks the target mob; SUCCEEDED when target is gone, FAILED when target goes down (triggers disposal fallthrough)
/datum/bt_node/ai_behavior/monkey_attack_mob
	var/target_key
	time_between_perform = CLICK_CD_MELEE

/datum/bt_node/ai_behavior/monkey_attack_mob/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/target = controller.blackboard[target_key]
	var/mob/living/living_pawn = controller.pawn
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(controller.blackboard[BB_TARGETING_STRATEGY])

	if(QDELETED(target) || !strategy.can_attack(living_pawn, target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/obj/item/holding_weapon
	for(var/obj/item/potential_weapon in target.held_items)
		if(!(potential_weapon.item_flags & ABSTRACT))
			holding_weapon = potential_weapon
			break

	var/attack_results = monkey_attack(controller, target, seconds_per_tick, holding_weapon && SPT_PROB(MONKEY_ATTACK_DISARM_PROB, seconds_per_tick), holding_weapon)

	if(!attack_results || controller.blackboard[BB_MONKEY_AGGRESSIVE])
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/hatred_value = controller.blackboard[BB_MONKEY_ENEMIES][target]
	if(isnull(hatred_value))
		hatred_value = 1
		controller.set_blackboard_key_assoc(BB_MONKEY_ENEMIES, target, hatred_value)

	if(!SPT_PROB(MONKEY_HATRED_REDUCTION_PROB, seconds_per_tick))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	hatred_value--
	if(hatred_value <= 0)
		controller.remove_thing_from_blackboard_key(BB_MONKEY_ENEMIES, target)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	controller.set_blackboard_key_assoc(BB_MONKEY_ENEMIES, target, hatred_value)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/monkey_attack_mob/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	if(succeeded) // disposal path clears the key on failure
		controller.clear_blackboard_key(target_key)

/// Attack with held weapon or bite; try to disarm if target is holding something
/datum/bt_node/ai_behavior/monkey_attack_mob/proc/monkey_attack(datum/ai_controller/controller, mob/living/target, seconds_per_tick, disarm, holding_weapon)
	var/mob/living/living_pawn = controller.pawn

	if(living_pawn.next_move > world.time)
		return FALSE

	var/obj/item/gun/gun_to_shoot = locate() in living_pawn.held_items
	if(gun_to_shoot?.can_shoot())
		if(gun_to_shoot != living_pawn.get_active_held_item())
			living_pawn.swap_hand(living_pawn.get_inactive_hand_index())
		controller.ai_interact(target = target, combat_mode = TRUE)
		return TRUE

	var/obj/item/potential_weapon = locate() in living_pawn.held_items
	if(!target.IsReachableBy(living_pawn, potential_weapon?.reach))
		return FALSE

	if(isnull(potential_weapon))
		controller.ai_interact(target = target, modifiers = disarm ? list(RIGHT_CLICK = TRUE) : null, combat_mode = TRUE)
		if(disarm && !isnull(holding_weapon) && controller.blackboard[BB_MONKEY_BLACKLISTITEMS][holding_weapon])
			controller.remove_thing_from_blackboard_key(BB_MONKEY_BLACKLISTITEMS, holding_weapon)
		return TRUE

	if(potential_weapon != living_pawn.get_active_held_item())
		living_pawn.swap_hand(living_pawn.get_inactive_hand_index())
	controller.ai_interact(target = target, combat_mode = TRUE)
	return TRUE

// --- Recruitment ---

/// Rallies nearby monkeys against the current attack target
/datum/bt_node/ai_behavior/recruit_monkeys
	var/target_key

/datum/bt_node/ai_behavior/recruit_monkeys/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/mob/living/attack_target = controller.blackboard[target_key]

	for(var/mob/living/nearby_monkey in view(living_pawn, MONKEY_ENEMY_VISION))
		if(QDELETED(nearby_monkey) || !HAS_AI_CONTROLLER_TYPE(nearby_monkey, /datum/ai_controller/monkey))
			continue
		if(!SPT_PROB(MONKEY_RECRUIT_PROB, seconds_per_tick))
			continue
		nearby_monkey.ai_controller.add_blackboard_key_assoc(BB_MONKEY_ENEMIES, attack_target, MONKEY_RECRUIT_HATED_AMOUNT)

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

// --- Serve food support ---

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

// --- Shenanigans support ---

/// Finds a press target: uses BB_MONKEY_PRESS_TYPEPATH if set, else a random nearby atom
/datum/bt_node/ai_behavior/monkey_find_press_target
	var/target_key
	time_between_perform = 2 SECONDS

/datum/bt_node/ai_behavior/monkey_find_press_target/perform(seconds_per_tick, datum/ai_controller/controller)
	if(controller.blackboard_key_exists(target_key))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	var/locate_path = controller.blackboard[BB_MONKEY_PRESS_TYPEPATH]
	var/mob/living/living_pawn = controller.pawn
	var/atom/found

	if(locate_path)
		found = locate(locate_path) in oview(2, living_pawn)
	else
		var/list/candidates = list()
		for(var/atom/visible in oview(1, living_pawn))
			if(!ismob(visible) && !isturf(visible))
				candidates += visible
		if(length(candidates))
			found = pick(candidates)

	if(!found)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(target_key, found)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

// --- Idle ---

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

// --- BT Subtrees ---

/datum/bt_node/subtree/monkey_combat
	behavior_tree_json = "code/datums/ai/monkey/monkey_combat.bt.json"

/datum/bt_node/subtree/monkey_find_weapon
	behavior_tree_json = "code/datums/ai/monkey/monkey_find_weapon.bt.json"

/datum/bt_node/subtree/monkey_shenanigans
	behavior_tree_json = "code/datums/ai/monkey/monkey_shenanigans.bt.json"

/datum/bt_node/subtree/monkey_serve_food
	behavior_tree_json = "code/datums/ai/monkey/monkey_serve_food.bt.json"
