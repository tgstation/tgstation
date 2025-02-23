/**
 * Slap someone who is nearby, line up with target, blast with a beam
 */
/datum/ai_controller/basic_controller/brimdemon
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_traits = PAUSE_DURING_DO_AFTER
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/no_target
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic,
		/datum/ai_planning_subtree/move_to_cardinal/brimdemon,
		/datum/ai_planning_subtree/targeted_mob_ability/brimbeam,
	)

/datum/ai_planning_subtree/move_to_cardinal/brimdemon
	move_behaviour = /datum/ai_behavior/move_to_cardinal/brimdemon

/datum/ai_behavior/move_to_cardinal/brimdemon
	minimum_distance = 2

/datum/ai_behavior/move_to_cardinal/brimdemon/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if(!succeeded)
		return
	var/mob/living/target = controller.blackboard[target_key]
	var/datum/action/cooldown/ability = controller.blackboard[BB_TARGETED_ACTION]
	if(QDELETED(target) || QDELETED(controller.pawn) || !ability?.IsAvailable())
		return
	ability.InterceptClickOn(clicker = controller.pawn, target = target)

/datum/ai_planning_subtree/targeted_mob_ability/brimbeam
	use_ability_behaviour = /datum/ai_behavior/targeted_mob_ability/brimbeam

/datum/ai_behavior/targeted_mob_ability/brimbeam
	/// Don't shoot if too far away
	var/max_target_distance = 9

/datum/ai_behavior/targeted_mob_ability/brimbeam/perform(seconds_per_tick, datum/ai_controller/controller, ability_key, target_key)
	var/mob/living/target = controller.blackboard[target_key]
	if (QDELETED(target) || !(get_dir(controller.pawn, target) in GLOB.cardinals) || get_dist(controller.pawn, target) > max_target_distance)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	return ..()
