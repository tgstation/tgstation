#define LIGHT_COOLDOWN_DURATION (2 SECONDS)

/// Vibebots just do what normal bots do except they flash their lights every so often.
/datum/ai_controller/basic_controller/bot/vibebot
	blackboard = list(
		BB_SALUTE_MESSAGES = list(
			"blinks at",
			"nods in appreciation towards",
			"pauses for a moment to look at",
		),
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_VIBEBOT_LIGHT_CHANGE_PROBABILITY = 25,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/respond_to_summon,
		/datum/ai_planning_subtree/salute_beepsky,
		/datum/ai_planning_subtree/pizzazz,
		/datum/ai_planning_subtree/find_patrol_beacon,
		/datum/ai_planning_subtree/manage_unreachable_list,
	)

/datum/ai_planning_subtree/pizzazz

/datum/ai_planning_subtree/pizzazz/SelectBehaviors(datum/ai_controller/basic_controller/bot/vibebot/controller, seconds_per_tick)
	controller.queue_behavior(/datum/ai_behavior/flash_lights)

/datum/ai_behavior/flash_lights
	action_cooldown = 2 SECONDS

/datum/ai_behavior/flash_lights/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller)
	if(SPT_PROB(controller.blackboard[BB_VIBEBOT_LIGHT_CHANGE_PROBABILITY], seconds_per_tick))
		SEND_SIGNAL(controller.pawn, COMSIG_CHANGE_VIBEBOT_COLOR)

	finish_action(controller, TRUE) // any attempt is a success

#undef LIGHT_COOLDOWN_DURATION
