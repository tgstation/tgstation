/// Goats are normally content to sorta hang around and crunch any plant in sight, but they will go ape on someone who attacks them.
/datum/ai_controller/basic_controller/goat
	behavior_tree_json = "goat.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_BASIC_MOB_SPEAK_LINES = list(
			BB_EMOTE_SAY = list("EHEHEHEHEH", "eh?"),
			BB_EMOTE_HEAR = list("brays."),
			BB_EMOTE_SEE = list("shakes their head.", "stamps a foot.", "glares around."),
			BB_SPEAK_CHANCE = 3,
		),
	)

	ai_traits = DEFAULT_AI_FLAGS | STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
