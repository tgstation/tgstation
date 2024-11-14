
/datum/ai_controller/basic_controller/cat/kitten
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_HUNGRY_MEOW = list("mrrp...", "mraw..."),
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_MAX_DISTANCE_TO_FOOD = 2,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/beg_human,
		/datum/ai_planning_subtree/find_and_hunt_target/find_cat_food/kitten,
		/datum/ai_planning_subtree/random_speech/cats,
	)

//if the food is too far away, point at it or meow. if its near us then go eat it

/datum/ai_planning_subtree/find_and_hunt_target/find_cat_food/kitten


/datum/ai_planning_subtree/find_and_hunt_target/find_cat_food/kitten/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/target = controller.blackboard[BB_CAT_FOOD_TARGET]
	if(target && get_dist(target, controller.pawn) > controller.blackboard[BB_MAX_DISTANCE_TO_FOOD])
		controller.queue_behavior(/datum/ai_behavior/beacon_for_food, BB_CAT_FOOD_TARGET, BB_HUNGRY_MEOW)
		return
	return ..()

/datum/ai_behavior/beacon_for_food
	action_cooldown = 5 SECONDS

/datum/ai_behavior/beacon_for_food/perform(seconds_per_tick, datum/ai_controller/controller, target_key, meows_key)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/living_pawn = controller.pawn
	var/list/meowing_list = controller.blackboard[meows_key]
	if(length(meowing_list))
		living_pawn.say(pick(meowing_list), forced = "ai_controller")
	living_pawn._pointed(target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/beacon_for_food/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/datum/ai_planning_subtree/beg_human

/datum/ai_planning_subtree/beg_human/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)

	if(controller.blackboard_key_exists(BB_HUMAN_BEG_TARGET))
		controller.queue_behavior(/datum/ai_behavior/beacon_for_food, BB_HUMAN_BEG_TARGET, BB_HUNGRY_MEOW)
		return

	controller.queue_behavior(/datum/ai_behavior/find_and_set/human_beg, BB_HUMAN_BEG_TARGET, /mob/living/carbon/human)

/datum/ai_behavior/find_and_set/human_beg/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/list/locate_items = controller.blackboard[BB_HUNTABLE_PREY]
	for(var/mob/living/carbon/human/human_target in oview(search_range, controller.pawn))
		if(human_target.stat != CONSCIOUS || isnull(human_target.mind))
			continue
		if(!length(typecache_filter_list(human_target.held_items, locate_items)))
			continue
		return human_target

	return null
