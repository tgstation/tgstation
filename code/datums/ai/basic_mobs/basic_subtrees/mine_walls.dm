//behavior to find mineable mineral walls

/datum/ai_planning_subtree/mine_walls
	var/find_wall_behavior = /datum/ai_behavior/find_mineral_wall

/datum/ai_planning_subtree/mine_walls/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(BB_TARGET_MINERAL_WALL))
		controller.queue_behavior(/datum/ai_behavior/mine_wall, BB_TARGET_MINERAL_WALL)
		return SUBTREE_RETURN_FINISH_PLANNING
	controller.queue_behavior(find_wall_behavior, BB_TARGET_MINERAL_WALL)

/datum/ai_behavior/mine_wall
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	action_cooldown = 15 SECONDS

/datum/ai_behavior/mine_wall/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/turf/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/mine_wall/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/basic/living_pawn = controller.pawn
	var/turf/closed/mineral/target = controller.blackboard[target_key]
	var/is_gibtonite_turf = istype(target, /turf/closed/mineral/gibtonite)
	if(!controller.ai_interact(target = target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(is_gibtonite_turf)
		living_pawn.manual_emote("sighs...") //accept whats about to happen to us

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/mine_wall/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/datum/ai_behavior/find_mineral_wall

/datum/ai_behavior/find_mineral_wall/perform(seconds_per_tick, datum/ai_controller/controller, found_wall_key)
	var/mob/living_pawn = controller.pawn

	for(var/turf/closed/mineral/potential_wall in oview(9, living_pawn))
		if(!check_if_mineable(controller, potential_wall)) //check if its surrounded by walls
			continue
		controller.set_blackboard_key(found_wall_key, potential_wall) //closest wall first!
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/ai_behavior/find_mineral_wall/proc/check_if_mineable(datum/ai_controller/controller, turf/target_wall)
	var/mob/living/source = controller.pawn
	var/direction_to_turf = get_dir(target_wall, source)
	if(!ISDIAGONALDIR(direction_to_turf))
		return TRUE
	var/list/directions_to_check = list()
	for(var/direction_check in GLOB.cardinals)
		if(direction_check & direction_to_turf)
			directions_to_check += direction_check

	for(var/direction in directions_to_check)
		var/turf/test_turf = get_step(target_wall, direction)
		if(isnull(test_turf))
			continue
		if(!test_turf.is_blocked_turf(ignore_atoms = list(source)))
			return TRUE
	return FALSE
