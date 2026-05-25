/datum/ai_controller/basic_controller/bot/honkbot
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/secbot,
		BB_UNREACHABLE_LIST_COOLDOWN = 1 MINUTES,
		BB_ALWAYS_IGNORE_FACTION = TRUE,
	)
	behavior_nodes = BT_PARALLEL(BT_PARALLEL_FAILURE_ALL,\
		BT_LEAF(/datum/bt_node/ai_behavior/use_mob_ability/random_honk, BB_HONK_ABILITY),\
		BT_SELECTOR(\
			BT_SUBTREE(/datum/bt_node/subtree/escape_captivity/pacifist),\
			BT_SUBTREE(/datum/bt_node/subtree/bot_respond_to_summon),\
			BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
				BT_DECORATOR(/datum/bt_node/decorator/secbot_target_valid,\
					BT_LEAF(/datum/bt_node/ai_behavior/basic_melee_attack/interact_once/bot,\
						BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
					)\
				),\
				"key" = BB_BASIC_MOB_CURRENT_TARGET\
			),\
			BT_LEAF(/datum/bt_node/ai_behavior/find_potential_targets,\
				BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
			),\
			BT_SELECTOR(\
				BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
					BT_LEAF(/datum/bt_node/ai_behavior/honkbot_slip_sequence, BB_SLIP_TARGET, BB_SLIPPERY_TARGET),\
					"key" = BB_SLIPPERY_TARGET\
				),\
				BT_LEAF(/datum/bt_node/ai_behavior/find_slippery_item, BB_SLIPPERY_TARGET)\
			),\
			BT_SELECTOR(\
				BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
					BT_PARALLEL(BT_PARALLEL_FAILURE_ONE,\
						BT_LEAF(/datum/bt_node/ai_behavior/play_with_clown, BB_CLOWN_FRIEND),\
						BT_LEAF(/datum/bt_node/ai_behavior/move_to_target,\
							BB_CLOWN_FRIEND, 1\
						)\
					),\
					"key" = BB_CLOWN_FRIEND\
				),\
				BT_LEAF(/datum/bt_node/ai_behavior/find_clown_friend, BB_CLOWN_FRIEND)\
			),\
			BT_SUBTREE(/datum/bt_node/subtree/bot_patrol),\
		)\
	)
	reset_keys = list(
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_BOT_SUMMON_TARGET,
	)

/datum/ai_controller/basic_controller/bot/honkbot/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	// on_clear_target intentionally removed — it caused grab-then-immediately-release bug
	// Cleanup is handled by on_stop_pulling instead
	RegisterSignal(new_pawn, COMSIG_ATOM_NO_LONGER_PULLING, PROC_REF(on_stop_pulling))

/datum/ai_controller/basic_controller/bot/honkbot/proc/on_stop_pulling(datum/source)
	SIGNAL_HANDLER

	if(!blackboard_key_exists(BB_SLIP_TARGET))
		return

	var/atom/slip_target = blackboard[BB_SLIP_TARGET]
	add_to_blacklist(slip_target)
	clear_blackboard_key(BB_SLIP_TARGET)

// =============================================================================
// Random honk (prob-gated use_mob_ability)
// =============================================================================

/datum/bt_node/ai_behavior/use_mob_ability/random_honk

/datum/bt_node/ai_behavior/use_mob_ability/random_honk/perform(seconds_per_tick, datum/ai_controller/controller, ability_key)
	if(!SPT_PROB(5, seconds_per_tick))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return ..()

// =============================================================================
// Slip sequence — stateful behavior handling grab + drag + release
// =============================================================================

/**
 * Encapsulates the full slip-victim sequence.
 * Phase 1: Find and grab a victim (internal movement allowed — mirrors basic_melee_attack pattern).
 * Phase 2: Drag the grabbed victim to the slippery item and release.
 * Bug fix: does NOT clear BB_SLIP_TARGET in finish_action — on_stop_pulling handles cleanup.
 */
/datum/bt_node/ai_behavior/honkbot_slip_sequence
	action_cooldown = 1 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/bt_node/ai_behavior/honkbot_slip_sequence/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, slip_key, slippery_key)
	var/mob/living/living_pawn = controller.pawn
	if(!living_pawn.has_gravity())
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[living_pawn] honkbot_slip_sequence: no gravity")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/atom/slippery_item = controller.blackboard[slippery_key]
	if(QDELETED(slippery_item) || !can_see(living_pawn, slippery_item, 5))
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[living_pawn] honkbot_slip_sequence: slippery item lost (deleted=[QDELETED(slippery_item)])")
		controller.clear_blackboard_key(slip_key)
		controller.clear_blackboard_key(slippery_key)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/victim = controller.blackboard[slip_key]
	if(QDELETED(victim))
		// Find a victim in range
		var/list/ignore_list = controller.blackboard[BB_TEMPORARY_IGNORE_LIST]
		for(var/mob/living/carbon/human/candidate in oview(5, living_pawn))
			if(LAZYACCESS(ignore_list, candidate))
				continue
			if(candidate.buckled || !candidate.has_gravity())
				continue
			if(!can_see(living_pawn, candidate, 5))
				continue
			if(controller.set_if_can_reach(key = slip_key, target = candidate))
				victim = candidate
				break
		if(isnull(victim))
			EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[living_pawn] honkbot_slip_sequence: no valid victim found near [slippery_item]")
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(living_pawn.pulling != victim)
		// Phase 1: move to victim and grab
		EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[living_pawn] slip phase 1: moving to grab [victim]", get_turf(victim), "Grab?")
		set_movement_target(controller, victim)
		if(get_dist(living_pawn, victim) <= 0)
			living_pawn.start_pulling(victim)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	// Phase 2: move to slippery item while pulling victim
	EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[living_pawn] slip phase 2: dragging [victim] to [slippery_item]", get_turf(slippery_item), "Drag!")
	set_movement_target(controller, slippery_item)
	if(get_dist(living_pawn, slippery_item) > 0)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	// Arrived at slippery item — step to position victim on it, then release
	EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[living_pawn] releasing [victim] onto [slippery_item]!", get_turf(slippery_item), "HONK!")
	var/list/possible_dirs = GLOB.alldirs.Copy()
	possible_dirs -= get_dir(living_pawn, victim)
	for(var/direction in possible_dirs)
		var/turf/possible_turf = get_step(living_pawn, direction)
		if(possible_turf.is_blocked_turf(source_atom = living_pawn))
			possible_dirs -= direction
	if(length(possible_dirs))
		step(living_pawn, pick(possible_dirs))
	living_pawn.stop_pulling()
	living_pawn.emote("flip")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

// =============================================================================
// Find slippery item
// =============================================================================

/datum/bt_node/ai_behavior/find_slippery_item
	action_cooldown = 5 SECONDS

/datum/bt_node/ai_behavior/find_slippery_item/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key)
	var/mob/living/living_pawn = controller.pawn
	if(!living_pawn.has_gravity())
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[living_pawn] find_slippery_item: no gravity")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/list/ignore_list = controller.blackboard[BB_TEMPORARY_IGNORE_LIST]
	var/list/slippery_items = controller.blackboard[BB_SLIPPERY_ITEMS]
	if(!length(slippery_items))
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[living_pawn] find_slippery_item: BB_SLIPPERY_ITEMS is empty")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/list/type_cache = typecacheof(slippery_items)
	for(var/atom/potential in oview(5, living_pawn))
		if(!is_type_in_typecache(potential, type_cache))
			continue
		if(LAZYACCESS(ignore_list, potential))
			continue
		if(!can_see(living_pawn, potential, 5))
			continue
		EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[living_pawn] found slippery item: [potential]", get_turf(potential), "Slippery!")
		controller.set_blackboard_key(target_key, potential)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[living_pawn] find_slippery_item: no slippery item in range")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

// =============================================================================
// Clown friend search and play
// =============================================================================

/datum/bt_node/ai_behavior/find_clown_friend
	action_cooldown = 5 SECONDS

/datum/bt_node/ai_behavior/find_clown_friend/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key)
	var/list/ignore_list = controller.blackboard[BB_TEMPORARY_IGNORE_LIST]
	for(var/mob/living/nearby_mob in oview(5, controller.pawn))
		if(LAZYACCESS(ignore_list, nearby_mob))
			continue
		if(nearby_mob.stat != CONSCIOUS)
			continue
		var/is_clown = HAS_TRAIT(nearby_mob, TRAIT_PERCEIVED_AS_CLOWN)
		if(!is_clown && istype(nearby_mob, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/robot_target = nearby_mob
			is_clown = istype(robot_target.model, /obj/item/robot_model/clown)
		if(!is_clown)
			continue
		if(controller.set_if_can_reach(key = target_key, target = nearby_mob))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[controller.pawn] find_clown_friend: no clown in range")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/bt_node/ai_behavior/play_with_clown

/datum/bt_node/ai_behavior/play_with_clown/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/living_target = controller.blackboard[target_key]
	if(QDELETED(living_target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(get_dist(controller.pawn, living_target) > 1)
		return AI_BEHAVIOR_INSTANT
	var/mob/living/living_pawn = controller.pawn
	var/datum/action/honk_ability = controller.blackboard[BB_HONK_ABILITY]
	honk_ability?.Trigger()
	living_pawn.manual_emote("celebrates with [living_target]!")
	living_pawn.emote("flip")
	living_pawn.emote("beep")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/play_with_clown/finish_action(datum/ai_controller/basic_controller/bot/controller, succeeded, target_key)
	. = ..()
	var/mob/living/living_target = controller.blackboard[target_key]
	if(!isnull(living_target))
		controller.add_to_blacklist(living_target)
	controller.clear_blackboard_key(target_key)
