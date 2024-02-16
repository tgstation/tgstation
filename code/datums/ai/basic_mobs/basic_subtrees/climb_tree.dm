/datum/ai_planning_subtree/climb_trees
	operational_datums = list(/datum/component/tree_climber)
	///chance to climb a tree
	var/climb_chance = 35

/datum/ai_planning_subtree/climb_trees/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)

	if(!SPT_PROB(climb_chance, seconds_per_tick))
		return

	if(controller.blackboard_key_exists(BB_CLIMBED_TREE))
		controller.queue_behavior(/datum/ai_behavior/climb_tree, BB_CLIMBED_TREE)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.queue_behavior(/datum/ai_behavior/find_and_set/valid_tree, BB_CLIMBED_TREE, /obj/structure/flora/tree)
