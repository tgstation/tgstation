

/datum/ai_controller/basic_controller/bee
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/bee,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_valid_home,
		/datum/ai_planning_subtree/enter_exit_home,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/pollinate,
	)

/datum/ai_planning_subtree/find_valid_home

/datum/ai_planning_subtree/find_valid_home/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/work_bee = controller.pawn

	var/obj/structure/beebox/current_home = controller.blackboard[BB_CURRENT_HOME]

	if(QDELETED(current_home))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/bee_hive, BB_CURRENT_HOME, /obj/structure/beebox)
		return

	if(work_bee in current_home.bees)
		return

	controller.queue_behavior(/datum/ai_behavior/inhabit_hive, BB_CURRENT_HOME)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_planning_subtree/enter_exit_home
	///chance we go back home
	var/flyback_chance = 15
	///chance we exit the home
	var/exit_chance = 35

/datum/ai_planning_subtree/enter_exit_home/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)

	var/obj/structure/beebox/current_home = controller.blackboard[BB_CURRENT_HOME]

	if(QDELETED(current_home))
		return

	var/mob/living/bee_pawn = controller.pawn
	var/action_prob =  (bee_pawn in current_home.contents) ? exit_chance : flyback_chance

	if(!SPT_PROB(action_prob, seconds_per_tick))
		return

	controller.queue_behavior(/datum/ai_behavior/enter_exit_hive, BB_CURRENT_HOME)
	return SUBTREE_RETURN_FINISH_PLANNING


/datum/ai_planning_subtree/find_and_hunt_target/pollinate
	target_key = BB_TARGET_HYDRO
	hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target/bees
	finding_behavior = /datum/ai_behavior/find_hunt_target/pollinate
	hunt_targets = list(/obj/machinery/hydroponics)
	hunt_range = 7
	//hunt_chance = 10


/datum/ai_behavior/hunt_target/unarmed_attack_target/bees
	always_reset_target = TRUE

/datum/ai_behavior/find_hunt_target/pollinate

/datum/ai_behavior/find_hunt_target/pollinate/valid_dinner(mob/living/source, obj/machinery/hydroponics/dinner, radius)
	if(!dinner.myseed)
		return FALSE
	if(dinner.plant_status == HYDROTRAY_PLANT_DEAD || dinner.recent_bee_visit)
		return FALSE

	return can_see(source, dinner, radius)

/datum/ai_behavior/enter_exit_hive
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/enter_exit_hive/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/enter_exit_hive/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/obj/structure/beebox/current_home = controller.blackboard[target_key]
	var/mob/living/bee_pawn = controller.pawn

	bee_pawn.UnarmedAttack(current_home)
	finish_action(controller, TRUE)

/datum/ai_behavior/inhabit_hive
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/inhabit_hive/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/inhabit_hive/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/obj/structure/beebox/potential_home = controller.blackboard[target_key]
	var/mob/living/bee_pawn = controller.pawn

	if(!potential_home.habitable(bee_pawn)) //the house become full before we get to it
		finish_action(controller, FALSE, target_key)
		return

	bee_pawn.UnarmedAttack(potential_home) //interact with the house to inhabit
	finish_action(controller, TRUE, target_key)

/datum/ai_behavior/inhabit_hive/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if(!succeeded)
		controller.clear_blackboard_key(target_key) //failed to make it our home so find another

/datum/ai_behavior/find_and_set/bee_hive
	action_cooldown = 10 SECONDS

/datum/ai_behavior/find_and_set/bee_hive/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/list/valid_hives = list()
	var/mob/living/bee_pawn = controller.pawn

	if(istype(bee_pawn.loc, /obj/structure/beebox))
		return bee_pawn.loc //for premade homes

	for(var/obj/structure/beebox/potential_home in oview(search_range, bee_pawn))
		if(!potential_home.habitable(bee_pawn))
			continue
		valid_hives += potential_home

	if(valid_hives.len)
		return pick(valid_hives)

/datum/targetting_datum/basic/bee

/datum/targetting_datum/basic/bee/can_attack(mob/living/owner, atom/target)
	if(!isliving(target))
		return FALSE
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/mob_target = target
	return !(mob_target.bee_friendly())

/datum/ai_controller/basic_controller/queen_bee
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/bee,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_valid_home,
		/datum/ai_planning_subtree/enter_exit_home/queen,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

//the queen spend more time in the hive
/datum/ai_planning_subtree/enter_exit_home/queen
	flyback_chance = 85
	exit_chance = 5
