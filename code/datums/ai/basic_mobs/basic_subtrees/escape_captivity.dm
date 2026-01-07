/// Generically try to escape from being trapped
/datum/ai_planning_subtree/escape_captivity
	/// Targeting strategy for use deciding if we can attack a mob grabbing us
	var/targeting_strategy_key = BB_TARGETING_STRATEGY
	/// If true we will never attack objects
	var/pacifist = FALSE

/datum/ai_planning_subtree/escape_captivity/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn

	if (isobj(living_pawn.buckled))
		// we can just stand up we don't need to freak out
		if (pacifist || !HAS_TRAIT(living_pawn.buckled, TRAIT_DANGEROUS_BUCKLE))
			controller.queue_behavior(/datum/ai_behavior/resist)
		// otherwise beat the shit out of we we gotta get out NOW
		else
			controller.queue_behavior(/datum/ai_behavior/break_out_of_object, living_pawn.buckled)
		return SUBTREE_RETURN_FINISH_PLANNING

	if (!isturf(living_pawn.loc) && !ismob(living_pawn.loc) && !istype(living_pawn.loc, /obj/item/mob_holder))
		var/atom/contained_in = living_pawn.loc
		var/attack_effective = FALSE
		if (!pacifist)
			if (isbasicmob(living_pawn)) // Currently this literally only works for basic mobs because it's hard to check for anyone else but it's ok because only they use this subtree
				var/mob/living/basic/basic_pawn = living_pawn
				attack_effective = basic_pawn.obj_damage > contained_in.damage_deflection
		if (attack_effective)
			controller.queue_behavior(/datum/ai_behavior/break_out_of_object, contained_in)
		else
			controller.queue_behavior(/datum/ai_behavior/resist)
		return SUBTREE_RETURN_FINISH_PLANNING

	var/mob/puller = living_pawn.pulledby
	if (puller && puller.grab_state > GRAB_PASSIVE)
		var/datum/targeting_strategy/targeting_strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])
		var/friends_list = controller.blackboard[BB_FRIENDS_LIST] || list()
		// Only resist grabs from mobs that aren't in our faction
		if (targeting_strategy?.can_attack(living_pawn, puller) && !(puller in friends_list))
			controller.queue_behavior(/datum/ai_behavior/resist)
			return SUBTREE_RETURN_FINISH_PLANNING

	if (HAS_TRAIT(living_pawn, TRAIT_RESTRAINED))
		controller.queue_behavior(/datum/ai_behavior/resist)
		return SUBTREE_RETURN_FINISH_PLANNING

/// Keep attacking an object while it is our loc or while we are buckled to it
/datum/ai_behavior/break_out_of_object
	action_cooldown = 0.2 SECONDS

/datum/ai_behavior/break_out_of_object/setup(datum/ai_controller/controller, atom/target)
	if (!should_attack_target(controller, target))
		return FALSE
	return TRUE

/datum/ai_behavior/break_out_of_object/perform(seconds_per_tick, datum/ai_controller/controller, atom/target_atom)
	if (!should_attack_target(controller, target_atom))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	controller.ai_interact(target = target_atom, combat_mode = TRUE)
	return AI_BEHAVIOR_DELAY

/datum/ai_behavior/break_out_of_object/proc/should_attack_target(datum/ai_controller/controller, atom/target)
	if (QDELETED(target))
		return FALSE
	var/mob/living/pawn = controller.pawn
	if (!target.IsReachableBy(pawn))
		return FALSE
	return pawn.loc == target || pawn.buckled == target

/datum/ai_planning_subtree/escape_captivity/pacifist
	pacifist = TRUE
