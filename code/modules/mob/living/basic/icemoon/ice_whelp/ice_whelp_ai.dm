#define ENRAGE_ADDITION 25
/datum/ai_controller/basic_controller/ice_whelp
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/allow_items,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
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
		/datum/ai_planning_subtree/find_and_hunt_target/corpses/ice_whelp,
		/datum/ai_planning_subtree/burn_trees,
	)

/datum/ai_planning_subtree/find_and_hunt_target/corpses/ice_whelp
	target_key = BB_TARGET_CANNIBAL
	finding_behavior = /datum/ai_behavior/find_hunt_target/corpses/dragon_corpse
	hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target/dragon_cannibalise
	hunt_targets = list(/mob/living/basic/mining/ice_whelp)
	hunt_range = 10

/datum/ai_behavior/find_hunt_target/corpses/dragon_corpse

/datum/ai_behavior/find_hunt_target/corpses/dragon_corpse/valid_dinner(mob/living/source, mob/living/dinner, radius)
	if(dinner.pulledby) //someone already got him before us
		return FALSE
	return ..()

/datum/ai_behavior/hunt_target/unarmed_attack_target/dragon_cannibalise
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/hunt_target/unarmed_attack_target/dragon_cannibalise/perform(seconds_per_tick, datum/ai_controller/controller, target_key, attack_key)
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(target) || target.stat != DEAD || target.pulledby) //we were too slow
		finish_action(controller, FALSE)
		return
	return ..()

/datum/ai_behavior/cannibalize/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

///subtree to find icy rocks and create sculptures out of them
/datum/ai_planning_subtree/sculpt_statues

/datum/ai_planning_subtree/sculpt_statues/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(BB_TARGET_ROCK))
		controller.queue_behavior(/datum/ai_behavior/sculpt_statue, BB_TARGET_ROCK)
		return SUBTREE_RETURN_FINISH_PLANNING
	controller.queue_behavior(/datum/ai_behavior/find_and_set, BB_TARGET_ROCK, /obj/structure/flora/rock/icy)

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
	var/mob/living/basic/living_pawn = controller.pawn

	if(QDELETED(target))
		finish_action(controller, FALSE, target_key)
		return

	living_pawn.melee_attack(target)
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

/datum/ai_behavior/targeted_mob_ability/ice_whelp/get_ability_to_use(datum/ai_controller/controller, ability_key)
	var/enraged_value = controller.blackboard[enraged_key]

	if(prob(enraged_value))
		controller.set_blackboard_key(enraged_key, 0)
		return controller.blackboard[secondary_ability_key]

	controller.set_blackboard_key(enraged_key, enraged_value + ENRAGE_ADDITION)
	return controller.blackboard[ability_key]

///subtree to look for trees and burn them with our flamethrower
/datum/ai_planning_subtree/burn_trees

/datum/ai_planning_subtree/burn_trees/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/datum/action/cooldown/using_action = controller.blackboard[BB_WHELP_STRAIGHTLINE_FIRE]
	if (!using_action?.IsAvailable())
		return

	if(controller.blackboard_key_exists(BB_TARGET_TREE))
		controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability/and_clear_target/burn_trees, BB_WHELP_STRAIGHTLINE_FIRE, BB_TARGET_TREE)
		return SUBTREE_RETURN_FINISH_PLANNING
	controller.queue_behavior(/datum/ai_behavior/set_target_tree, BB_TARGET_TREE)

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

#undef ENRAGE_ADDITION
