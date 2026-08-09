
/// AI controller for normal roach
/datum/ai_controller/basic_controller/cockroach
	behavior_tree_json = "code/modules/mob/living/basic/vermin/cockroach/cockroach.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_OWNER_SELF_HARM_RESPONSES = list(
			"*me waves its antennae in disapproval.",
			"*me chitters sadly."
		),
		BB_BASIC_MOB_SPEAK_LINES = list(
			BB_EMOTE_HEAR = list("chitters."),
			BB_EMOTE_SOUND = list('sound/mobs/non-humanoids/insect/chitter.ogg'),
			BB_SPEAK_CHANCE = 5,
		),
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance

/// AI controller for aggressive roach
/datum/ai_controller/basic_controller/cockroach/aggro
	behavior_tree_json = "code/modules/mob/living/basic/vermin/cockroach/cockroach_aggro.bt.json"

/// AI controller for roach who can shoot at you
/datum/ai_controller/basic_controller/cockroach/glockroach
	behavior_tree_json = "code/modules/mob/living/basic/vermin/cockroach/cockroach_glockroach.bt.json"

/// roach who shoots at you slightly slower
/datum/ai_controller/basic_controller/cockroach/mobroach
	behavior_tree_json = "code/modules/mob/living/basic/vermin/cockroach/cockroach_mobroach.bt.json"

/datum/bt_node/ai_behavior/basic_ranged_attack/glockroach //Slightly slower, as this is being made in feature freeze ;)
	time_between_perform = 1 SECONDS

/datum/bt_node/ai_behavior/basic_ranged_attack/mobroach
	time_between_perform = 2 SECONDS
