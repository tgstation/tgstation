/datum/ai_controller/basic_controller/bear
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/bear,
		/datum/ai_planning_subtree/climb_trees,
		/datum/ai_planning_subtree/find_and_hunt_target/find_hive,
		/datum/ai_planning_subtree/find_and_hunt_target/find_honeycomb,
	)

/datum/ai_planning_subtree/basic_melee_attack_subtree/bear
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/bear

/datum/ai_planning_subtree/find_and_hunt_target/find_hive
	target_key = BB_FOUND_HONEY
	hunting_behavior = /datum/ai_behavior/hunt_target/find_hive
	finding_behavior = /datum/ai_behavior/find_hunt_target/find_hive
	hunt_targets = list(/obj/structure/beebox)
	hunt_range = 10

/datum/ai_planning_subtree/find_and_hunt_target/find_honeycomb
	target_key = BB_LOW_PRIORITY_HUNTING_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/find_honeycomb
	finding_behavior = /datum/ai_behavior/find_hunt_target/find_honeycomb
	hunt_targets = list(/obj/item/food/honeycomb)
	hunt_range = 10

/datum/ai_planning_subtree/climb_trees
	///chance to climb a tree
	var/climb_chance = 35

/datum/ai_planning_subtree/climb_trees/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)

	if(!SPT_PROB(climb_chance, seconds_per_tick))
		return

	var/obj/structure/flora/tree/target = controller.blackboard[BB_CLIMBED_TREE]

	if(QDELETED(target))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/valid_tree, BB_CLIMBED_TREE, /obj/structure/flora/tree)
		return

	controller.queue_behavior(/datum/ai_behavior/climb_tree, BB_CLIMBED_TREE)
	return SUBTREE_RETURN_FINISH_PLANNING
