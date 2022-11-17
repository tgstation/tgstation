/// Will try to return to an area if not already inside it, then default to random movement
/datum/idle_behavior/idle_random_walk/go_home
	/// Take this many steps towards your location per cycle, we don't want to set the movement target straight there because we'd get stuck in this idle action

/// If you have a home and aren't in it, try to go there
/datum/idle_behavior/idle_random_walk/go_home/perform_idle_behavior(delta_time, datum/ai_controller/controller)
	if (controller.blackboard[BB_BASIC_MOB_FLEEING])
		return // Too scared right now even to wander randomly

	var/area/home_area = controller.blackboard[BB_MOB_HOME_AREA]
	if (!home_area)
		return ..()
	if (get_area(controller.pawn) == home_area)
		return ..()

	var/datum/weakref/weak_turf = controller.blackboard[BB_MOB_HOME_TURF]
	var/turf/target_turf = weak_turf?.resolve()
	if (!target_turf || target_turf.is_blocked_turf(exclude_mobs = TRUE))
		target_turf = find_home_turf(home_area)
		controller.blackboard[BB_MOB_HOME_TURF] = WEAKREF(target_turf)

	if (target_turf.z != controller.pawn.z)
		return ..() // We're not pathfinding our way out of this one

	if (!target_turf)
		return ..()
	move_towards_turf(controller, target_turf)

/**
 * Get a turf to aim towards, we want to blackboard this and not do it every perform
 * We simply get the first non-blocked turf we can find
 */
/datum/idle_behavior/idle_random_walk/go_home/proc/find_home_turf(area/home_area)
	var/list/home_turfs = get_area_turfs(home_area.type)
	for (var/turf/potential_home as anything in home_turfs)
		if (potential_home.is_blocked_turf(exclude_mobs = TRUE))
			continue
		return potential_home

/// Behaviour you use to move towards your home, to be extended for funky movement types
/datum/idle_behavior/idle_random_walk/go_home/proc/move_towards_turf(datum/ai_controller/controller, turf/home_turf)
	var/mob/living/living_pawn = controller.pawn
	var/direction_to_home = get_dir(living_pawn, home_turf)
	var/turf/destination = get_step(living_pawn, direction_to_home)
	if(!destination)
		return
	living_pawn.Move(destination, direction_to_home)

/// Carp variant which can teleport towards its house if it is blocked
/datum/idle_behavior/idle_random_walk/go_home/carp

/datum/idle_behavior/idle_random_walk/go_home/carp/move_towards_turf(datum/ai_controller/controller, turf/home_turf)
	var/datum/action/cooldown/mob_cooldown/lesser_carp_rift/rift_action = controller.blackboard[BB_CARP_RIFT]
	if (QDELETED(rift_action))
		return ..()
	if (!rift_action.IsAvailable())
		return ..()

	var/direction_to_home = get_dir(controller.pawn, home_turf)
	var/turf/next_turf = get_step(controller.pawn, direction_to_home)
	if (!next_turf.is_blocked_turf(exclude_mobs = TRUE))
		return ..() // Only teleport if we're blocked

	var/distance_to_home = get_dist(controller.pawn, home_turf)
	var/turf/rift_turf = (distance_to_home <= rift_action.max_range) ? home_turf : get_ranged_target_turf(controller.pawn, direction_to_home, rift_action.max_range)
	if (!rift_action.InterceptClickOn(controller.pawn, null, rift_turf))
		return ..()
