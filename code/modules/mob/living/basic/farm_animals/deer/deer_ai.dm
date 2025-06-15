/datum/ai_controller/basic_controller/deer
	blackboard = list(
		BB_STATIONARY_MOVE_TO_TARGET = TRUE,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/deer,
		/datum/ai_planning_subtree/stare_at_thing,
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/rest_at_home,
		/datum/ai_planning_subtree/play_with_friends,
		/datum/ai_planning_subtree/find_and_hunt_target/mark_territory,
		/datum/ai_planning_subtree/find_and_hunt_target/graze,
		/datum/ai_planning_subtree/find_and_hunt_target/drink_water,
	)


///subtree to go around drinking water
/datum/ai_planning_subtree/find_and_hunt_target/drink_water
	target_key = BB_DEER_WATER_TARGET
	finding_behavior = /datum/ai_behavior/find_and_set/in_list/turf_types
	hunting_behavior = /datum/ai_behavior/hunt_target/drink_water
	hunt_targets = list(/turf/open/water)
	hunt_range = 7
	hunt_chance = 5


/datum/ai_behavior/hunt_target/drink_water
	always_reset_target = TRUE
	hunt_cooldown = 20 SECONDS


/datum/ai_behavior/hunt_target/drink_water/target_caught(mob/living/hunter, atom/hunted)
	var/static/list/possible_emotes = list("drinks the water!", "dances in the water!", "splashes around happily!")
	hunter.manual_emote(pick(possible_emotes))


///subtree to go around grazing
/datum/ai_planning_subtree/find_and_hunt_target/graze
	target_key = BB_DEER_GRASS_TARGET
	finding_behavior = /datum/ai_behavior/find_and_set/in_list/turf_types
	hunting_behavior = /datum/ai_behavior/hunt_target/eat_grass
	hunt_targets = list(/turf/open/floor/grass)
	hunt_range = 7
	hunt_chance = 45


/datum/ai_behavior/hunt_target/eat_grass
	always_reset_target = TRUE
	hunt_cooldown = 15 SECONDS


/datum/ai_behavior/hunt_target/eat_grass/target_caught(mob/living/hunter, atom/hunted)
	var/static/list/possible_emotes = list("eats the grass!", "munches down the grass!", "chews on the grass!")
	hunter.manual_emote(pick(possible_emotes))


///subtree to go around playing with other deers
/datum/ai_planning_subtree/play_with_friends


/datum/ai_planning_subtree/play_with_friends/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/static/list/emote_list = list("plays with", "dances with", "celebrates with")
	var/static/list/friend_types = typecacheof(list(/mob/living/basic/deer))
	if(controller.blackboard_key_exists(BB_DEER_PLAYFRIEND))
		controller.queue_behavior(/datum/ai_behavior/emote_on_target, BB_DEER_PLAYFRIEND, emote_list)
	if(SPT_PROB(3, seconds_per_tick))
		controller.queue_behavior(/datum/ai_behavior/find_hunt_target/valid_deer, BB_DEER_PLAYFRIEND, friend_types)
		return SUBTREE_RETURN_FINISH_PLANNING


/datum/ai_behavior/emote_on_target/deer_play


/datum/ai_behavior/emote_on_target/deer_play/run_emote(mob/living/living_pawn, atom/target, list/emote_list)
	. = ..()
	living_pawn.spin(spintime = 4, speed = 1)


/datum/ai_behavior/find_hunt_target/valid_deer/valid_dinner(mob/living/source, mob/living/deer, radius, datum/ai_controller/controller, seconds_per_tick)
	if(deer.stat == DEAD)
		return FALSE
	if(!can_see(source, deer, radius))
		return FALSE
	deer.ai_controller?.set_blackboard_key(BB_DEER_PLAYFRIEND, source)
	return can_see(source, deer, radius)


///subtree to mark trees as territories
/datum/ai_planning_subtree/find_and_hunt_target/mark_territory
	target_key = BB_DEER_TREE_TARGET
	finding_behavior = /datum/ai_behavior/find_hunt_target
	hunting_behavior = /datum/ai_behavior/hunt_target/mark_territory
	hunt_targets = list(/obj/structure/flora/tree)
	hunt_range = 7
	hunt_chance = 75


/datum/ai_behavior/hunt_target/mark_territory
	always_reset_target = TRUE
	hunt_cooldown = 15 SECONDS


/datum/ai_behavior/hunt_target/mark_territory/target_caught(mob/living/hunter, atom/hunted)
	hunter.manual_emote("marks [hunted] with its hooves!")
	hunter.ai_controller.set_blackboard_key(BB_DEER_TREEHOME, hunted)


/datum/ai_planning_subtree/find_and_hunt_target/mark_territory/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(BB_DEER_TREEHOME)) //already found our home, abort!
		return
	return ..()


/datum/ai_planning_subtree/rest_at_home/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard[BB_DEER_RESTING] > world.time) //we're resting for now, nothing more to do
		return SUBTREE_RETURN_FINISH_PLANNING
	if(!controller.blackboard_key_exists(BB_DEER_TREEHOME) || controller.blackboard[BB_DEER_NEXT_REST_TIMER] > world.time)
		return
	controller.queue_behavior(/datum/ai_behavior/return_home, BB_DEER_TREEHOME)


/datum/ai_behavior/return_home
	required_distance = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	///minimum time till next rest
	var/minimum_time = 2 MINUTES
	///maximum time till next rest
	var/maximum_time = 4 MINUTES


/datum/ai_behavior/return_home/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	var/list/possible_turfs = get_adjacent_open_turfs(target)
	shuffle_inplace(possible_turfs)
	for(var/turf/possible_turf as anything in possible_turfs)
		if(!possible_turf.is_blocked_turf())
			set_movement_target(controller, possible_turf)
			return TRUE
	return FALSE


/datum/ai_behavior/return_home/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/living_pawn = controller.pawn
	var/static/list/possible_emotes = list("rests its legs...", "yawns and naps...", "curls up and rests...")
	living_pawn.manual_emote(pick(possible_emotes))
	controller.set_blackboard_key(BB_DEER_RESTING, world.time + 15 SECONDS)
	controller.set_blackboard_key(BB_DEER_NEXT_REST_TIMER, world.time + rand(minimum_time, maximum_time))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
