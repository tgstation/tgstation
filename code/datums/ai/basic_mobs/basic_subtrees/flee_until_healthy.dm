/// The mob will try to move away from mobs which do not share factions until its health is above a certain threshold
/// If this mob can't heal itself somehow after a certain point it will probably do that forever
/datum/ai_planning_subtree/flee_until_healthy
	/// If a mob is at or below this percentage it will start avoiding mobs
	var/activate_below_percentage = 0.5
	/// If a mob reaches this percentage of health it will stop avoiding mobs
	var/disabled_at_percentage = 1
	/// If we're currently fleeing
	var/fleeing = FALSE

/datum/ai_planning_subtree/flee_until_healthy/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	check_fleeing(controller)
	if (!fleeing)
		return

	controller.queue_behavior(/datum/ai_behavior/find_nearest_unfriendly_mob, BB_BASIC_MOB_CURRENT_TARGET, BB_FLEE_TARGETTING_DATUM)

	var/datum/weakref/weak_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	var/atom/target = weak_target?.resolve()
	if (!target)
		return

	controller.queue_behavior(/datum/ai_behavior/flee_target_mob)
	return SUBTREE_RETURN_FINISH_PLANNING // We gotta get out of here

/// Check whether we should still be running away or not
/datum/ai_planning_subtree/flee_until_healthy/proc/check_fleeing(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/current_health_percentage = (living_pawn.maxHealth / living_pawn.health)
	if (fleeing)
		fleeing = current_health_percentage < disabled_at_percentage
		return
	fleeing = current_health_percentage <= activate_below_percentage
