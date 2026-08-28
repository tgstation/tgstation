/datum/ai_controller/basic_controller/raptor
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/raptor/raptor_ai.bt.json"
	blackboard = list(
		BB_INTERACTIONS_WITH_OWNER = list(
			"pecks",
			"nuzzles",
			"wags their tail against",
			"playfully leans against"
		),
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_BABIES_PARTNER_TYPES = list(/mob/living/basic/raptor),
		BB_MAX_CHILDREN = 5,
		BB_RAPTOR_FLEE_THRESHOLD = 0.25,
		BB_FUCKS = TRUE
	)
	ai_movement = /datum/ai_movement/basic_avoidance

/// Angry raptors with no faction check on retaliation
/datum/ai_controller/basic_controller/raptor/aggressive
	ai_movement = /datum/ai_movement/basic_avoidance
	blackboard = list(
		BB_INTERACTIONS_WITH_OWNER = list(
			"pecks",
			"nuzzles",
			"wags their tail against",
			"playfully leans against"
		),
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/exact_match/ignore_friends,
		BB_HUNT_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_BABIES_PARTNER_TYPES = list(/mob/living/basic/raptor),
		BB_MAX_CHILDREN = 5,
		BB_RAPTOR_FLEE_THRESHOLD = 0.1,
		BB_FUCKS = TRUE
	)

/datum/ai_controller/basic_controller/raptor/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	RegisterSignal(new_pawn, COMSIG_AI_BLACKBOARD_KEY_SET(BB_RAPTOR_COWARD), PROC_REF(on_cowardly_set))
	RegisterSignal(new_pawn, COMSIG_AI_BLACKBOARD_KEY_CLEARED(BB_RAPTOR_COWARD), PROC_REF(on_cowardly_clear))

/datum/ai_controller/basic_controller/raptor/proc/on_cowardly_set(datum/source)
	SIGNAL_HANDLER
	ADD_TRAIT(pawn, TRAIT_MOB_DIFFICULT_TO_MOUNT, REF(src))

/datum/ai_controller/basic_controller/raptor/proc/on_cowardly_clear(datum/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(pawn, TRAIT_MOB_DIFFICULT_TO_MOUNT, REF(src))

/datum/ai_controller/basic_controller/baby_raptor
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/raptor/baby_raptor.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_FIND_MOM_TYPES = list(/mob/living/basic/raptor),
		BB_IGNORE_MOM_TYPES = list(/mob/living/basic/raptor/baby)
	)
	ai_movement = /datum/ai_movement/basic_avoidance
