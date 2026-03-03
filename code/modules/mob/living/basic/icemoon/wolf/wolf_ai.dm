//This mimicks the old simple_animal wolf behavior fairly closely.
//The 30 tiles fleeing is pretty wild and may need toning back under basicmob behavior, we'll have to see.
/datum/ai_controller/basic_controller/wolf
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/allow_items,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_BASIC_MOB_FLEE_DISTANCE = 30,
		BB_VISION_RANGE = 9,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_REINFORCEMENTS_EMOTE = "unleashes a chilling howl, calling for aid!",
		BB_OWNER_SELF_HARM_RESPONSES = list(
			"*me howls in dissaproval.",
			"*me whines sadly.",
			"*me attempts to take your hand in its mouth."
		)
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	//reinforcements needs to be skipped over entirely on tamed wolves because it causes them to attack their owner and then themselves
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/call_reinforcements/wolf,
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/call_reinforcements/wolf

/datum/ai_planning_subtree/call_reinforcements/wolf/decide_to_call(datum/ai_controller/controller)
	//only call reinforcements if the person who just smacked us isn't a friend to avoid hitting them once, then killing ourselves if we've been tamed
	if (controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET) && istype(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], /mob))
		return !(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] in controller.blackboard[BB_FRIENDS_LIST])
	else
		return FALSE

