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
 * Decorator that gates its child on the pawn having been recently attacked by a valid enemy.
 *
 * On tick():
 *   1. Reads BB_BASIC_MOB_ATTACKED_BY (set by /datum/element/ai_retaliate).
 *   2. Validates the attacker against the controller's targeting strategy.
 *   3. If valid: writes the attacker to BB_BASIC_MOB_CURRENT_TARGET, clears BB_BASIC_MOB_ATTACKED_BY,
 *      then ticks the child.
 *   4. If not valid (no attacker or fails strategy): returns BT_FAILURE.
 *
 * Observer: observer_abort = BT_ABORT_LOWER_PRIORITY, watching BB_BASIC_MOB_ATTACKED_BY.
 * When the key is SET (ai_retaliate fires COMSIG_AI_BLACKBOARD_KEY_SET), lower-priority running
 * behaviors are cancelled and the BT is replanned, allowing this decorator to interrupt idle pathing.
 *
 * Replaces /datum/ai_planning_subtree/target_retaliate for BT-native controllers.
 */
/datum/bt_node/decorator/attacked_by_enemy
	observer_abort = BT_ABORT_LOWER_PRIORITY
	observed_keys = list(BB_BASIC_MOB_ATTACKED_BY)
	/// Blackboard key for the targeting strategy.
	var/targeting_strategy_key = BB_TARGETING_STRATEGY
	/// Blackboard key to write the retaliating target into.
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET
	/// Blackboard key to write the target's hiding location into.
	var/hiding_location_key = BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION

/datum/bt_node/decorator/attacked_by_enemy/tick(datum/ai_controller/controller, seconds_per_tick)
	var/mob/attacker = controller.blackboard[BB_BASIC_MOB_ATTACKED_BY]
	if(QDELETED(attacker))
		controller.clear_blackboard_key(BB_BASIC_MOB_ATTACKED_BY)
		return BT_FAILURE

	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])
	if(!strategy?.can_attack(controller.pawn, attacker))
		controller.clear_blackboard_key(BB_BASIC_MOB_ATTACKED_BY)
		return BT_FAILURE

	// Set the attacker as our new target
	controller.set_blackboard_key(target_key, attacker)
	var/atom/hiding = strategy.find_hidden_mobs(controller.pawn, attacker)
	if(hiding)
		controller.set_blackboard_key(hiding_location_key, hiding)

	// Consume the signal — only act on a single attack event per invocation
	controller.clear_blackboard_key(BB_BASIC_MOB_ATTACKED_BY)
	return child.tick(controller, seconds_per_tick)

/datum/bt_node/decorator/attacked_by_enemy/evaluate_for_observer(datum/ai_controller/controller)
	// Pure check for the observer path — only validates that the key holds a non-deleted mob.
	// Does NOT modify the blackboard (no side effects on interrupt).
	var/mob/attacker = controller.blackboard[BB_BASIC_MOB_ATTACKED_BY]
	return !QDELETED(attacker)
