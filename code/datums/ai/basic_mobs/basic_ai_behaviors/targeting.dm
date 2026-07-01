/// List of objects that AIs will treat as targets
GLOBAL_ALIST_EMPTY(hostile_machines_by_z)
/// Static typecache list of things we are interested in
/// Consider this a union of the for loop and the hearers call from below
/// Must be kept up to date with the contents of hostile_machines
GLOBAL_LIST_INIT(target_interested_atoms, typecacheof(list(/mob, /obj/machinery/porta_turret, /obj/vehicle/sealed/mecha)))


///Used to find combat targets; Allow finding things hidden in things such as lockers too.
/datum/bt_node/ai_behavior/acquire_target/update_combat_targets
	target_source = /datum/target_source/hearers
	targeting_strategy = BB_TARGETING_STRATEGY
	vision_range = 9
	target_loss_distance = 16
	/// Blackboard key for aggro range, uses vision range if not specified
	var/aggro_range_key = BB_AGGRO_RANGE
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

/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/can_search(datum/ai_controller/controller)
	return !(controller.blackboard[BB_FIND_TARGETS_FIELD(type)])

/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/should_keep_target(datum/ai_controller/controller, datum/targeting_strategy/strategy, atom/current_target)
	if(!current_target)
		return FALSE
	if(!strategy.is_valid_target(controller.pawn, current_target, vision_range))
		return FALSE
	var/datum/target_priority_strategy/priority_strategy = GET_TARGET_PRIORITY_STRATEGY(controller.blackboard[priority_strategy_key])
	if(!priority_strategy)
		return TRUE
	return controller.blackboard[BB_BASIC_MOB_TARGET_REFRESH_COOLDOWN] > world.time

/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/on_no_candidates(datum/ai_controller/controller, atom/current_target, datum/targeting_strategy/strategy, range)
	if(current_target && strategy.can_keep_target(controller.pawn, current_target, target_loss_distance))
		return list(current_target)
	if(!current_target)
		failed_to_find_anyone(controller, target_key, targeting_strategy, hiding_location_key)
	return list()

/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/on_no_valid_candidates(datum/ai_controller/controller, atom/current_target)
	if(!current_target)
		failed_to_find_anyone(controller, target_key, targeting_strategy, hiding_location_key)

/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/filter_candidates(datum/ai_controller/controller, list/candidates, datum/targeting_strategy/strategy, atom/current_target)
	var/mob/living/pawn = controller.pawn
	var/datum/target_priority_strategy/priority_strategy = GET_TARGET_PRIORITY_STRATEGY(controller.blackboard[priority_strategy_key])
	var/current_priority = priority_strategy ? priority_strategy.get_target_priority(controller, current_target) : 0
	var/list/filtered = list()
	for(var/atom/candidate as anything in candidates)
		if(!strategy.is_valid_target(pawn, candidate, vision_range, controller))
			continue
		if(priority_strategy && priority_strategy.get_target_priority(controller, candidate) < current_priority)
			continue
		filtered += candidate
	return filtered

/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/on_target_found(datum/ai_controller/controller, atom/target, datum/targeting_strategy/strategy)
	controller.set_blackboard_key(BB_BASIC_MOB_TARGET_REFRESH_COOLDOWN, world.time + priority_refresh_cooldown)
	var/atom/potential_hiding_location = strategy.find_hidden_mobs(controller.pawn, target)
	if(potential_hiding_location)
		controller.set_blackboard_key(hiding_location_key, potential_hiding_location)

/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/proc/failed_to_find_anyone(datum/ai_controller/controller, target_key, targeting_strategy, hiding_location_key)
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
		targeting_strategy,
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
	on_target_found(controller, target, strategy)

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

/// Prioritizes targets carrying the trait named by our trait_key blackboard key over the rest.
/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/prioritize_trait
	/// Blackboard key holding the trait that marks a target as high-priority.
	var/trait_key = BB_TARGET_PRIORITY_TRAIT

/datum/bt_node/ai_behavior/acquire_target/update_combat_targets/prioritize_trait/pick_final_target(datum/ai_controller/controller, list/filtered_targets)
	var/list/priority_targets = list()
	var/priority_trait = controller.blackboard[trait_key]
	for(var/atom/target as anything in filtered_targets)
		if(HAS_TRAIT(target, priority_trait))
			priority_targets += target
	if(length(priority_targets))
		return ..(controller, priority_targets)
	return ..()
