/datum/ai_controller/basic_controller/mook
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
		BB_BLACKLIST_MINERAL_TURFS = list(/turf/closed/mineral/gibtonite, /turf/closed/mineral/strong),
		BB_MAXIMUM_DISTANCE_TO_VILLAGE = 7,
		BB_STORM_APPROACHING = FALSE,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_and_hunt_target/material_stand,
		/datum/ai_planning_subtree/use_mob_ability/mook_jump,
		/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores/mook,
		/datum/ai_planning_subtree/mine_walls/mook,
		/datum/ai_planning_subtree/wander_away_from_village,
	)


/datum/ai_planning_subtree/use_mob_ability/mook_jump
	ability_key = BB_MOOK_JUMP_ABILITY

/datum/ai_planning_subtree/use_mob_ability/mook_jump/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/storm_approaching = controller.blackboard[BB_STORM_APPROACHING]
	var/mob/living/living_pawn = controller.pawn
	var/obj/effect/home = controller.blackboard[BB_HOME_VILLAGE]
	if(QDELETED(home))
		return
	if(get_dist(living_pawn, home) < controller.blackboard[BB_MAXIMUM_DISTANCE_TO_VILLAGE])
		return
	if(storm_approaching || (locate(/obj/item/stack/ore) in living_pawn))
		controller.clear_blackboard_key(BB_TARGET_MINERAL_WALL)
		return ..()

/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores/mook

/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores/mook/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	if(locate(/obj/item/stack/ore) in living_pawn)
		return
	return ..()

/datum/ai_planning_subtree/find_and_hunt_target/material_stand
	target_key = BB_MATERIAL_STAND_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target/material_stand
	finding_behavior = /datum/ai_behavior/find_hunt_target
	hunt_targets = list(/obj/structure/material_stand)
	hunt_range = 9

/datum/ai_planning_subtree/find_and_hunt_target/material_stand/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	if(!locate(/obj/item/stack/ore) in living_pawn)
		return
	return ..()

/datum/ai_behavior/hunt_target/unarmed_attack_target/material_stand
	required_distance = 0
	always_reset_target = TRUE
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

///try to face the counter when depositing ores
/datum/ai_behavior/hunt_target/unarmed_attack_target/material_stand/setup(datum/ai_controller/controller, hunting_target_key, hunting_cooldown_key)
	. = ..()
	var/atom/hunt_target = controller.blackboard[hunting_target_key]
	if (QDELETED(hunt_target))
		return FALSE
	var/list/possible_turfs = list()
	var/list/directions = list(SOUTH, SOUTHEAST)

	for(var/direction in directions)
		var/turf/bottom_turf = get_step(hunt_target, direction)
		if(!bottom_turf.is_blocked_turf())
			possible_turfs += bottom_turf

	if(!length(possible_turfs))
		return FALSE
	set_movement_target(controller, pick(possible_turfs))


/datum/ai_planning_subtree/wander_away_from_village

/datum/ai_planning_subtree/wander_away_from_village/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	var/storm_approaching = controller.blackboard[BB_STORM_APPROACHING]
	///if we have ores to deposit or a storm is approaching, dont wander away
	if(storm_approaching || (locate(/obj/item/stack/ore) in living_pawn))
		return

	if(controller.blackboard_key_exists(BB_HOME_VILLAGE))
		controller.queue_behavior(/datum/ai_behavior/wander, BB_HOME_VILLAGE)
		return

	controller.queue_behavior(/datum/ai_behavior/find_village, BB_HOME_VILLAGE)

/datum/ai_behavior/find_village

/datum/ai_behavior/find_village/perform(seconds_per_tick, datum/ai_controller/controller, village_key)
	. = ..()

	var/obj/effect/landmark/home_marker = locate(/obj/effect/landmark/mook_village) in GLOB.landmarks_list
	if(isnull(home_marker))
		finish_action(controller, FALSE)
		return

	controller.set_blackboard_key(village_key, home_marker)
	finish_action(controller, TRUE)

/datum/ai_behavior/wander
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	var/wander_distance = 9
	required_distance = 0

/datum/ai_behavior/wander/setup(datum/ai_controller/controller, village_key)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	var/obj/effect/target = controller.blackboard[village_key]
	if(QDELETED(target))
		return FALSE

	if(target.z != living_pawn.z)
		return FALSE

	var/list/angle_directions = list()
	for(var/direction in GLOB.alldirs)
		angle_directions += dir2angle(direction)

	var/angle_to_home = get_angle(living_pawn, target)
	angle_directions -= angle_to_home
	angle_directions -= (angle_to_home + 45)
	angle_directions -= (angle_to_home - 45)
	shuffle_inplace(angle_directions)

	var/turf/wander_destination = get_turf(living_pawn)
	for(var/angle in angle_directions)
		var/turf/test_turf = get_furthest_turf(living_pawn, angle, target)
		if(isnull(test_turf))
			continue
		var/distance_from_target = get_dist(target, test_turf)
		if(distance_from_target <= get_dist(target, wander_destination))
			continue
		wander_destination = test_turf
		if(distance_from_target == wander_distance) //we already got the max running distance
			break

	set_movement_target(controller, wander_destination)

/datum/ai_behavior/wander/proc/get_furthest_turf(atom/source, angle, atom/target)
	var/turf/return_turf
	for(var/i in 1 to wander_distance)
		var/turf/test_destination = get_ranged_target_turf_direct(source, target, range = i, offset = angle)
		if(test_destination.is_blocked_turf(source_atom = source))
			break
		return_turf = test_destination
	return return_turf

/datum/ai_behavior/wander/perform(seconds_per_tick, datum/ai_controller/controller, target_key, hiding_location_key)
	. = ..()
	finish_action(controller, TRUE)

/datum/ai_planning_subtree/mine_walls/mook
	find_wall_behavior = /datum/ai_behavior/find_mineral_wall/mook

/datum/ai_behavior/find_mineral_wall/mook

/datum/ai_behavior/find_mineral_wall/mook/check_if_mineable(datum/ai_controller/controller, turf/target_wall)
	var/list/forbidden_turfs = controller.blackboard[BB_BLACKLIST_MINERAL_TURFS]
	if(is_type_in_list(target_wall, forbidden_turfs))
		return FALSE
	return ..()
