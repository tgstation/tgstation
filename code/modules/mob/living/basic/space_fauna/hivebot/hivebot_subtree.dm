/datum/ai_controller/basic_controller/hivebot
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/hive_communicate,
	)

/datum/ai_controller/basic_controller/hivebot/mechanic
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/find_and_hunt_target/repair_machines,
		/datum/ai_planning_subtree/hive_communicate,
	)

/datum/ai_controller/basic_controller/hivebot/ranged
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/hivebot,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/hive_communicate,
	)

/datum/ai_controller/basic_controller/hivebot/ranged/rapid
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/hive_communicate,
	)


/datum/ai_planning_subtree/basic_ranged_attack_subtree/hivebot_rapid
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/hivebot_rapid


/datum/ai_planning_subtree/basic_ranged_attack_subtree/hivebot
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/hivebot

/datum/ai_planning_subtree/hive_communicate
	///chance to go and relay message
	var/relay_chance = 10

/datum/ai_planning_subtree/hive_communicate/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)

	if(!SPT_PROB(relay_chance, seconds_per_tick))
		return

	var/mob/hive_target = controller.blackboard[BB_HIVE_PARTNER]

	if(QDELETED(hive_target))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/hive_partner, BB_HIVE_PARTNER, /mob/living/basic/hivebot)
		return

	controller.queue_behavior(/datum/ai_behavior/relay_message, BB_HIVE_PARTNER)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_planning_subtree/find_and_hunt_target/repair_machines
	target_key = BB_MACHINE_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/repair_machines
	finding_behavior = /datum/ai_behavior/find_hunt_target/repair_machines
	hunt_targets = list(/obj/machinery)
	hunt_range = 10
	hunt_chance = 35
