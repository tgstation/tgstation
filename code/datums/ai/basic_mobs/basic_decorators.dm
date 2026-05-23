// =============================================================================
// Generic BT decorators for basic mob AI trees
// =============================================================================

/**
 * Decorator that runs its child with a configurable random probability each tick.
 * chance is a 0.0–1.0 float (e.g. 0.15 = 15%). Returns BT_FAILURE when the roll misses.
 *
 * Usage:
 *   BT_DECORATOR(/datum/bt_node/decorator/random_chance, child, "chance" = 0.15)
 */
/datum/bt_node/decorator/random_chance
	/// 0.0–1.0 float; converted to percentage for prob(). Configure via BT_DECORATOR.
	var/chance = 0.5

/datum/bt_node/decorator/random_chance/check_condition(datum/ai_controller/controller)
	return prob(chance * 100)

// =============================================================================

/**
 * Decorator that passes when the pawn is within melee range (dist ≤ 1) of its target.
 * Returns BT_FAILURE when the target is farther away or missing.
 * Useful for explicitly gating melee branches in a selector.
 *
 * Usage:
 *   BT_DECORATOR(/datum/bt_node/decorator/target_in_melee_range, child,
 *       "target_key" = BB_BASIC_MOB_CURRENT_TARGET)
 */
/datum/bt_node/decorator/target_in_melee_range
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET

/datum/bt_node/decorator/target_in_melee_range/check_condition(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	return get_dist(controller.pawn, target) <= 1

// =============================================================================

/**
 * Decorator that passes when the pawn is outside melee range (dist > 1) of its target.
 * Returns BT_FAILURE when adjacent or target is missing.
 * Useful for gating ranged branches in a selector.
 *
 * Usage:
 *   BT_DECORATOR(/datum/bt_node/decorator/target_outside_melee_range, child,
 *       "target_key" = BB_BASIC_MOB_CURRENT_TARGET)
 */
/datum/bt_node/decorator/target_outside_melee_range
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET

/datum/bt_node/decorator/target_outside_melee_range/check_condition(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	return get_dist(controller.pawn, target) > 1
