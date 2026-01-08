/// AI for handling blood-drunk miner behavior
/// General consideration is as follows:
/// - If in PKA range, shoot PKA
/// - If not in PKA range, dash attack on the target
/// - If in melee range, use melee attacks (depending on saw state)
/// - After attacks, transform saw state from open to closed.
/datum/ai_controller/blood_drunk_miner
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/no_gutted_mobs,
		BB_TARGET_MINIMUM_STAT = DEAD,
		BB_AGGRO_RANGE = 18, // oh fuck oh shit
		BB_BDM_RANGED_ATTACK_COOLDOWN = 0,
	)

	movement_delay = 0.3 SECONDS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/targeted_mob_ability/blood_drunk/shoot_pka,
		/datum/ai_planning_subtree/targeted_mob_ability/blood_drunk/dash_attack,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Parent type that contains key logic important for subsequent abilities
/datum/ai_planning_subtree/targeted_mob_ability/blood_drunk
	/// Range where we determine what distance we're at. If higher, we consider ourselves out of PKA range and will dash attack instead. Inclusive when it comes to choosing to shoot PKA.
	var/pka_range = 3

/// Check our blackboard to see if we are able to use a ranged ability in the first place
/datum/ai_planning_subtree/targeted_mob_ability/blood_drunk/additional_ability_checks(datum/ai_controller/controller, datum/action/cooldown/using_action)
	. = ..()
	if(controller.blackboard[BB_BDM_RANGED_ATTACK_COOLDOWN] > world.time)
		return FALSE
	controller.override_blackboard_key(BB_BDM_RANGED_ATTACK_COOLDOWN, world.time + controller.blackboard[BB_BDM_RANGED_ATTACK_COOLDOWN_DURATION])

/// The BDM will preferentially shoot its PKA within range over other abilities
/datum/ai_planning_subtree/targeted_mob_ability/blood_drunk/shoot_pka
	ability_key = BB_BDM_KINETIC_ACCELERATOR_ABILITY

/datum/ai_planning_subtree/targeted_mob_ability/blood_drunk/shoot_pka/additional_ability_checks(datum/ai_controller/controller, datum/action/cooldown/using_action)
	. = ..()
	// do not shoot the PKA if we are not in the right range
	var/mob/living/pawn = controller.pawn
	var/mob/living/victim = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(get_dist(pawn, victim) >= pka_range)
		return FALSE
	return TRUE

/// The BDM will dash attack if not in PKA range
/datum/ai_planning_subtree/targeted_mob_ability/blood_drunk/dash_attack
	ability_key = BB_BDM_DASH_ATTACK_ABILITY

/datum/ai_planning_subtree/targeted_mob_ability/blood_drunk/dash_attack/additional_ability_checks(datum/ai_controller/controller, datum/action/cooldown/using_action)
	. = ..()
	// only dash attack if we are out of PKA range
	var/mob/living/pawn = controller.pawn
	var/mob/living/victim = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(get_dist(pawn, victim) < pka_range)
		return FALSE
	return TRUE

/datum/ai_controller/blood_drunk_miner/doom
	movement_delay = 0.8 SECONDS
