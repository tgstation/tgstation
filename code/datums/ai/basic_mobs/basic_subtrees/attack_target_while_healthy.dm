/// Performs attacks until you drop under a certain health ratio
/datum/ai_planning_subtree/basic_melee_attack_subtree/while_healthy

/datum/ai_planning_subtree/basic_melee_attack_subtree/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/datum/weakref/weak_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	var/atom/target = weak_target?.resolve()

	if(!target || QDELETED(target))
		return
	controller.queue_behavior(melee_attack_behavior, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION, BB_BASIC_MOB_FLEE_BELOW_HP_RATIO)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/basic_melee_attack/while_healthy

/datum/ai_behavior/basic_melee_attack/while_healthy/setup(datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key, health_ratio_key)
	if (!controller.blackboard[health_ratio_key])
		return FALSE
	return ..()

/datum/ai_behavior/basic_melee_attack/while_healthy/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key, health_ratio_key)
	var/mob/living/living_pawn = controller.pawn
	var/current_health_ratio = (living_pawn.health / living_pawn.maxHealth)
	if (current_health_ratio < controller.blackboard[health_ratio_key])
		finish_action(controller, FALSE)
		return
	return ..()

/// Performs attacks until you drop under a certain health ratio
/datum/ai_planning_subtree/basic_ranged_attack_subtree/while_healthy

/datum/ai_planning_subtree/basic_ranged_attack_subtree/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/datum/weakref/weak_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	var/atom/target = weak_target?.resolve()
	if(!target || QDELETED(target))
		return
	controller.queue_behavior(ranged_attack_behavior, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION, BB_BASIC_MOB_FLEE_BELOW_HP_RATIO)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/basic_ranged_attack/while_healthy

/datum/ai_behavior/basic_ranged_attack/while_healthy/setup(datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key, health_ratio_key)
	if (!controller.blackboard[health_ratio_key])
		return FALSE
	return ..()

/datum/ai_behavior/basic_ranged_attack/while_healthy/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key, health_ratio_key)
	var/mob/living/living_pawn = controller.pawn
	var/current_health_ratio = (living_pawn.health / living_pawn.maxHealth)
	if (current_health_ratio > controller.blackboard[health_ratio_key])
		finish_action(controller, FALSE)
		return
	return ..()
