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
	behavior_tree_json = "code/modules/mob/living/basic/icemoon/wolf/wolf.bt.json"


