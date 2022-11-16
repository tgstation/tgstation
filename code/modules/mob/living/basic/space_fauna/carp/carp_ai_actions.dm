/// Melee attack until you get too hurt
/datum/ai_planning_subtree/basic_melee_attack_subtree/while_healthy/carp
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/while_healthy/carp

/datum/ai_behavior/basic_melee_attack/while_healthy/carp
	action_cooldown = 1.5 SECONDS

/datum/ai_planning_subtree/targetted_mob_ability/magicarp
	ability_key = BB_MAGICARP_SPELL

/// As basic attack tree but interrupt if your health gets low or if your spell is off cooldown
/datum/ai_planning_subtree/basic_melee_attack_subtree/while_healthy/magicarp
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/while_healthy/carp/magic

// This got too nested for me to think of how to make it generic in a way which wasn't stupid
/datum/ai_behavior/basic_melee_attack/while_healthy/carp/magic

/datum/ai_behavior/basic_melee_attack/while_healthy/carp/magic/setup(datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key, health_ratio_key)
	if (!controller.blackboard[BB_MAGICARP_SPELL])
		return FALSE
	return ..()

/datum/ai_behavior/basic_melee_attack/while_healthy/carp/magic/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key, health_ratio_key)
	var/datum/action/cooldown/using_action = controller.blackboard[BB_MAGICARP_SPELL]
	if (!QDELETED(using_action) && using_action.IsAvailable())
		finish_action(controller, FALSE)
		return
	return ..()
