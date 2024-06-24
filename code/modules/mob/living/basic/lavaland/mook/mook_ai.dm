///commands the chief can pick from
GLOBAL_LIST_INIT(mook_commands, list(
	new /datum/pet_command/point_targeting/attack,
	new /datum/pet_command/point_targeting/fetch,
))

/datum/ai_controller/basic_controller/mook
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/mook,
		BB_BLACKLIST_MINERAL_TURFS = list(/turf/closed/mineral/gibtonite, /turf/closed/mineral/strong),
		BB_MAXIMUM_DISTANCE_TO_VILLAGE = 7,
		BB_STORM_APPROACHING = FALSE,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/look_for_village,
		/datum/ai_planning_subtree/targeted_mob_ability/leap,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/material_stand,
		/datum/ai_planning_subtree/use_mob_ability/mook_jump,
		/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores/mook,
		/datum/ai_planning_subtree/mine_walls/mook,
		/datum/ai_planning_subtree/wander_away_from_village,
	)
	can_idle = FALSE // these guys are intended to operate even if nobody's around

///check for faction if not a ash walker, otherwise just attack
/datum/targeting_strategy/basic/mook/faction_check(datum/ai_controller/controller, mob/living/living_mob, mob/living/the_target)
	if(FACTION_ASHWALKER in living_mob.faction)
		return FALSE

	return ..()

/datum/ai_planning_subtree/targeted_mob_ability/leap
	ability_key = BB_MOOK_LEAP_ABILITY

/datum/ai_planning_subtree/use_mob_ability/mook_jump
	ability_key = BB_MOOK_JUMP_ABILITY

///jump towards the village when we have found ore or there is a storm coming
/datum/ai_planning_subtree/use_mob_ability/mook_jump/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/storm_approaching = controller.blackboard[BB_STORM_APPROACHING]
	var/mob/living/living_pawn = controller.pawn
	var/obj/effect/home = controller.blackboard[BB_HOME_VILLAGE]
	if(QDELETED(home))
		return
	if(get_dist(living_pawn, home) < controller.blackboard[BB_MAXIMUM_DISTANCE_TO_VILLAGE])
		return
	if(home.z != living_pawn.z)
		return
	if(!storm_approaching && !(locate(/obj/item/stack/ore) in living_pawn))
		return

	controller.clear_blackboard_key(BB_TARGET_MINERAL_WALL)
	return ..()

///hunt ores that we will haul off back to the village
/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores/mook

/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores/mook/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	if(locate(/obj/item/stack/ore) in living_pawn)
		return
	return ..()

///deposit ores into the stand!
/datum/ai_planning_subtree/find_and_hunt_target/material_stand
	target_key = BB_MATERIAL_STAND_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target/material_stand
	finding_behavior = /datum/ai_behavior/find_hunt_target
	hunt_targets = list(/obj/structure/ore_container/material_stand)
	hunt_range = 9

/datum/ai_planning_subtree/find_and_hunt_target/material_stand/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	if(!locate(/obj/item/stack/ore) in living_pawn)
		return
	return ..()

/datum/ai_behavior/hunt_target/unarmed_attack_target/material_stand
	required_distance = 0
	always_reset_target = TRUE
	switch_combat_mode = TRUE
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

///look for our village
/datum/ai_planning_subtree/look_for_village

/datum/ai_planning_subtree/look_for_village/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(BB_HOME_VILLAGE))
		return

	controller.queue_behavior(/datum/ai_behavior/find_village, BB_HOME_VILLAGE)

/datum/ai_behavior/find_village

/datum/ai_behavior/find_village/perform(seconds_per_tick, datum/ai_controller/controller, village_key)

	var/obj/effect/landmark/home_marker = locate(/obj/effect/landmark/mook_village) in GLOB.landmarks_list
	if(isnull(home_marker))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(village_key, home_marker)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

///explore the lands away from the village to look for ore
/datum/ai_planning_subtree/wander_away_from_village

/datum/ai_planning_subtree/wander_away_from_village/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	var/storm_approaching = controller.blackboard[BB_STORM_APPROACHING]
	///if we have ores to deposit or a storm is approaching, dont wander away
	if(storm_approaching || (locate(/obj/item/stack/ore) in living_pawn))
		return

	if(controller.blackboard_key_exists(BB_HOME_VILLAGE))
		controller.queue_behavior(/datum/ai_behavior/wander, BB_HOME_VILLAGE)

/datum/ai_behavior/wander
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	required_distance = 0
	/// distance we will wander away from the village
	var/wander_distance = 9

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
		if(distance_from_target == wander_distance)
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
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_planning_subtree/mine_walls/mook
	find_wall_behavior = /datum/ai_behavior/find_mineral_wall/mook

/datum/ai_planning_subtree/mine_walls/mook/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	var/storm_approaching = controller.blackboard[BB_STORM_APPROACHING]
	if(storm_approaching || locate(/obj/item/stack/ore) in living_pawn)
		return
	return ..()

/datum/ai_behavior/find_mineral_wall/mook

/datum/ai_behavior/find_mineral_wall/mook/check_if_mineable(datum/ai_controller/controller, turf/target_wall)
	var/list/forbidden_turfs = controller.blackboard[BB_BLACKLIST_MINERAL_TURFS]
	if(is_type_in_list(target_wall, forbidden_turfs))
		return FALSE
	return ..()

///bard mook plays nice music for the village
/datum/ai_controller/basic_controller/mook/bard
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/mook,
		BB_MAXIMUM_DISTANCE_TO_VILLAGE = 10,
		BB_STORM_APPROACHING = FALSE,
		BB_SONG_LINES = MOOK_SONG,
	)
	idle_behavior = /datum/idle_behavior/walk_near_target/mook_village
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/look_for_village,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/play_music_for_visitor,
		/datum/ai_planning_subtree/use_mob_ability/mook_jump,
		/datum/ai_planning_subtree/generic_play_instrument,
	)


///find an audience to follow and play music for!
/datum/ai_planning_subtree/play_music_for_visitor

/datum/ai_planning_subtree/play_music_for_visitor/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard_key_exists(BB_MOOK_MUSIC_AUDIENCE))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/music_audience, BB_MOOK_MUSIC_AUDIENCE, /mob/living/carbon/human)
		return
	var/atom/home = controller.blackboard[BB_HOME_VILLAGE]
	if(isnull(home))
		return

	var/atom/human_target = controller.blackboard[BB_MOOK_MUSIC_AUDIENCE]
	if(get_dist(human_target, home) > controller.blackboard[BB_MAXIMUM_DISTANCE_TO_VILLAGE] || controller.blackboard[BB_STORM_APPROACHING])
		controller.clear_blackboard_key(BB_MOOK_MUSIC_AUDIENCE)
		return

	controller.queue_behavior(/datum/ai_behavior/travel_towards, BB_MOOK_MUSIC_AUDIENCE)

/datum/ai_behavior/find_and_set/music_audience

/datum/ai_behavior/find_and_set/music_audience/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/atom/home = controller.blackboard[BB_HOME_VILLAGE]
	for(var/mob/living/carbon/human/target in oview(search_range, controller.pawn))
		if(target.stat > UNCONSCIOUS || !target.mind)
			continue
		if(isnull(home) || get_dist(target, home) > controller.blackboard[BB_MAXIMUM_DISTANCE_TO_VILLAGE])
			continue
		return target

/datum/idle_behavior/walk_near_target/mook_village
	target_key = BB_HOME_VILLAGE

///healer mooks guard the village from intruders and heal the miner mooks when they come home
/datum/ai_controller/basic_controller/mook/support
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/mook,
		BB_MAXIMUM_DISTANCE_TO_VILLAGE = 10,
		BB_STORM_APPROACHING = FALSE,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)
	idle_behavior = /datum/idle_behavior/walk_near_target/mook_village
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/look_for_village,
		/datum/ai_planning_subtree/acknowledge_chief,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/use_mob_ability/mook_jump,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/injured_mooks,
	)

///tree to find and register our leader
/datum/ai_planning_subtree/acknowledge_chief/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(BB_MOOK_TRIBAL_CHIEF))
		return
	controller.queue_behavior(/datum/ai_behavior/find_and_set/find_chief, BB_MOOK_TRIBAL_CHIEF, /mob/living/basic/mining/mook/worker/tribal_chief)

/datum/ai_behavior/find_and_set/find_chief/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/mob/living/chief = locate(locate_path) in oview(search_range, controller.pawn)
	if(isnull(chief))
		return null
	var/mob/living/living_pawn = controller.pawn
	living_pawn.befriend(chief)
	return chief

///find injured miner mooks after they come home from a long day of work
/datum/ai_planning_subtree/find_and_hunt_target/injured_mooks
	target_key = BB_INJURED_MOOK
	hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target/injured_mooks
	finding_behavior = /datum/ai_behavior/find_hunt_target/injured_mooks
	hunt_targets = list(/mob/living/basic/mining/mook/worker)
	hunt_range = 9

///we only heal when the mooks are home during a storm
/datum/ai_planning_subtree/find_and_hunt_target/injured_mooks/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard[BB_STORM_APPROACHING])
		return ..()


/datum/ai_behavior/find_hunt_target/injured_mooks

/datum/ai_behavior/find_hunt_target/injured_mooks/valid_dinner(mob/living/source, mob/living/injured_mook)
	return (injured_mook.health < injured_mook.maxHealth)

/datum/ai_behavior/hunt_target/unarmed_attack_target/injured_mooks

/datum/ai_behavior/hunt_target/unarmed_attack_target/injured_mooks
	always_reset_target = TRUE
	hunt_cooldown = 10 SECONDS


///the chief would rather command his mooks to attack people than attack them himself
/datum/ai_controller/basic_controller/mook/tribal_chief
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/mook,
		BB_STORM_APPROACHING = FALSE,
	)
	idle_behavior = /datum/idle_behavior/walk_near_target/mook_village
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/look_for_village,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/leap,
		/datum/ai_planning_subtree/issue_commands,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/material_stand,
		/datum/ai_planning_subtree/use_mob_ability/mook_jump,
		/datum/ai_planning_subtree/find_and_hunt_target/bonfire,
		/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores/tribal_chief,
	)

/datum/ai_planning_subtree/issue_commands
	///how far we look for a mook to command
	var/command_distance = 5

/datum/ai_planning_subtree/issue_commands/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!locate(/mob/living/basic/mining/mook) in oview(command_distance, controller.pawn))
		return
	if(controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		controller.queue_behavior(/datum/ai_behavior/issue_commands, BB_BASIC_MOB_CURRENT_TARGET, /datum/pet_command/point_targeting/attack)
		return

	var/atom/ore_target = controller.blackboard[BB_ORE_TARGET]
	var/mob/living/living_pawn = controller.pawn
	if(isnull(ore_target))
		return
	if(get_dist(ore_target, living_pawn) <= 1)
		return

	controller.queue_behavior(/datum/ai_behavior/issue_commands, BB_ORE_TARGET, /datum/pet_command/point_targeting/fetch)

/datum/ai_behavior/issue_commands
	action_cooldown = 5 SECONDS

/datum/ai_behavior/issue_commands/perform(seconds_per_tick, datum/ai_controller/controller, target_key, command_path)
	var/mob/living/basic/living_pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]

	if(isnull(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/datum/pet_command/to_command = locate(command_path) in GLOB.mook_commands
	if(isnull(to_command))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/issue_command = pick(to_command.speech_commands)
	living_pawn.say(issue_command, forced = "controller")
	living_pawn._pointed(target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED


///find an ore, only pick it up when a mook brings it close to us
/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores/tribal_chief

/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores/tribal_chief/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	if(locate(/obj/item/stack/ore) in living_pawn)
		return

	var/atom/target_ore = controller.blackboard[BB_ORE_TARGET]

	if(isnull(target_ore))
		return ..()

	if(!isturf(target_ore.loc)) //picked up by someone else
		controller.clear_blackboard_key(BB_ORE_TARGET)
		return

	if(get_dist(target_ore, living_pawn) > 1)
		return

	return ..()

/datum/ai_planning_subtree/find_and_hunt_target/bonfire
	target_key = BB_MOOK_BONFIRE_TARGET
	finding_behavior = /datum/ai_behavior/find_hunt_target/bonfire
	hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target/bonfire
	hunt_targets = list(/obj/structure/bonfire)
	hunt_range = 9


/datum/ai_behavior/find_hunt_target/bonfire

/datum/ai_behavior/find_hunt_target/bonfire/valid_dinner(mob/living/source, obj/structure/bonfire/fire, radius)
	if(fire.burning)
		return FALSE

	return can_see(source, fire, radius)

/datum/ai_behavior/hunt_target/unarmed_attack_target/bonfire
	always_reset_target = TRUE
