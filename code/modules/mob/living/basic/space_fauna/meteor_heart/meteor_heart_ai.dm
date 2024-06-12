/// A spellcasting AI which does not move
/datum/ai_controller/basic_controller/meteor_heart
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGETLESS_TIME = 0,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/ground_spikes,
		/datum/ai_planning_subtree/use_mob_ability/spine_traps,
		/datum/ai_planning_subtree/sleep_with_no_target/meteor_heart,
	)

/datum/ai_planning_subtree/targeted_mob_ability/ground_spikes
	ability_key = BB_METEOR_HEART_GROUND_SPIKES
	finish_planning = FALSE

/datum/ai_planning_subtree/use_mob_ability/spine_traps
	ability_key = BB_METEOR_HEART_SPINE_TRAPS

/// After enough time with no target, deaggro and change animation state
/datum/ai_planning_subtree/sleep_with_no_target/meteor_heart
	sleep_behaviour = /datum/ai_behavior/sleep_after_targetless_time/meteor_heart

/datum/ai_behavior/sleep_after_targetless_time/meteor_heart

/datum/ai_behavior/sleep_after_targetless_time/meteor_heart/enter_sleep(datum/ai_controller/controller)
	var/mob/living/basic/meteor_heart/heart = controller.pawn
	if (!istype(heart))
		return ..()
	heart.deaggro()
