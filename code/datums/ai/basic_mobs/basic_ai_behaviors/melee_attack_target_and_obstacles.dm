/**
 * # Attack target & obstacles
 * Maintain and move towards your current target, attack them when in range
 * Check for impediments in front of the mob every perform and attack those if it cannot reach the target
 * The obstacle attack check bypasses the targetting datum, otherwise usually the mob would aggro onto random windows instead of enemies
 */
/datum/ai_behavior/basic_melee_attack/attack_obstacles
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	/// If we should attack walls, be prepared for complaints about breaches
	var/can_attack_turfs = FALSE

/datum/ai_behavior/basic_melee_attack/attack_obstacles/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	controller.behavior_cooldowns[src] = world.time + action_cooldown
	var/mob/living/basic/basic_mob = controller.pawn
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()

	if (!target)
		finish_action(controller, succeeded = FALSE)
		return

	if (get_dist(basic_mob, target) <= required_distance)
		return ..()

	var/turf/next_step = get_step_towards(basic_mob, target)
	if (!next_step.is_blocked_turf(exclude_mobs = TRUE))
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

/datum/ai_behavior/basic_melee_attack/attack_obstacles/proc/attack_in_direction(datum/ai_controller/controller, mob/living/basic/basic_mob, direction)
	var/turf/next_step = get_step(basic_mob, direction)
	if (!next_step.is_blocked_turf(exclude_mobs = TRUE))
		return FALSE

	for (var/obj/object as anything in next_step.contents)
		if (!can_smash_object(basic_mob, object))
			continue
		basic_mob.melee_attack(object)
		return TRUE

	if (can_attack_turfs)
		basic_mob.melee_attack(next_step)
		return TRUE
	return FALSE

/datum/ai_behavior/basic_melee_attack/attack_obstacles/proc/can_smash_object(mob/living/basic/basic_mob, obj/object)
	if (!object.density)
		return FALSE
	if (object.IsObscured())
		return FALSE
	if (basic_mob.see_invisible < object.invisibility)
		return FALSE
	return TRUE // It's in our way, let's get it out of our way
