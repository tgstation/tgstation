/datum/ai_behavior/basic_melee_attack/bear
	action_cooldown = 2 SECONDS

/datum/ai_behavior/find_hunt_target/find_hive

/datum/ai_behavior/find_hunt_target/find_hive/valid_dinner(mob/living/source, obj/structure/beebox/hive, radius)
	if(!length(hive.honeycombs))
		return FALSE
	return can_see(source, hive, radius)

/datum/ai_behavior/hunt_target/find_hive
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/find_hive/target_caught(mob/living/hunter, obj/structure/beebox/hive_target)
	var/datum/callback/callback = CALLBACK(hunter, TYPE_PROC_REF(/mob/living/basic/bear, extract_combs), hive_target)
	callback.Invoke()

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
	var/mob/living/basic/bear_pawn = controller.pawn
	bear_pawn.melee_attack(target_tree)
	finish_action(controller, TRUE, target_key)


/datum/ai_behavior/climb_tree/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if(succeeded)
		controller.clear_blackboard_key(target_key)

/datum/ai_behavior/find_hunt_target/find_honeycomb

/datum/ai_behavior/find_hunt_target/find_honeycomb/setup(datum/ai_controller/controller, ability_key, target_key)
	var/mob/living/living_pawn = controller.pawn
	if(living_pawn.pulling) //we already pulling a honey
		return FALSE
	return TRUE

/datum/ai_behavior/hunt_target/find_honeycomb
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/find_honeycomb/target_caught(mob/living/hunter, obj/item/food/honeycomb/food_target)
	hunter.start_pulling(food_target)
