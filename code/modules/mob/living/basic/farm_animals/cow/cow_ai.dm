/datum/ai_controller/basic_controller/cow
	behavior_tree_json = "cow.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_BASIC_MOB_TIP_REACTING = FALSE,
		BB_BASIC_MOB_TIPPER = null,
		BB_BASIC_MOB_SPEAK_LINES = list(
			BB_EMOTE_SAY = list("moo?", "moo", "MOOOOOO"),
			BB_EMOTE_HEAR = list("brays."),
			BB_EMOTE_SEE = list("shakes her head."),
			BB_EMOTE_SOUND = list('sound/mobs/non-humanoids/cow/cow.ogg'),
			BB_SPEAK_CHANCE = 1,
		),
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
