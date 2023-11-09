/// Add or remove people to our retaliation shitlist just on an arbitrary whim
/datum/ai_planning_subtree/capricious_retaliate
	/// Blackboard key which tells us how to select valid targets
	var/targetting_datum_key = BB_TARGETTING_DATUM
	/// Whether we should skip checking faction for our decision
	var/ignore_faction = TRUE

/datum/ai_planning_subtree/capricious_retaliate/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	controller.queue_behavior(/datum/ai_behavior/capricious_retaliate, targetting_datum_key, ignore_faction)

/// Add or remove people to our retaliation shitlist just on an arbitrary whim
/datum/ai_behavior/capricious_retaliate
	action_cooldown = 1 SECONDS

/datum/ai_behavior/capricious_retaliate/perform(seconds_per_tick, datum/ai_controller/controller, targetting_datum_key, ignore_faction)
	var/atom/pawn = controller.pawn
	if (controller.blackboard_key_exists(BB_BASIC_MOB_RETALIATE_LIST))
		var/deaggro_chance = controller.blackboard[BB_RANDOM_DEAGGRO_CHANCE] || 10
		if (!SPT_PROB(deaggro_chance, seconds_per_tick))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
		pawn.visible_message(span_notice("[pawn] calms down.")) // We can blackboard key this if anyone else actually wants to customise it
		controller.clear_blackboard_key(BB_BASIC_MOB_RETALIATE_LIST)
		controller.CancelActions() // Otherwise they will try and get one last kick in
		return AI_BEHAVIOR_DELAY

	var/aggro_chance = controller.blackboard[BB_RANDOM_AGGRO_CHANCE] || 0.5
	if (!SPT_PROB(aggro_chance, seconds_per_tick))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/aggro_range = controller.blackboard[BB_AGGRO_RANGE] || 9
	var/list/potential_targets = hearers(aggro_range, get_turf(pawn)) - pawn
	if (!length(potential_targets))
		failed_targetting(controller, pawn, ignore_faction)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/datum/targetting_datum/target_helper = controller.blackboard[targetting_datum_key]

	var/mob/living/final_target = null
	if (ignore_faction)
		controller.set_blackboard_key(BB_TEMPORARILY_IGNORE_FACTION, TRUE)
	while (isnull(final_target) && length(potential_targets))
		var/mob/living/test_target = pick_n_take(potential_targets)
		if (target_helper.can_attack(pawn, test_target, vision_range = aggro_range))
			final_target = test_target

	if (isnull(final_target))
		failed_targetting(controller, pawn, ignore_faction)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, final_target)
	pawn.visible_message(span_warning("[pawn] glares grumpily at [final_target]!"))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Called if we try but fail to target something
/datum/ai_behavior/capricious_retaliate/proc/failed_targetting(datum/ai_controller/controller, atom/pawn, ignore_faction)
	pawn.visible_message(span_notice("[pawn] grumbles.")) // We're pissed off but with no outlet to vent our frustration upon

/datum/ai_behavior/capricious_retaliate/finish_action(datum/ai_controller/controller, succeeded, ignore_faction)
	. = ..()
	if (succeeded || !ignore_faction)
		return
	var/usually_ignores_faction = controller.blackboard[BB_ALWAYS_IGNORE_FACTION] || FALSE
	controller.set_blackboard_key(BB_TEMPORARILY_IGNORE_FACTION, usually_ignores_faction)
