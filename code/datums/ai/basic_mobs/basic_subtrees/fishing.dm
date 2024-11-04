#define FISHING_COOLDOWN 45 SECONDS

///subtree for fishing and eating food!
/datum/ai_planning_subtree/fish
	///behavior we use to find fishable objects
	var/datum/ai_behavior/find_fishable_behavior = /datum/ai_behavior/find_and_set/in_list
	///behavior we use to fish!
	var/datum/ai_behavior/fishing_behavior = /datum/ai_behavior/interact_with_target/fishing
	///blackboard key storing things we can fish from
	var/fishable_list_key = BB_FISHABLE_LIST
	///key where we store found fishable items
	var/fishing_target_key = BB_FISHING_TARGET
	///key where we store our fishing cooldown
	var/fishing_cooldown_key = BB_FISHING_COOLDOWN
	///our fishing range
	var/fishing_range = 5

/datum/ai_planning_subtree/fish/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard[BB_ONLY_FISH_WHILE_HUNGRY] && controller.blackboard[BB_NEXT_FOOD_EAT] > world.time)
		return
	if(controller.blackboard[BB_FISHING_TIMER] > world.time)
		return
	if(!controller.blackboard_key_exists(fishing_target_key))
		controller.queue_behavior(find_fishable_behavior, fishing_target_key, controller.blackboard[fishable_list_key], fishing_range)
		return
	controller.queue_behavior(/datum/ai_behavior/interact_with_target/fishing, fishing_target_key, fishing_cooldown_key)
	return SUBTREE_RETURN_FINISH_PLANNING

///less expensive fishing behavior!
/datum/ai_planning_subtree/fish/fish_from_turfs
	find_fishable_behavior = /datum/ai_behavior/find_and_set/in_list/closest_turf

/datum/ai_behavior/interact_with_target/fishing
	clear_target = FALSE
	combat_mode = FALSE

/datum/ai_behavior/interact_with_target/fishing/finish_action(datum/ai_controller/controller, succeeded, fishing_target_key, fishing_cooldown_key)
	. = ..()
	if(!succeeded)
		return
	var/cooldown = controller.blackboard[fishing_cooldown_key] || FISHING_COOLDOWN
	controller.set_blackboard_key(BB_FISHING_TIMER, world.time + cooldown)

#undef FISHING_COOLDOWN
