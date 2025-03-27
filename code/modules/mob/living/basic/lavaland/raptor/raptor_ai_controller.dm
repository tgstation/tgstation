/datum/ai_controller/basic_controller/raptor
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
		BB_BABIES_CHILD_TYPES = list(/mob/living/basic/raptor/baby_raptor),
		BB_MAX_CHILDREN = 5,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee/raptor,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
		/datum/ai_planning_subtree/find_and_hunt_target/heal_raptors,
		/datum/ai_planning_subtree/random_speech/blackboard,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/raptor_trough,
		/datum/ai_planning_subtree/find_and_hunt_target/care_for_young,
		/datum/ai_planning_subtree/make_babies,
		/datum/ai_planning_subtree/express_happiness,
		/datum/ai_planning_subtree/find_and_hunt_target/play_with_owner/raptor,
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

/datum/ai_controller/basic_controller/raptor/on_mob_eat()
	. = ..()
	clear_blackboard_key(BB_RAPTOR_TROUGH_TARGET)

/datum/ai_controller/basic_controller/baby_raptor
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_FIND_MOM_TYPES = list(/mob/living/basic/raptor),
		BB_IGNORE_MOM_TYPES = list(/mob/living/basic/raptor/baby_raptor),
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/blackboard,
		/datum/ai_planning_subtree/find_and_hunt_target/raptor_trough,
		/datum/ai_planning_subtree/express_happiness,
		/datum/ai_planning_subtree/look_for_adult,
	)
