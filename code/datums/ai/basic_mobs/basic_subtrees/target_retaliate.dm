/// Sets the BB target to a mob which you can see and who has recently attacked you
/datum/ai_planning_subtree/target_retaliate
	operational_datums = list(/datum/element/ai_retaliate, /datum/component/ai_retaliate_advanced)
	/// Blackboard key which tells us how to select valid targets
	var/targeting_strategy_key = BB_TARGETING_STRATEGY
	/// Blackboard key in which to store selected target
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET
	/// Blackboard key in which to store selected target's hiding place
	var/hiding_place_key = BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION
	/// do we check for faction?
	var/check_faction = FALSE

/datum/ai_planning_subtree/target_retaliate/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	controller.queue_behavior(/datum/ai_behavior/target_from_retaliate_list, BB_BASIC_MOB_RETALIATE_LIST, target_key, targeting_strategy_key, hiding_place_key, check_faction)

/datum/ai_planning_subtree/target_retaliate/check_faction
	check_faction = TRUE

/// Places a mob which you can see and who has recently attacked you into some 'run away from this' AI keys
/// Can use a different targeting strategy than you use to select attack targets
/// Not required if fleeing is the only target behaviour or uses the same target datum
/datum/ai_planning_subtree/target_retaliate/to_flee
	targeting_strategy_key = BB_FLEE_TARGETING_STRATEGY
	target_key = BB_BASIC_MOB_FLEE_TARGET
	hiding_place_key = BB_BASIC_MOB_FLEE_TARGET_HIDING_LOCATION

/**
 * Picks a target from a provided list of atoms who have been pissing you off
 * You will probably need /datum/element/ai_retaliate to take advantage of this unless you're populating the blackboard yourself
 */
/datum/ai_behavior/target_from_retaliate_list
	action_cooldown = 2 SECONDS
	/// How far can we see stuff?
	var/vision_range = 9

/datum/ai_behavior/target_from_retaliate_list/perform(seconds_per_tick, datum/ai_controller/controller, shitlist_key, target_key, targeting_strategy_key, hiding_location_key, check_faction)
	var/mob/living/living_mob = controller.pawn
	var/datum/targeting_strategy/targeting_strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])
	if(!targeting_strategy)
		. = AI_BEHAVIOR_DELAY
		CRASH("No target datum was supplied in the blackboard for [controller.pawn]")

	var/list/shitlist = controller.blackboard[shitlist_key]
	var/atom/existing_target = controller.blackboard[target_key]

	if (!check_faction)
		controller.set_blackboard_key(BB_TEMPORARILY_IGNORE_FACTION, TRUE)

	if (!QDELETED(existing_target) && (locate(existing_target) in shitlist) && targeting_strategy.can_attack(living_mob, existing_target, vision_range))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	var/list/enemies_list = list()
	for(var/mob/living/potential_target as anything in shitlist)
		if(!targeting_strategy.can_attack(living_mob, potential_target, vision_range))
			continue
		enemies_list += potential_target

	if(!length(enemies_list))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/atom/new_target = pick_final_target(controller, enemies_list)
	controller.set_blackboard_key(target_key, new_target)

	var/atom/potential_hiding_location = targeting_strategy.find_hidden_mobs(living_mob, new_target)

	if(potential_hiding_location) //If they're hiding inside of something, we need to know so we can go for that instead initially.
		controller.set_blackboard_key(hiding_location_key, potential_hiding_location)

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Returns the desired final target from the filtered list of enemies
/datum/ai_behavior/target_from_retaliate_list/proc/pick_final_target(datum/ai_controller/controller, list/enemies_list)
	return pick(enemies_list)

/datum/ai_behavior/target_from_retaliate_list/finish_action(datum/ai_controller/controller, succeeded, shitlist_key, target_key, targeting_strategy_key, hiding_location_key, check_faction)
	. = ..()
	if (succeeded || check_faction)
		return
	var/usually_ignores_faction = controller.blackboard[BB_ALWAYS_IGNORE_FACTION] || FALSE
	controller.set_blackboard_key(BB_TEMPORARILY_IGNORE_FACTION, usually_ignores_faction)
