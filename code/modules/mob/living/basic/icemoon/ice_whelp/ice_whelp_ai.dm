/datum/ai_controller/basic_controller/ice_whelp
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/allow_items/goliath,
		BB_WHELP_ENRAGED = 0,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/ice_whelp,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/sculpt_statues,
		/datum/ai_planning_subtree/cannibalize,
		/datum/ai_planning_subtree/burn_trees,
	)

///subtree to find corpses of our kind and consume them
/datum/ai_planning_subtree/cannibalize

/datum/ai_planning_subtree/cannibalize/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/target = controller.blackboard[BB_TARGET_CANNIBAL]

	if(QDELETED(target))
		controller.queue_behavior(/datum/ai_behavior/find_cannibal_food, BB_TARGET_CANNIBAL)
		return

	controller.queue_behavior(/datum/ai_behavior/cannibalize, BB_TARGET_CANNIBAL)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/find_cannibal_food/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()

	var/mob/living_pawn = controller.pawn

	var/mob/to_be_consumed

	for(var/mob/potential_food in oview(9, living_pawn))
		if(!istype(potential_food, living_pawn.type))
			continue
		if(potential_food.stat != DEAD)
			continue
		if(potential_food.pulledby) //someone already got him before us
			continue
		to_be_consumed = potential_food
		break

	if(!to_be_consumed)
		finish_action(controller, FALSE)
		return

	controller.set_blackboard_key(target_key, to_be_consumed)
	finish_action(controller, TRUE)

/datum/ai_behavior/cannibalize
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	///the hp we'll regain after cannibalizing
	var/health_boost = 5

/datum/ai_behavior/cannibalize/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/cannibalize/perform(seconds_per_tick, datum/ai_controller/controller, target_key, attack_key)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	var/mob/living/target = controller.blackboard[target_key]

	if(QDELETED(target))
		finish_action(controller, FALSE)
		return

	if(target.stat != DEAD || target.pulledby) //we were too slow
		finish_action(controller, FALSE)
		return

	living_pawn.start_pulling(target)
	if(!do_after(living_pawn, 5 SECONDS, target))
		finish_action(controller, FALSE)
		return

	target.gib()
	living_pawn.adjustBruteLoss(-1 * health_boost)
	finish_action(controller, TRUE)

/datum/ai_behavior/cannibalize/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

///subtree to find icy rocks and create sculptures out of them
/datum/ai_planning_subtree/sculpt_statues

/datum/ai_planning_subtree/sculpt_statues/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/obj/target = controller.blackboard[BB_TARGET_ROCK]

	if(QDELETED(target))
		controller.queue_behavior(/datum/ai_behavior/find_and_set, BB_TARGET_ROCK, /obj/structure/flora/rock/icy)
		return

	controller.queue_behavior(/datum/ai_behavior/sculpt_statue, BB_TARGET_ROCK)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/sculpt_statue
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	action_cooldown = 5 MINUTES

/datum/ai_behavior/sculpt_statue/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/obj/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/sculpt_statue/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()

	var/atom/target = controller.blackboard[target_key]
	var/mob/living/basic/mining/ice_whelp/living_pawn = controller.pawn

	if(QDELETED(target))
		finish_action(controller, FALSE, target_key)
		return

	living_pawn.create_sculpture(target)
	finish_action(controller, TRUE, target_key)

/datum/ai_behavior/sculpt_statue/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)


//subtree to use our attacks on the victim
/datum/ai_planning_subtree/targeted_mob_ability/ice_whelp
	ability_key = BB_WHELP_STRAIGHTLINE_FIRE
	use_ability_behaviour = /datum/ai_behavior/targeted_mob_ability/ice_whelp
	finish_planning = FALSE


/datum/ai_behavior/targeted_mob_ability/ice_whelp
	///key that stores how enraged we are
	var/enraged_key = BB_WHELP_ENRAGED
	///key that stores the ability we will use instead if we are fully enraged
	var/secondary_ability_key = BB_WHELP_WIDESPREAD_FIRE

/datum/ai_behavior/targeted_mob_ability/ice_whelp/perform(seconds_per_tick, datum/ai_controller/controller, ability_key, target_key)
	var/datum/action/cooldown/ability
	var/enraged_value = controller.blackboard[enraged_key]

	if(prob(enraged_value))
		ability = controller.blackboard[secondary_ability_key]
		controller.set_blackboard_key(enraged_key, 0)
	else
		ability = controller.blackboard[ability_key]
		controller.set_blackboard_key(enraged_key, enraged_value + 25)

	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(ability) || QDELETED(target))
		finish_action(controller, FALSE, ability_key, target_key)
		return

	var/mob/pawn = controller.pawn
	var/result = ability.InterceptClickOn(pawn, null, target)
	finish_action(controller, result, ability_key, target_key)

///subtree to look for trees and burn them with our flamethrower
/datum/ai_planning_subtree/burn_trees

/datum/ai_planning_subtree/burn_trees/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/datum/action/cooldown/using_action = controller.blackboard[BB_WHELP_STRAIGHTLINE_FIRE]
	if (!using_action.IsAvailable())
		return

	var/obj/structure/target = controller.blackboard[BB_TARGET_TREE]
	if(QDELETED(target))
		controller.queue_behavior(/datum/ai_behavior/set_target_tree, BB_TARGET_TREE)
		return

	controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability/and_clear_target/burn_trees, BB_WHELP_STRAIGHTLINE_FIRE, BB_TARGET_TREE)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/set_target_tree

/datum/ai_behavior/set_target_tree/perform(seconds_per_tick, datum/ai_controller/controller, tree_key)
	. = ..()

	var/mob/living_pawn = controller.pawn
	var/list/possible_trees = list()

	for(var/obj/structure/flora/tree/possible_tree in oview(9, living_pawn))
		if(istype(possible_tree, /obj/structure/flora/tree/stump)) //no leaves to burn
			continue
		possible_trees += possible_tree

	if(!length(possible_trees))
		finish_action(controller, FALSE)
		return

	controller.set_blackboard_key(tree_key, pick(possible_trees))
	finish_action(controller, TRUE)

/datum/ai_behavior/targeted_mob_ability/and_clear_target/burn_trees
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	required_distance = 2
	action_cooldown = 2 MINUTES

/datum/ai_behavior/targeted_mob_ability/and_clear_target/burn_trees/setup(datum/ai_controller/controller, ability_key, target_key)
	. = ..()
	var/obj/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)
