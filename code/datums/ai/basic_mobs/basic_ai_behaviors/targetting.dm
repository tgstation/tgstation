/datum/ai_behavior/find_potential_targets
	action_cooldown = 2 SECONDS
	/// How far can we see stuff?
	var/vision_range = 9
	/// Blackboard key for aggro range, uses vision range if not specified
	var/aggro_range_key = BB_AGGRO_RANGE
	/// Static typecache list of things we are interested in
	var/static/list/interesting_atoms = typecacheof(list(/mob, /obj/machinery/porta_turret, /obj/vehicle/sealed/mecha))

/datum/ai_behavior/find_potential_targets/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	var/mob/living/living_mob = controller.pawn
	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]

	if(!targetting_datum)
		CRASH("No target datum was supplied in the blackboard for [controller.pawn]")

	var/atom/current_target = controller.blackboard[target_key]
	if (targetting_datum.can_attack(living_mob, current_target, vision_range))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/aggro_range = controller.blackboard[aggro_range_key] || vision_range

	controller.clear_blackboard_key(target_key)

	// If we're using a field rn, just don't do anything yeah?
	if(controller.blackboard[BB_FIND_TARGETS_FIELD(type)])
		return AI_BEHAVIOR_DELAY

	var/list/potential_targets = hearers(aggro_range, get_turf(controller.pawn)) - living_mob //Remove self, so we don't suicide

	for(var/obj/machinery/enemy_spotted in range(aggro_range, living_mob))
		// Stand down private
		if(!is_type_in_typecache(enemy_spotted, interesting_atoms))
			continue
		potential_targets += enemy_spotted

	if(!potential_targets.len)
		failed_to_find_anyone(controller, target_key, targetting_datum_key, hiding_location_key)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/list/filtered_targets = list()
	for(var/atom/pot_target in potential_targets)
		if(!targetting_datum.can_attack(living_mob, pot_target))//Can we attack it?
			continue
		filtered_targets += pot_target

	if(!filtered_targets.len)
		failed_to_find_anyone(controller, target_key, targetting_datum_key, hiding_location_key)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/atom/target = pick_final_target(controller, filtered_targets)
	controller.set_blackboard_key(target_key, target)

	var/atom/potential_hiding_location = targetting_datum.find_hidden_mobs(living_mob, target)

	if(potential_hiding_location) //If they're hiding inside of something, we need to know so we can go for that instead initially.
		controller.set_blackboard_key(hiding_location_key, potential_hiding_location)

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/find_potential_targets/proc/failed_to_find_anyone(datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	var/aggro_range = controller.blackboard[aggro_range_key] || vision_range
	// takes the larger between our range() input and our implicit hearers() input (world.view)
	aggro_range = max(aggro_range, ROUND_UP(max(getviewsize(world.view)) / 2))
	// Alright, here's the interesting bit
	// We're gonna use this max range to hook into a proximity field so we can just await someone interesting to come along
	// Rather then trying to check every few seconds
	var/datum/proximity_monitor/detection_field = new /datum/proximity_monitor/advanced/ai_target_tracking(
		controller.pawn,
		aggro_range,
		TRUE,
		src,
		controller,
		target_key,
		targetting_datum_key,
		hiding_location_key,
	)
	// We're gonna store this field in our blackboard, so we can clear it away if we end up finishing successsfully
	controller.set_blackboard_key(BB_FIND_TARGETS_FIELD(type), detection_field)

/datum/ai_behavior/find_potential_targets/proc/new_turf_found(turf/found, datum/ai_controller/controller, datum/targetting_datum/targetting_datum)
	var/valid_found = FALSE
	var/mob/pawn = controller.pawn
	for(var/maybe_target as anything in found)
		if(maybe_target == pawn)
			continue
		if(!is_type_in_typecache(maybe_target, interesting_atoms))
			continue
		if(!targetting_datum.can_attack(pawn, maybe_target))
			continue
		valid_found = TRUE
		break
	if(!valid_found)
		return
	// If we found any one thing we "could" attack, then run the full search again so we can select from the best possible canidate
	var/datum/proximity_monitor/field = controller.blackboard[BB_FIND_TARGETS_FIELD(type)]
	qdel(field) // autoclears so it's fine

/datum/ai_behavior/find_potential_targets/proc/atom_allowed(atom/movable/checking, datum/targetting_datum/targetting_datum, mob/pawn)
	if(checking == pawn)
		return FALSE
	if(!ismob(checking) && !is_type_in_typecache(checking, interesting_atoms))
		return FALSE
	if(!targetting_datum.can_attack(pawn, checking))
		return FALSE
	return TRUE

/datum/ai_behavior/find_potential_targets/proc/new_atoms_found(list/atom/movable/found, datum/ai_controller/controller, target_key, datum/targetting_datum/targetting_datum, hiding_location_key)
	var/mob/pawn = controller.pawn
	var/list/accepted_targets = list()
	for(var/maybe_target as anything in found)
		if(maybe_target == pawn)
			continue
		// Need to better handle viewers here
		if(!ismob(maybe_target) && !is_type_in_typecache(maybe_target, interesting_atoms))
			continue
		if(!targetting_datum.can_attack(pawn, maybe_target))
			continue
		accepted_targets += maybe_target

	// Alright, we found something acceptable, let's use it yeah?
	var/atom/target = pick_final_target(controller, accepted_targets)
	controller.set_blackboard_key(target_key, target)

	var/atom/potential_hiding_location = targetting_datum.find_hidden_mobs(pawn, target)

	if(potential_hiding_location) //If they're hiding inside of something, we need to know so we can go for that instead initially.
		controller.set_blackboard_key(hiding_location_key, potential_hiding_location)

	finish_action(controller, succeeded = TRUE)

/datum/ai_behavior/find_potential_targets/finish_action(datum/ai_controller/controller, succeeded, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	if (succeeded)
		var/datum/proximity_monitor/field = controller.blackboard[BB_FIND_TARGETS_FIELD(type)]
		qdel(field) // autoclears so it's fine
		controller.CancelActions() // On retarget cancel any further queued actions so that they will setup again with new target

/// Returns the desired final target from the filtered list of targets
/datum/ai_behavior/find_potential_targets/proc/pick_final_target(datum/ai_controller/controller, list/filtered_targets)
	return pick(filtered_targets)
