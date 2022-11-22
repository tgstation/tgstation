/**
 * # Attack obstacle in path
 * Will attack something which is one tile away from you in a straight line between you and your target
 * This isn't a movement behaviour and will only attack things you're next to when it executes
 */
/datum/ai_behavior/attack_obstacle_in_path
	action_cooldown = 0.6 SECONDS
	/// If we should attack walls, be prepared for complaints about breaches
	var/attack_walls = FALSE

/datum/ai_behavior/attack_obstacle_in_path/setup(datum/ai_controller/controller, target_key)
	. = ..()
	//Hiding location is priority
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	if(!target)
		return FALSE

/datum/ai_behavior/attack_obstacle_in_path/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	var/mob/living/basic/basic_mob = controller.pawn
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()

	if (!target)
		finish_action(controller, succeeded = FALSE)
		return

	var/turf/next_step = get_step_towards(basic_mob, target)
	if (next_step == get_turf(basic_mob))
		finish_action(controller, succeeded = FALSE)
		return

	var/dir_to_next_step = get_dir(basic_mob, next_step)

	// If moving diagonally we need to punch both ways, or more accurately the one we are blocked in
	var/list/dirs_to_move = list()
	if (ISDIAGONALDIR(dir_to_next_step))
		for(var/direction in GLOB.cardinals)
			if(direction & dir_to_next_step)
				dirs_to_move += direction
	else
		dirs_to_move += dir_to_next_step

	for (var/direction in dirs_to_move)
		if (attack_in_direction(controller, basic_mob, direction))
			return

	finish_action(controller, succeeded = FALSE)

/datum/ai_behavior/attack_obstacle_in_path/proc/attack_in_direction(datum/ai_controller/controller, mob/living/basic/basic_mob, direction)
	var/turf/next_step = get_step(basic_mob, direction)
	if (!next_step.is_blocked_turf(exclude_mobs = TRUE))
		return FALSE

	for (var/obj/object as anything in next_step.contents)
		if (!ismachinery(object) && !isstructure(object))
			continue
		if (!object.density)
			continue
		if (object.IsObscured())
			continue
		basic_mob.melee_attack(object)
		finish_action(controller, succeeded = TRUE)
		return TRUE

	if (attack_walls) // A basic mob will need the wall_smasher element for this to do anything
		basic_mob.melee_attack(next_step)
		finish_action(controller, succeeded = TRUE)
		return TRUE
	return FALSE
