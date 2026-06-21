/// AI for handling blood-drunk miner behavior
/// General consideration is as follows:
/// - If in PKA range, shoot PKA
/// - If not in PKA range, dash attack on the target
/// - If in melee range, use melee attacks (depending on saw state)
/// - After attacks, transform saw state from open to closed.
/datum/ai_controller/blood_drunk_miner
	behavior_tree_json = "code/modules/mob/living/basic/boss/blood_drunk_miner/blood_drunk_miner.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/no_gutted_mobs,
		BB_TARGET_MINIMUM_STAT = DEAD,
		BB_AGGRO_RANGE = 18, // oh fuck oh shit
		BB_BDM_RANGED_ATTACK_COOLDOWN = 0,
	)

	movement_delay = 0.25 SECONDS
	ai_movement = /datum/ai_movement/basic_avoidance

/datum/ai_controller/blood_drunk_miner/doom
	movement_delay = 0.5 SECONDS
