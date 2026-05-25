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
/datum/bt_node/ai_behavior/break_out_of_object
	action_cooldown = 0.2 SECONDS

/datum/bt_node/ai_behavior/break_out_of_object/setup(datum/ai_controller/controller, atom/target)
	if (!should_attack_target(controller, target))
		return FALSE
	return TRUE

/datum/bt_node/ai_behavior/break_out_of_object/perform(seconds_per_tick, datum/ai_controller/controller, atom/target_atom)
	if (!should_attack_target(controller, target_atom))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	controller.ai_interact(target = target_atom, combat_mode = TRUE)
	return AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/break_out_of_object/proc/should_attack_target(datum/ai_controller/controller, atom/target)
	if (QDELETED(target))
		return FALSE
	var/mob/living/pawn = controller.pawn
	if (!target.IsReachableBy(pawn))
		return FALSE
	return pawn.loc == target || pawn.buckled == target

// DEPRECATED — port to /datum/bt_node/ai_behavior/break_out_of_object
/datum/ai_behavior/break_out_of_object
	parent_type = /datum/bt_node/ai_behavior/break_out_of_object

/datum/ai_planning_subtree/escape_captivity/pacifist
	pacifist = TRUE

// =============================================================================
// BT-native escape captivity nodes
// These replace the legacy subtree for controllers that use the inline descriptor system.
// The legacy /datum/ai_planning_subtree/escape_captivity remains untouched for other controllers.
// =============================================================================

/**
 * Variant of break_out_of_object that reads its target from a blackboard key.
 * Use as BT_LEAF(/datum/bt_node/ai_behavior/break_out_of_object/from_bb, BB_BASIC_MOB_ESCAPE_TARGET).
 * The escape-condition decorators write the target into the BB key before ticking this behavior.
 */
/datum/bt_node/ai_behavior/break_out_of_object/from_bb

/datum/bt_node/ai_behavior/break_out_of_object/from_bb/setup(datum/ai_controller/controller, target_key)
	var/atom/target = controller.blackboard[target_key]
	return should_attack_target(controller, target)

/datum/bt_node/ai_behavior/break_out_of_object/from_bb/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/atom/target = controller.blackboard[target_key]
	if(!should_attack_target(controller, target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	controller.ai_interact(target = target, combat_mode = TRUE)
	return AI_BEHAVIOR_DELAY

// --- Escape condition decorators ---

/**
 * Gates its child on the pawn being buckled to an obj.
 * As a side effect of tick(), writes pawn.buckled into BB_BASIC_MOB_ESCAPE_TARGET so
 * child behaviors (break_out_of_object/from_bb) can access it without a direct reference.
 * Uses evaluate_for_observer() (pure, no side effects) for the observer interrupt path.
 * Set observer_abort = BT_ABORT_LOWER_PRIORITY; watches COMSIG_MOB_BUCKLED + COMSIG_MOB_UNBUCKLED.
 */
/datum/bt_node/decorator/pawn_buckled_to_obj
	var/target_key = BB_BASIC_MOB_ESCAPE_TARGET
	observer_abort = BT_ABORT_LOWER_PRIORITY

/datum/bt_node/decorator/pawn_buckled_to_obj/get_pawn_observe_signals()
	return list(COMSIG_MOB_BUCKLED, COMSIG_MOB_UNBUCKLED)

/datum/bt_node/decorator/pawn_buckled_to_obj/tick(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/pawn = controller.pawn
	if(!isobj(pawn.buckled))
		return BT_FAILURE
	controller.blackboard[target_key] = pawn.buckled
	return child.tick(controller, seconds_per_tick)

/datum/bt_node/decorator/pawn_buckled_to_obj/evaluate_for_observer(datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	return isobj(pawn.buckled)

/**
 * Gates its child on the buckle target having TRAIT_DANGEROUS_BUCKLE (i.e. worth attacking to escape).
 * Inner decorator — no observer needed; only evaluated inside a pawn_buckled_to_obj branch.
 */
/datum/bt_node/decorator/buckle_target_dangerous
	var/pacifist = FALSE
	var/target_key = BB_BASIC_MOB_ESCAPE_TARGET

/datum/bt_node/decorator/buckle_target_dangerous/check_condition(datum/ai_controller/controller)
	if(pacifist)
		return FALSE
	var/atom/target = controller.blackboard[target_key]
	return !isnull(target) && HAS_TRAIT(target, TRAIT_DANGEROUS_BUCKLE)

/**
 * Gates its child on the pawn being inside an obj (not a turf, not a mob, not a mob_holder).
 * tick() writes pawn.loc into the escape target BB key as a side effect.
 * evaluate_for_observer() is pure (no side effects).
 * Set observer_abort = BT_ABORT_LOWER_PRIORITY; watches COMSIG_MOVABLE_MOVED.
 */
/datum/bt_node/decorator/pawn_contained_in_obj
	var/target_key = BB_BASIC_MOB_ESCAPE_TARGET
	observer_abort = BT_ABORT_LOWER_PRIORITY

/datum/bt_node/decorator/pawn_contained_in_obj/get_pawn_observe_signals()
	return list(COMSIG_MOVABLE_MOVED)

/datum/bt_node/decorator/pawn_contained_in_obj/tick(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/pawn = controller.pawn
	if(isturf(pawn.loc) || ismob(pawn.loc) || istype(pawn.loc, /obj/item/mob_holder))
		return BT_FAILURE
	controller.blackboard[target_key] = pawn.loc
	return child.tick(controller, seconds_per_tick)

/datum/bt_node/decorator/pawn_contained_in_obj/evaluate_for_observer(datum/ai_controller/controller)
	var/atom/loc = controller.pawn.loc
	return !isturf(loc) && !ismob(loc) && !istype(loc, /obj/item/mob_holder)

/**
 * Gates its child on the container being worth attacking (pawn.obj_damage > damage_deflection).
 * Inner decorator — no observer needed; only evaluated inside a pawn_contained_in_obj branch.
 */
/datum/bt_node/decorator/container_attackable
	var/pacifist = FALSE
	var/target_key = BB_BASIC_MOB_ESCAPE_TARGET

/datum/bt_node/decorator/container_attackable/check_condition(datum/ai_controller/controller)
	if(pacifist)
		return FALSE
	if(!isbasicmob(controller.pawn))
		return FALSE
	var/atom/target = controller.blackboard[target_key]
	if(isnull(target))
		return FALSE
	var/mob/living/basic/basic_pawn = controller.pawn
	return basic_pawn.obj_damage > target.damage_deflection

/**
 * Gates its child on the pawn being grabbed above GRAB_PASSIVE by an enemy.
 * No observer — grab initiation has no clean pawn-side signal; evaluated each planning tick. Should add a signal to this later probably lol
 */
/datum/bt_node/decorator/pawn_grabbed_by_enemy
	var/targeting_strategy_key = BB_TARGETING_STRATEGY
	child_typepath = /datum/bt_node/ai_behavior/resist

/datum/bt_node/decorator/pawn_grabbed_by_enemy/check_condition(datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	var/mob/puller = pawn.pulledby
	if(isnull(puller) || puller.grab_state <= GRAB_PASSIVE)
		return FALSE
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])
	if(!strategy?.can_attack(pawn, puller))
		return FALSE
	var/list/friends = controller.blackboard[BB_FRIENDS_LIST] || list()
	return !(puller in friends)

/**
 * Gates its child on the pawn having TRAIT_RESTRAINED.
 * Set observer_abort = BT_ABORT_LOWER_PRIORITY; watches SIGNAL_ADDTRAIT and SIGNAL_REMOVETRAIT.
 */
/datum/bt_node/decorator/pawn_is_restrained
	observer_abort = BT_ABORT_LOWER_PRIORITY
	child_typepath = /datum/bt_node/ai_behavior/resist

/datum/bt_node/decorator/pawn_is_restrained/get_pawn_observe_signals()
	return list(SIGNAL_ADDTRAIT(TRAIT_RESTRAINED), SIGNAL_REMOVETRAIT(TRAIT_RESTRAINED))

/datum/bt_node/decorator/pawn_is_restrained/check_condition(datum/ai_controller/controller)
	return HAS_TRAIT(controller.pawn, TRAIT_RESTRAINED)

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
	// @bt-generated begin
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/decorator/pawn_buckled_to_obj,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/selector,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/decorator/buckle_target_dangerous,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/break_out_of_object/from_bb, "default_behavior_args" = list(BB_BASIC_MOB_ESCAPE_TARGET))\
								)\
							),\
							list("__t" = /datum/bt_node/ai_behavior/resist, "default_behavior_args" = list())\
						)\
					)\
				)\
			),\
			list(\
				"__t" = /datum/bt_node/decorator/pawn_contained_in_obj,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/selector,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/decorator/container_attackable,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/break_out_of_object/from_bb, "default_behavior_args" = list(BB_BASIC_MOB_ESCAPE_TARGET))\
								)\
							),\
							list("__t" = /datum/bt_node/ai_behavior/resist, "default_behavior_args" = list())\
						)\
					)\
				)\
			),\
			list(\
				"__t" = /datum/bt_node/decorator/pawn_grabbed_by_enemy,\
				"__c" = list(\
					list("__t" = /datum/bt_node/ai_behavior/resist, "default_behavior_args" = list())\
				)\
			),\
			list(\
				"__t" = /datum/bt_node/decorator/pawn_is_restrained,\
				"__c" = list(\
					list("__t" = /datum/bt_node/ai_behavior/resist, "default_behavior_args" = list())\
				)\
			)\
		)\
	)
	// @bt-generated end

/// Pacifist variant: never attacks objects, only resists.
/datum/bt_node/subtree/escape_captivity/pacifist
	behavior_tree_json = "escape_captivity_pacifist.bt.json"
	behavior_nodes = BT_SELECTOR(\
		BT_DECORATOR(/datum/bt_node/decorator/pawn_buckled_to_obj,\
			BT_LEAF(/datum/bt_node/ai_behavior/resist)\
		),\
		BT_DECORATOR(/datum/bt_node/decorator/pawn_contained_in_obj,\
			BT_LEAF(/datum/bt_node/ai_behavior/resist)\
		),\
		BT_DECORATOR(/datum/bt_node/decorator/pawn_grabbed_by_enemy,\
			BT_LEAF(/datum/bt_node/ai_behavior/resist)\
		),\
		BT_DECORATOR(/datum/bt_node/decorator/pawn_is_restrained,\
			BT_LEAF(/datum/bt_node/ai_behavior/resist)\
		)\
	)
