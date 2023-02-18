/// If there's something between us and our target then we need to queue a behaviour to make it not be there
/datum/ai_planning_subtree/attack_obstacle_in_path
	/// Blackboard key containing current target
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET
	/// The action to execute, extend to add a different cooldown or something
	var/attack_behaviour = /datum/ai_behavior/attack_obstructions

/datum/ai_planning_subtree/attack_obstacle_in_path/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()

	if(isnull(target))
		return

	var/turf/next_step = get_step_towards(controller.pawn, target)
	if (!next_step.is_blocked_turf(exclude_mobs = TRUE, source_atom = controller.pawn))
		return

	controller.queue_behavior(attack_behaviour, target_key)
	// Don't cancel future planning, maybe we can move now

/// Something is in our way, get it outta here
/datum/ai_behavior/attack_obstructions
	action_cooldown = 2 SECONDS
	/// If we should attack walls, be prepared for complaints about breaches
	var/can_attack_turfs = FALSE
	/// Tries to bump open airlocks with an attack
	var/bump_open_airlock = FALSE

/datum/ai_behavior/attack_obstructions/perform(delta_time, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/basic/basic_mob = controller.pawn
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()

	if (!target)
		finish_action(controller, succeeded = FALSE)
		return

	var/turf/next_step = get_step_towards(basic_mob, target)
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
	finish_action(controller, succeeded = TRUE)

/datum/ai_behavior/attack_obstructions/proc/attack_in_direction(datum/ai_controller/controller, mob/living/basic/basic_mob, direction)
	var/turf/next_step = get_step(basic_mob, direction)
	if (!next_step.is_blocked_turf(exclude_mobs = TRUE, source_atom = controller.pawn))
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

/datum/ai_behavior/attack_obstructions/proc/can_smash_object(mob/living/basic/basic_mob, obj/object)
	if (!object.density)
		return FALSE
	if (object.IsObscured())
		return FALSE
	if (basic_mob.see_invisible < object.invisibility)
		return FALSE
	return TRUE // It's in our way, let's get it out of our way

/datum/ai_planning_subtree/attack_obstacle_in_path/low_priority_target
	target_key = BB_LOW_PRIORITY_HUNTING_TARGET
