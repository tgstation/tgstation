/datum/ai_behavior/find_and_set/valid_tree

/datum/ai_behavior/find_and_set/valid_tree/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/list/valid_trees = list()
	for (var/obj/structure/flora/tree/tree_target in oview(search_range, controller.pawn))
		if(istype(tree_target, /obj/structure/flora/tree/dead)) //no died trees
			continue
		valid_trees += tree_target

	if(valid_trees.len)
		return pick(valid_trees)

/datum/ai_behavior/climb_tree
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/climb_tree/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE

	set_movement_target(controller, target)

/datum/ai_behavior/climb_tree/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/obj/structure/flora/target_tree = controller.blackboard[target_key]
	var/mob/living/basic/living_pawn = controller.pawn
	SEND_SIGNAL(living_pawn, COMSIG_LIVING_CLIMB_TREE, target_tree)
	finish_action(controller, TRUE, target_key)

/datum/ai_behavior/climb_tree/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if(succeeded)
		controller.clear_blackboard_key(target_key)
