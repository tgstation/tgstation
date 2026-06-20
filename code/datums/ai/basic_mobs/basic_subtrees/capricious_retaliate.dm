///Random chance to add things to our retaliate list
/datum/bt_node/ai_behavior/capricious_retaliate
	var/targeting_strategy = BB_TARGETING_STRATEGY
	var/ignore_faction
	time_between_perform = 1 SECONDS

/datum/bt_node/ai_behavior/capricious_retaliate/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/pawn = controller.pawn

	if(controller.blackboard_key_exists(BB_BASIC_MOB_RETALIATE_LIST))
		var/deaggro_chance = controller.blackboard[BB_RANDOM_DEAGGRO_CHANCE] || 10
		if(prob(deaggro_chance)) //Chance to chill the fuck out. This prob() should be matched with the frequency of calling.
			pawn.visible_message(span_notice("[pawn] calms down."))
			controller.clear_blackboard_key(BB_BASIC_MOB_RETALIATE_LIST)
			controller.clear_blackboard_key(BB_CURRENT_TARGET)
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED // De-aggroed

	var/aggro_chance = controller.blackboard[BB_RANDOM_AGGRO_CHANCE] || 0.5
	if(!prob(aggro_chance)) //Check if we should get pissed at someone REEE
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/aggro_range = controller.blackboard[BB_AGGRO_RANGE] || 9
	var/list/potential_targets = hearers(aggro_range, get_turf(pawn)) - pawn
	if(!length(potential_targets))
		failed_targeting(pawn)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(!ispath(targeting_strategy))
		targeting_strategy = controller.blackboard[targeting_strategy]

	var/datum/targeting_strategy/target_helper = GET_TARGETING_STRATEGY(targeting_strategy)

	if(ignore_faction)
		controller.set_blackboard_key(BB_TEMPORARILY_IGNORE_FACTION, TRUE)

	var/mob/living/final_target = null
	while(isnull(final_target) && length(potential_targets))
		var/mob/living/test_target = pick_n_take(potential_targets)
		if(target_helper.is_valid_target(pawn, test_target, vision_range = aggro_range))
			final_target = test_target

	if(isnull(final_target))
		failed_targeting(pawn)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	// Add to shitlist — set_blackboard_key_assoc_lazylist calls post_blackboard_key_set, waking the combat branch
	controller.set_blackboard_key_assoc_lazylist(BB_BASIC_MOB_RETALIATE_LIST, final_target, world.time)
	pawn.visible_message(span_warning("[pawn] glares grumpily at [final_target]!"))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/capricious_retaliate/proc/failed_targeting(atom/pawn)
	pawn.visible_message(span_notice("[pawn] grumbles."))

/datum/bt_node/ai_behavior/capricious_retaliate/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	if(succeeded || !ignore_faction)
		return
	var/usually_ignores_faction = controller.blackboard[BB_ALWAYS_IGNORE_FACTION] || FALSE
	controller.set_blackboard_key(BB_TEMPORARILY_IGNORE_FACTION, usually_ignores_faction)
