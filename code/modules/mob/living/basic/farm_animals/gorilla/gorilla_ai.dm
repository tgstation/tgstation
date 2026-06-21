/// Pretty basic, just click people to death. Also hunt and eat bananas.
/datum/ai_controller/basic_controller/gorilla
	behavior_tree_json = "code/modules/mob/living/basic/farm_animals/gorilla/gorilla.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
		BB_EMOTE_KEY = "ooga",
		BB_EMOTE_CHANCE = 40,
	)

	ai_traits = DEFAULT_AI_FLAGS | STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance

/datum/ai_controller/basic_controller/gorilla/lesser
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/allow_items,
		BB_EMOTE_KEY = "ooga",
		BB_EMOTE_CHANCE = 60,
	)
