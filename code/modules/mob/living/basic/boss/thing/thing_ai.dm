/datum/ai_controller/basic_controller/thing_boss
	blackboard = list( //todo make less forgetful
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/no_gutted_mobs,
		BB_TARGET_MINIMUM_STAT = DEAD, // Will attack dead ungutted mobs
		BB_THETHING_CHARGE = null,
		BB_THETHING_DECIMATE = null,
		BB_THETHING_BIGTENDRILS = null,
		BB_THETHING_CARDTENDRILS = null,
		BB_THETHING_SHRIEK = null,
		BB_THETHING_ATTACKMODE = TRUE,
		BB_THETHING_NOAOE = TRUE,
		BB_THETHING_LASTAOE = null,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/no_target
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/thing_boss_aoe,
		/datum/ai_planning_subtree/thing_boss_melee,
	)

/datum/ai_planning_subtree/thing_boss_aoe/SelectBehaviors(datum/ai_controller/monkey/controller, seconds_per_tick)
	var/mob/living/pawn = controller.pawn
	if(HAS_TRAIT_FROM(pawn, TRAIT_IMMOBILIZED, MEGAFAUNA_TRAIT) || (controller.blackboard[BB_THETHING_ATTACKMODE] || controller.blackboard[BB_THETHING_NOAOE]))
		return
	// our target
	var/mob/living/shaft_miner = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(isnull(shaft_miner) || (isturf(shaft_miner.loc) && shaft_miner.z != pawn.z) || shaft_miner.stat == DEAD) //Dont use abilities on off z level targets, or dead shaft miners. We want to melee those.
		return

	controller.set_blackboard_key(BB_THETHING_ATTACKMODE, TRUE) // putting this here so we go to melee mode if we cant do any aoe
	var/static/list/aoe_attacks = list(BB_THETHING_DECIMATE, BB_THETHING_BIGTENDRILS, BB_THETHING_CARDTENDRILS)
	var/list/possible_attacks = aoe_attacks.Copy() - controller.blackboard[BB_THETHING_LASTAOE]
	for(var/bb_action_key in possible_attacks)
		var/datum/action/action = controller.blackboard[bb_action_key]
		if(!action?.IsAvailable())
			possible_attacks -= bb_action_key
	if(!length(possible_attacks))
		return
	var/current_aoe_key = pick(possible_attacks)
	controller.set_blackboard_key(BB_THETHING_LASTAOE, current_aoe_key)
	controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability, current_aoe_key, BB_BASIC_MOB_CURRENT_TARGET)
	if(prob(60) && shaft_miner.body_position != LYING_DOWN) //potential follow-up
		controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability, BB_THETHING_CHARGE, BB_BASIC_MOB_CURRENT_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING


/datum/ai_planning_subtree/thing_boss_melee/SelectBehaviors(datum/ai_controller/monkey/controller, seconds_per_tick)
	var/mob/living/pawn = controller.pawn
	if(HAS_TRAIT_FROM(pawn, TRAIT_IMMOBILIZED, MEGAFAUNA_TRAIT))
		return

	// our target
	var/mob/living/shaft_miner = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(isnull(shaft_miner) || (isturf(shaft_miner.loc) && shaft_miner.z != pawn.z))
		return
	var/target_dist = get_dist(pawn, shaft_miner)

	var/datum/action/shriek = controller.blackboard[BB_THETHING_SHRIEK]
	var/datum/action/charge = controller.blackboard[BB_THETHING_CHARGE]
	if(isnull(shriek) || isnull(charge))
		return // pray this never occurs

	controller.set_blackboard_key(BB_THETHING_ATTACKMODE, FALSE)

	if(shriek.IsAvailable() && target_dist <= 2 && shaft_miner.stat != DEAD)
		controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability/min_range/short, BB_THETHING_SHRIEK, BB_BASIC_MOB_CURRENT_TARGET)
		return
	else if(charge.IsAvailable() && target_dist >= 5) // While we cant hit prone targets, this helps to close the distance.
		controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability, BB_THETHING_CHARGE, BB_BASIC_MOB_CURRENT_TARGET)
		return

	controller.queue_behavior(/datum/ai_behavior/basic_melee_attack, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
