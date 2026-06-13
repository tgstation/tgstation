/// Geese like to eat random objects and kill themselves, and occasionally get pissed off for no reason
/datum/ai_controller/basic_controller/goose
	behavior_tree_json = "goose.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_SEARCH_RANGE = 1,
		BB_EAT_FOOD_COOLDOWN = 10 SECONDS,
		BB_EAT_EMOTES = list(),
		BB_BASIC_MOB_SPEAK_LINES = list(
			BB_EMOTE_SAY = list("Honk!"),
			BB_EMOTE_HEAR = list("honks.", "honks loudly.", "honks aggressively."),
			BB_EMOTE_SEE = list("flaps.", "preens.", "glares around."),
			BB_SPEAK_CHANCE = 3,
		),
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance

/// Goose who doesn't randomly retaliate but does still try to die by eating random items
/datum/ai_controller/basic_controller/goose/calm
	behavior_tree_json = "goose_calm.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_SEARCH_RANGE = 1,
		BB_EAT_FOOD_COOLDOWN = 0.5 SECONDS, // Uh oh
		BB_EAT_EMOTES = list(),
		BB_BASIC_MOB_SPEAK_LINES = list(
			BB_EMOTE_SAY = list("Honk!"),
			BB_EMOTE_HEAR = list("honks.", "honks loudly.", "honks aggressively."),
			BB_EMOTE_SEE = list("flaps.", "preens.", "glares around."),
			BB_SPEAK_CHANCE = 3,
		),
	)

/// Geese are picky: they only forage for edible items and plastic, and only when it's right next to them.
/datum/bt_node/subtree/forage_for_goose_food
	behavior_tree_json = "forage_for_goose_food.bt.json"
