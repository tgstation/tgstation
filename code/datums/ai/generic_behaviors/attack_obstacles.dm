
///Destroy shit int he way
/datum/bt_node/ai_behavior/attack_obstructions
	var/target_key
	time_between_perform = 2 SECONDS
	/// If we should attack walls, be prepared for complaints about breaches
	var/can_attack_turfs = FALSE
	/// For if you want your mob to be able to attack dense objects
	var/can_attack_dense_objects = FALSE

/datum/bt_node/ai_behavior/attack_obstructions/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/basic_mob = controller.pawn
	var/atom/target = controller.blackboard[target_key]

	if(QDELETED(target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/turf/next_step = get_step_towards(basic_mob, target)
	if(!next_step.is_blocked_turf(exclude_mobs = TRUE, source_atom = controller.pawn))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED // Path clear — let selector fall through to melee

	var/dir_to_next_step = get_dir(basic_mob, next_step)
	var/list/dirs_to_move = list()
	if(ISDIAGONALDIR(dir_to_next_step))
		for(var/direction in GLOB.cardinals)
			if(direction & dir_to_next_step)
				dirs_to_move += direction
	else
		dirs_to_move += dir_to_next_step

	for(var/direction in dirs_to_move)
		if(attack_in_direction(controller, basic_mob, direction))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED // Nothing smashable — let selector fall through

/datum/bt_node/ai_behavior/attack_obstructions/proc/attack_in_direction(datum/ai_controller/controller, mob/living/basic/basic_mob, direction)
	var/turf/next_step = get_step(basic_mob, direction)
	if(!next_step.is_blocked_turf(exclude_mobs = TRUE, source_atom = controller.pawn))
		return FALSE

	for(var/obj/object as anything in next_step.contents)
		if(!can_smash_object(basic_mob, object))
			continue
		basic_mob.melee_attack(object)
		return TRUE

	if(can_attack_turfs)
		basic_mob.melee_attack(next_step)
		return TRUE
	return FALSE

/datum/bt_node/ai_behavior/attack_obstructions/proc/can_smash_object(mob/living/basic/basic_mob, obj/object)
	if(!object.density && !can_attack_dense_objects)
		return FALSE
	if(object.IsObscured())
		return FALSE
	if(basic_mob.see_invisible < object.invisibility)
		return FALSE
	var/list/whitelist = basic_mob.ai_controller.blackboard[BB_OBSTACLE_TARGETING_WHITELIST]
	if(whitelist && !is_type_in_typecache(object, whitelist))
		return FALSE
	return TRUE

/datum/bt_node/ai_behavior/attack_obstructions/attack_turfs
	can_attack_turfs = TRUE
