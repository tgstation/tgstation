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

/datum/ai_planning_subtree/escape_captivity/pacifist
	pacifist = TRUE

// =============================================================================
// Re-usable BT subtree composites
// =============================================================================

/**
 * Selector that replicates escape_captivity logic using BT decorator nodes.
 * Priority order: buckled > contained > grabbed by enemy > restrained.
 * The first matching condition queues the appropriate behavior and returns BT_RUNNING.
 * If none match, returns BT_FAILURE so the next behavior_nodes entry is tried.
 */
/datum/bt_node/subtree/escape_captivity
	behavior_tree_json = "escape_captivity.bt.json"

/// Pacifist variant: never attacks objects, only resists.
/datum/bt_node/subtree/escape_captivity/pacifist
	behavior_tree_json = "escape_captivity_pacifist.bt.json"
