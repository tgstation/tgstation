/// Basetype with normal parameters
/datum/ai_controller/basic_controller/simple
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

// =============================================================================
// BT combat subtrees and controllers
// =============================================================================

/**
 * Selector: tries melee first (gated on having a target), falls back to find_potential_targets
 * only when no target is set. The bb_key_set decorator aborts the attack branch reactively when
 * the target is cleared so the selector can immediately fall through to target-finding.
 *
 * The attack branch runs as a BT_PARALLEL: basic_melee_attack (A) handles attacking when
 * adjacent; move_to_target (B) drives locomotion independently each tick.
 */
/datum/bt_node/subtree/simple_hostile_combat
	behavior_tree_json = "simple_hostile_combat.bt.json"

/// BT equivalent of simple_hostile. Escape has priority: bt_escape_captivity is tried first;
/// if no escape condition fires (BT_FAILURE) the combat parallel takes over.
/datum/ai_controller/basic_controller/simple/simple_hostile
	behavior_tree_json = "simple_hostile.bt.json"

// =============================================================================
// Additional BT combat subtrees
// =============================================================================

/// Ranged attack + movement toward target, falls back to target search
/datum/bt_node/subtree/simple_ranged_combat
	behavior_tree_json = "simple_ranged_combat.bt.json"

/// Ranged combat tree that only reacts to attackers (no active target search).
/// Uses the retaliate list: target_from_retaliate_list picks attacker, then combat runs.
/datum/bt_node/subtree/simple_ranged_retaliate_combat
	behavior_tree_json = "simple_ranged_retaliate_combat.bt.json"

/// Attacks obstacles (if blocking), then picks melee or ranged based on range, in parallel with movement.
/// Branch A is a selector: smash obstacles → punch if adjacent → shoot as fallback.
/datum/bt_node/subtree/simple_skirmisher_combat
	behavior_tree_json = "simple_skirmisher_combat.bt.json"

/// Use cooldown ability on target, in parallel with movement.
/// Branch A uses ability; movement is Branch B.
/datum/bt_node/subtree/simple_ability_combat
	behavior_tree_json = "simple_ability_combat.bt.json"

/// Ability combat, but only retaliates (no active target search).
/// Uses the retaliate list: target_from_retaliate_list picks attacker, then ability + movement run.
/datum/bt_node/subtree/simple_ability_retaliate_combat
	behavior_tree_json = "simple_ability_retaliate_combat.bt.json"

/// Use ability alongside melee, in parallel with movement.
/// Branch A is a selector: smash obstacles → use ability (preferred) → punch as fallback.
/datum/bt_node/subtree/simple_ability_melee_combat
	behavior_tree_json = "simple_ability_melee_combat.bt.json"

/// Use ability alongside ranged fire, in parallel with movement.
/// Branch A is a selector: ability (preferred) → ranged as fallback when ability on cooldown.
/datum/bt_node/subtree/simple_ability_ranged_combat
	behavior_tree_json = "simple_ability_ranged_combat.bt.json"

/// Reacts only to attackers with melee + movement.
/// Uses the retaliate list: target_from_retaliate_list picks attacker, then combat runs.
/datum/bt_node/subtree/simple_retaliate_combat
	behavior_tree_json = "simple_retaliate_combat.bt.json"

/// Randomly picks targets; de-aggros randomly too.
/// capricious_retaliate manages BB_BASIC_MOB_RETALIATE_LIST; target_from_retaliate_list picks
/// the actual combat target. Both run in parallel so de-aggro can interrupt combat mid-flight.
/datum/bt_node/subtree/simple_capricious_combat
	behavior_tree_json = "simple_capricious_combat.bt.json"

/// Finds nearest potential target and flees from them
/datum/bt_node/subtree/simple_fearful_combat
	behavior_tree_json = "simple_fearful_combat.bt.json"

/// Flees from attackers (from the retaliate list) only
/datum/bt_node/subtree/simple_skittish_combat
	behavior_tree_json = "simple_skittish_combat.bt.json"

/// Melee + obstacles, full priority order
/datum/bt_node/subtree/simple_hostile_obstacles_combat
	behavior_tree_json = "simple_hostile_obstacles_combat.bt.json"

// =============================================================================
// Ported simple_* controllers
// =============================================================================

/// Find a target, walk at target, attack intervening obstacles
/datum/ai_controller/basic_controller/simple/simple_hostile_obstacles
	behavior_tree_json = "simple_hostile_obstacles.bt.json"

/// Find a target, maintain distance, shoot them
/datum/ai_controller/basic_controller/simple/simple_ranged
	behavior_tree_json = "simple_ranged.bt.json"

/datum/ai_controller/basic_controller/simple/simple_ranged_retaliate
	behavior_tree_json = "simple_ranged_retaliate.bt.json"

/// Find a target, walk towards it AND shoot it
/datum/ai_controller/basic_controller/simple/simple_skirmisher
	behavior_tree_json = "simple_skirmisher.bt.json"

/// Use an ability on target on cooldown
/datum/ai_controller/basic_controller/simple/simple_ability
	behavior_tree_json = "simple_ability.bt.json"

/datum/ai_controller/basic_controller/simple/simple_ability_retaliate
	behavior_tree_json = "simple_ability_retaliate.bt.json"

/// Use an ability on target on cooldown, then try to punch them
/datum/ai_controller/basic_controller/simple/simple_ability_melee
	behavior_tree_json = "simple_ability_melee.bt.json"

/// Use an ability on target on cooldown, then try to shoot them
/datum/ai_controller/basic_controller/simple/simple_ability_ranged
	behavior_tree_json = "simple_ability_ranged.bt.json"

/// Fight back if attacked
/datum/ai_controller/basic_controller/simple/simple_retaliate
	behavior_tree_json = "simple_retaliate.bt.json"
	ai_traits = DEFAULT_AI_FLAGS | STOP_MOVING_WHEN_PULLED

/// Get pissed at random people for no reason
/datum/ai_controller/basic_controller/simple/simple_capricious
	behavior_tree_json = "simple_capricious.bt.json"
	ai_traits = DEFAULT_AI_FLAGS | STOP_MOVING_WHEN_PULLED

/// Runs away from anyone it sees
/datum/ai_controller/basic_controller/simple/simple_fearful
	behavior_tree_json = "simple_fearful.bt.json"
	ai_traits = PASSIVE_AI_FLAGS

/// Runs away when attacked
/datum/ai_controller/basic_controller/simple/simple_skittish
	behavior_tree_json = "simple_skittish.bt.json"
	ai_traits = PASSIVE_AI_FLAGS

/// Does what it is told and protects da boss
/// TODO: port pet command system to BT so pet_planning functions correctly
/datum/ai_controller/basic_controller/simple/simple_goon
	behavior_tree_json = "simple_goon.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)


/// Literally does nothing except random speech
/datum/ai_controller/basic_controller/talk
	behavior_tree_json = "talk.bt.json"
	idle_behavior = null
