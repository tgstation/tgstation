/// List of objects that AIs will treat as targets
GLOBAL_ALIST_EMPTY(hostile_machines_by_z)
/// Static typecache list of things we are interested in
/// Consider this a union of the for loop and the hearers call from below
/// Must be kept up to date with the contents of hostile_machines
GLOBAL_LIST_INIT(target_interested_atoms, typecacheof(list(/mob, /obj/machinery/porta_turret, /obj/vehicle/sealed/mecha)))


///Used to find combat targets; Allow finding things hidden in things such as lockers too.
/datum/bt_node/ai_behavior/acquire_target/update_combat_targets
	target_source = /datum/target_source/hearers
	/// How far can we see stuff?
	vision_range = 9
	/// Blackboard key for aggro range, uses vision range if not specified
	var/aggro_range_key = BB_AGGRO_RANGE
	///Aggro loss distance
	var/aggro_loss_distance = 16
	/// Blackboard key holding the hiding-location atom (e.g. closet the target ducked into)
	var/hiding_location_key
	/// Blackboard key holding the /datum/target_priority_strategy typepath for selection
	var/priority_strategy_key = BB_TARGET_PRIORITY_STRATEGY
	/// If we have a priority strategy set, how often do we refresh our target search?
	var/priority_refresh_cooldown = 6 SECONDS

/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/get_cooldown(datum/ai_controller/controller)
	if(controller.blackboard[BB_FIND_TARGETS_FIELD(type)])
		return 60 SECONDS
	return ..()

/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/get_targeting_strategy(datum/ai_controller/controller)
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])
	if(!strategy)
		CRASH("No target datum was supplied in the blackboard for [controller.pawn]")
	return strategy

/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_mob = controller.pawn
	var/datum/targeting_strategy/targeting_strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])

	if(!targeting_strategy)
		CRASH("No target datum was supplied in the blackboard for [controller.pawn]")

	var/atom/current_target = controller.blackboard[target_key]
	var/datum/target_priority_strategy/priority_strategy = GET_TARGET_PRIORITY_STRATEGY(controller.blackboard[priority_strategy_key])
	if((!priority_strategy || controller.blackboard[BB_BASIC_MOB_TARGET_REFRESH_COOLDOWN] > world.time) && current_target && targeting_strategy.is_valid_target(living_mob, current_target, vision_range))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/aggro_range = controller.blackboard[aggro_range_key] || vision_range

	// If we're using a field rn, just don't do anything yeah?
	if(controller.blackboard[BB_FIND_TARGETS_FIELD(type)])
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/datum/target_source/source = GET_TARGET_SOURCE(target_source)
	var/list/potential_targets = source.collect_candidates(living_mob, controller, aggro_range)

	if(!potential_targets.len)
		if(!current_target)
			failed_to_find_anyone(controller, target_key, targeting_strategy_key, hiding_location_key)
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
		if (!can_see(living_mob, current_target, aggro_loss_distance))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
		potential_targets += current_target

	var/list/filtered_targets = list()
	var/current_priority = 0
	if(priority_strategy)
		current_priority = priority_strategy.get_target_priority(controller, current_target)

	for(var/atom/pot_target in potential_targets)
		if(!targeting_strategy.is_valid_target(living_mob, pot_target))
			continue
		if (priority_strategy && priority_strategy.get_target_priority(controller, pot_target) < current_priority)
			continue
		filtered_targets += pot_target

	if(!filtered_targets.len)
		if(!current_target)
			failed_to_find_anyone(controller, target_key, targeting_strategy_key, hiding_location_key)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/atom/target = pick_final_target(controller, filtered_targets)

	EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_TARGETING, "[controller.pawn] has selected [target] as a target for blackboard key [target_key]! Behavior: [src]", get_turf(target), "Target: [target]")
	EVLOG_LINES(controller, EVLOG_CATEGORY_AI_TARGETING, "Line to target", get_turf(controller.pawn), get_turf(target))

	if(target != current_target)
		controller.set_blackboard_key(target_key, target)
	controller.set_blackboard_key(BB_BASIC_MOB_TARGET_REFRESH_COOLDOWN, world.time + priority_refresh_cooldown)

	var/atom/potential_hiding_location = targeting_strategy.find_hidden_mobs(living_mob, target)

	if(potential_hiding_location) //If they're hiding inside of something, we need to know so we can go for that instead initially.
		controller.set_blackboard_key(hiding_location_key, potential_hiding_location)

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/proc/failed_to_find_anyone(datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	var/aggro_range = controller.blackboard[aggro_range_key] || vision_range
	// takes the larger between our range() input and our implicit hearers() input (world.view)
	aggro_range = max(aggro_range, ROUND_UP(max(getviewsize(world.view)) / 2))
	// Alright, here's the interesting bit
	// We're gonna use this max range to hook into a proximity field so we can just await someone interesting to come along
	// Rather then trying to check every few seconds
	var/datum/proximity_monitor/advanced/ai_target_tracking/detection_field = new(
		controller.pawn,
		aggro_range,
		TRUE,
		src,
		controller,
		target_key,
		targeting_strategy_key,
		hiding_location_key,
	)
	// We're gonna store this field in our blackboard, so we can clear it away if we end up finishing successsfully
	controller.set_blackboard_key(BB_FIND_TARGETS_FIELD(type), detection_field)
	controller.clear_blackboard_key(target_key)


/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/proc/new_turf_found(turf/found, datum/ai_controller/controller, datum/targeting_strategy/strategy)
	var/valid_found = FALSE
	var/mob/pawn = controller.pawn
	for(var/maybe_target in found)
		if(maybe_target == pawn)
			continue
		if(!is_type_in_typecache(maybe_target, GLOB.target_interested_atoms))
			continue
		if(!strategy.is_valid_target(pawn, maybe_target))
			continue
		valid_found = TRUE
		break
	if(!valid_found)
		return
	// If we found any one thing we "could" attack, then run the full search again so we can select from the best possible canidate
	var/datum/proximity_monitor/field = controller.blackboard[BB_FIND_TARGETS_FIELD(type)]
	qdel(field) // autoclears so it's fine
	// Fire instantly, you should find something I hope
	modify_cooldown(world.time)

/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/proc/atom_allowed(atom/movable/checking, datum/targeting_strategy/strategy, mob/pawn)
	if(checking == pawn)
		return FALSE
	if(!ismob(checking) && !is_type_in_typecache(checking, GLOB.target_interested_atoms))
		return FALSE
	if(!strategy.is_valid_target(pawn, checking))
		return FALSE
	return TRUE

/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/proc/new_atoms_found(list/atom/movable/found, datum/ai_controller/controller, target_key, datum/targeting_strategy/strategy, hiding_location_key)
	var/mob/pawn = controller.pawn
	var/list/accepted_targets = list()
	for(var/maybe_target in found)
		if(maybe_target == pawn)
			continue
		// Need to better handle viewers here
		if(!ismob(maybe_target) && !is_type_in_typecache(maybe_target, GLOB.target_interested_atoms))
			continue
		if(!strategy.is_valid_target(pawn, maybe_target))
			continue
		accepted_targets += maybe_target

	// Alright, we found something acceptable, let's use it yeah?
	var/atom/target = pick_final_target(controller, accepted_targets)
	EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_TARGETING, "[controller.pawn] has selected [target] as a target for blackboard key [target_key]! Behavior: [src]", get_turf(target), "Target: [target]")
	EVLOG_LINES(controller, EVLOG_CATEGORY_AI_TARGETING, "Line to target", get_turf(controller.pawn), get_turf(target))
	controller.set_blackboard_key(target_key, target)

	var/atom/potential_hiding_location = strategy.find_hidden_mobs(pawn, target)

	if(potential_hiding_location) //If they're hiding inside of something, we need to know so we can go for that instead initially.
		controller.set_blackboard_key(hiding_location_key, potential_hiding_location)

	finish_action(controller, succeeded = TRUE)

/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	if (succeeded)
		var/datum/proximity_monitor/field = controller.blackboard[BB_FIND_TARGETS_FIELD(type)]
		qdel(field) // autoclears so it's fine
		modify_cooldown(get_cooldown(controller))

/// Picks the final target, preferring higher-priority candidates when a priority strategy is set.
/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/pick_final_target(datum/ai_controller/controller, list/filtered_targets)
	var/datum/target_priority_strategy/priority_strategy = GET_TARGET_PRIORITY_STRATEGY(controller.blackboard[priority_strategy_key])
	if(!priority_strategy)
		return pick(filtered_targets)
	return priority_strategy.select_target(controller, filtered_targets)

/// Picks targets based on which one has the lowest health.
/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/most_wounded

/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/most_wounded/pick_final_target(datum/ai_controller/controller, list/filtered_targets)
	var/list/living_targets = list()
	for(var/mob/living/living_target in filtered_targets)
		living_targets += living_target
	if(living_targets.len)
		sortTim(living_targets, GLOBAL_PROC_REF(cmp_mob_health))
		return living_targets[living_targets.len]
	return ..()

// DEPRECATED — port to /datum/bt_node/ai_behavior/acquire_target/update_combat_targets
/datum/ai_behavior/update_targets
	parent_type = /datum/bt_node/ai_behavior/acquire_target/update_combat_targets

/// Targets with the trait specified by the BB_TARGET_PRIORITY_TRAIT blackboard key will be prioritized over the rest.
/datum/ai_behavior/update_targets/prioritize_trait

/datum/ai_behavior/update_targets/prioritize_trait/pick_final_target(datum/ai_controller/controller, list/filtered_targets) // still compiles via deprecated stub
	var/priority_targets = list()
	for(var/atom/target as anything in filtered_targets)
		if(HAS_TRAIT(target, controller.blackboard[BB_TARGET_PRIORITY_TRAIT]))
			priority_targets += target
	if(length(priority_targets))
		return ..(controller, priority_targets)
	return ..()

/datum/ai_behavior/update_targets/bigger_range
	vision_range = 16
