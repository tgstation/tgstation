/datum/ai_controller/basic_controller/tendril
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_AGGRO_RANGE = 9, // Keeps an eye on you even if you flee
		BB_AGGRO_GRAB_RANGE = 5, // Only aggros if you get real close and personal
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/call_reinforcements/mining,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/tendril_chaser,
		/datum/ai_planning_subtree/use_mob_ability/tendril_spikes,
		/datum/ai_planning_subtree/use_mob_ability/tendril_lash,
	)

/datum/ai_planning_subtree/targeted_mob_ability/tendril_chaser
	ability_key = BB_TENDRIL_CHASER
	operational_datums = list(/datum/component/ai_target_timer)
	finish_planning = FALSE

/datum/ai_planning_subtree/use_mob_ability/tendril_lash
	ability_key = BB_TENDRIL_LASH

/datum/ai_planning_subtree/use_mob_ability/tendril_lash/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if (isnull(target) || get_dist(controller.pawn, target) > /obj/projectile/tentacle_lash::range)
		return FALSE
	return ..()

/datum/ai_planning_subtree/use_mob_ability/tendril_spikes
	ability_key = BB_TENDRIL_SPIKES

/datum/ai_planning_subtree/use_mob_ability/tendril_spikes/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	var/datum/action/cooldown/mob_cooldown/tendril_cross_spikes/ability = controller.blackboard[ability_key]
	if (isnull(target) || !istype(ability) || get_dist(controller.pawn, target) > ability.spike_range)
		return FALSE
	return ..()
