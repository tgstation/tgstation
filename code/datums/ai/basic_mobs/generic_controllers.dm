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
	behavior_nodes = BT_SELECTOR(\
						BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
							BT_PARALLEL(BT_PARALLEL_FAILURE_ANY, BT_PARALLEL_SUCCESS_CHILD_ONE, FALSE, FALSE,\
								BT_LEAF(/datum/bt_node/ai_behavior/basic_melee_attack,\
									BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
								),\
								BT_LEAF(/datum/bt_node/ai_behavior/move_to_target,\
									BB_BASIC_MOB_CURRENT_TARGET, 1\
								)\
							),\
							"key" = BB_BASIC_MOB_CURRENT_TARGET,\
							"observed_keys" = list(BB_BASIC_MOB_CURRENT_TARGET),\
							"observer_abort" = BT_ABORT_SELF\
						),\
						BT_LEAF(/datum/bt_node/ai_behavior/find_potential_targets,\
							BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
						)\
			)

/// BT equivalent of simple_hostile. Escape has priority: bt_escape_captivity is tried first;
/// if no escape condition fires (BT_FAILURE) the combat parallel takes over.
/datum/ai_controller/basic_controller/simple/simple_hostile
	behavior_tree_json = "simple_hostile.bt.json"
	behavior_nodes = BT_SELECTOR(\
		BT_SUBTREE(/datum/bt_node/subtree/escape_captivity),\
		BT_SUBTREE(/datum/bt_node/subtree/simple_hostile_combat),\
	)

// =============================================================================
// Additional BT combat subtrees
// =============================================================================

/// Ranged attack + movement toward target, falls back to target search
/datum/bt_node/subtree/simple_ranged_combat
	behavior_tree_json = "simple_ranged_combat.bt.json"
	behavior_nodes = BT_SELECTOR(\
						BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
							BT_PARALLEL(BT_PARALLEL_FAILURE_ANY, BT_PARALLEL_SUCCESS_CHILD_ONE, FALSE, FALSE,\
								BT_LEAF(/datum/bt_node/ai_behavior/basic_ranged_attack,\
									BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
								),\
								BT_LEAF(/datum/bt_node/ai_behavior/move_to_target,\
									BB_BASIC_MOB_CURRENT_TARGET, 3\
								)\
							),\
							"key" = BB_BASIC_MOB_CURRENT_TARGET,\
							"observed_keys" = list(BB_BASIC_MOB_CURRENT_TARGET),\
							"observer_abort" = BT_ABORT_SELF\
						),\
						BT_LEAF(/datum/bt_node/ai_behavior/find_potential_targets,\
							BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
						)\
			)

/// Ranged combat tree that only reacts to attackers (no active target search).
/// Uses the retaliate list: target_from_retaliate_list picks attacker, then combat runs.
/datum/bt_node/subtree/simple_ranged_retaliate_combat
	behavior_tree_json = "simple_ranged_combat.bt.json"
	behavior_nodes = BT_SELECTOR(\
						BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
							BT_SEQUENCE(\
								BT_LEAF(/datum/bt_node/ai_behavior/target_from_retaliate_list,\
									BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
								),\
								BT_PARALLEL(BT_PARALLEL_FAILURE_ANY, BT_PARALLEL_SUCCESS_CHILD_ONE, FALSE, FALSE,\
									BT_LEAF(/datum/bt_node/ai_behavior/basic_ranged_attack,\
										BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
									),\
									BT_LEAF(/datum/bt_node/ai_behavior/move_to_target,\
										BB_BASIC_MOB_CURRENT_TARGET, 3\
									)\
								)\
							),\
							"key" = BB_BASIC_MOB_RETALIATE_LIST,\
							"observed_keys" = list(BB_BASIC_MOB_RETALIATE_LIST),\
							"observer_abort" = BT_ABORT_LOWER_PRIORITY\
						)\
			)

/// Attacks obstacles (if blocking), then picks melee or ranged based on range, in parallel with movement.
/// Branch A is a selector: smash obstacles → punch if adjacent → shoot as fallback.
/datum/bt_node/subtree/simple_skirmisher_combat
	behavior_tree_json = "simple_skirmisher_combat.bt.json"
	behavior_nodes = BT_SELECTOR(\
						BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
							BT_PARALLEL(BT_PARALLEL_FAILURE_ANY, BT_PARALLEL_SUCCESS_CHILD_ONE, FALSE, FALSE,\
								BT_SELECTOR(\
									BT_LEAF(/datum/bt_node/ai_behavior/attack_obstructions, BB_BASIC_MOB_CURRENT_TARGET),\
									BT_LEAF(/datum/bt_node/ai_behavior/basic_melee_attack,\
										BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
									),\
									BT_LEAF(/datum/bt_node/ai_behavior/basic_ranged_attack,\
										BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
									)\
								),\
								BT_LEAF(/datum/bt_node/ai_behavior/move_to_target,\
									BB_BASIC_MOB_CURRENT_TARGET, 1\
								)\
							),\
							"key" = BB_BASIC_MOB_CURRENT_TARGET,\
							"observed_keys" = list(BB_BASIC_MOB_CURRENT_TARGET),\
							"observer_abort" = BT_ABORT_SELF\
						),\
						BT_LEAF(/datum/bt_node/ai_behavior/find_potential_targets,\
							BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
						)\
			)

/// Use cooldown ability on target, in parallel with movement.
/// Branch A uses ability; movement is Branch B.
/datum/bt_node/subtree/simple_ability_combat
	behavior_tree_json = "simple_ability_combat.bt.json"
	behavior_nodes = BT_SELECTOR(\
						BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
							BT_PARALLEL(BT_PARALLEL_FAILURE_ANY, BT_PARALLEL_SUCCESS_CHILD_ONE, FALSE, FALSE,\
								BT_LEAF(/datum/bt_node/ai_behavior/targeted_mob_ability,\
									BB_TARGETED_ACTION, BB_BASIC_MOB_CURRENT_TARGET\
								),\
								BT_LEAF(/datum/bt_node/ai_behavior/move_to_target,\
									BB_BASIC_MOB_CURRENT_TARGET, 3\
								)\
							),\
							"key" = BB_BASIC_MOB_CURRENT_TARGET,\
							"observed_keys" = list(BB_BASIC_MOB_CURRENT_TARGET),\
							"observer_abort" = BT_ABORT_SELF\
						),\
						BT_LEAF(/datum/bt_node/ai_behavior/find_potential_targets,\
							BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
						)\
			)

/// Ability combat, but only retaliates (no active target search).
/// Uses the retaliate list: target_from_retaliate_list picks attacker, then ability + movement run.
/datum/bt_node/subtree/simple_ability_retaliate_combat
	behavior_tree_json = "simple_ability_combat.bt.json"
	behavior_nodes = BT_SELECTOR(\
						BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
							BT_SEQUENCE(\
								BT_LEAF(/datum/bt_node/ai_behavior/target_from_retaliate_list,\
									BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
								),\
								BT_PARALLEL(BT_PARALLEL_FAILURE_ANY, BT_PARALLEL_SUCCESS_CHILD_ONE, FALSE, FALSE,\
									BT_LEAF(/datum/bt_node/ai_behavior/targeted_mob_ability,\
										BB_TARGETED_ACTION, BB_BASIC_MOB_CURRENT_TARGET\
									),\
									BT_LEAF(/datum/bt_node/ai_behavior/move_to_target,\
										BB_BASIC_MOB_CURRENT_TARGET, 3\
									)\
								)\
							),\
							"key" = BB_BASIC_MOB_RETALIATE_LIST,\
							"observed_keys" = list(BB_BASIC_MOB_RETALIATE_LIST),\
							"observer_abort" = BT_ABORT_LOWER_PRIORITY\
						)\
			)

/// Use ability alongside melee, in parallel with movement.
/// Branch A is a selector: smash obstacles → use ability (preferred) → punch as fallback.
/datum/bt_node/subtree/simple_ability_melee_combat
	behavior_tree_json = "simple_ability_melee_combat.bt.json"
	behavior_nodes = BT_SELECTOR(\
						BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
							BT_PARALLEL(BT_PARALLEL_FAILURE_ANY, BT_PARALLEL_SUCCESS_CHILD_ONE, FALSE, FALSE,\
								BT_SELECTOR(\
									BT_LEAF(/datum/bt_node/ai_behavior/attack_obstructions, BB_BASIC_MOB_CURRENT_TARGET),\
									BT_LEAF(/datum/bt_node/ai_behavior/targeted_mob_ability,\
										BB_TARGETED_ACTION, BB_BASIC_MOB_CURRENT_TARGET\
									),\
									BT_LEAF(/datum/bt_node/ai_behavior/basic_melee_attack,\
										BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
									)\
								),\
								BT_LEAF(/datum/bt_node/ai_behavior/move_to_target,\
									BB_BASIC_MOB_CURRENT_TARGET, 1\
								)\
							),\
							"key" = BB_BASIC_MOB_CURRENT_TARGET,\
							"observed_keys" = list(BB_BASIC_MOB_CURRENT_TARGET),\
							"observer_abort" = BT_ABORT_SELF\
						),\
						BT_LEAF(/datum/bt_node/ai_behavior/find_potential_targets,\
							BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
						)\
			)

/// Use ability alongside ranged fire, in parallel with movement.
/// Branch A is a selector: ability (preferred) → ranged as fallback when ability on cooldown.
/datum/bt_node/subtree/simple_ability_ranged_combat
	behavior_tree_json = "simple_ability_ranged_combat.bt.json"
	behavior_nodes = BT_SELECTOR(\
						BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
							BT_PARALLEL(BT_PARALLEL_FAILURE_ANY, BT_PARALLEL_SUCCESS_CHILD_ONE, FALSE, FALSE,\
								BT_SELECTOR(\
									BT_LEAF(/datum/bt_node/ai_behavior/targeted_mob_ability,\
										BB_TARGETED_ACTION, BB_BASIC_MOB_CURRENT_TARGET\
									),\
									BT_LEAF(/datum/bt_node/ai_behavior/basic_ranged_attack,\
										BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
									)\
								),\
								BT_LEAF(/datum/bt_node/ai_behavior/move_to_target,\
									BB_BASIC_MOB_CURRENT_TARGET, 3\
								)\
							),\
							"key" = BB_BASIC_MOB_CURRENT_TARGET,\
							"observed_keys" = list(BB_BASIC_MOB_CURRENT_TARGET),\
							"observer_abort" = BT_ABORT_SELF\
						),\
						BT_LEAF(/datum/bt_node/ai_behavior/find_potential_targets,\
							BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
						)\
			)

/// Reacts only to attackers with melee + movement.
/// Uses the retaliate list: target_from_retaliate_list picks attacker, then combat runs.
/datum/bt_node/subtree/simple_retaliate_combat
	behavior_tree_json = "simple_retaliate_combat.bt.json"
	behavior_nodes = BT_SELECTOR(\
						BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
							BT_SEQUENCE(\
								BT_LEAF(/datum/bt_node/ai_behavior/target_from_retaliate_list,\
									BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
								),\
								BT_PARALLEL(BT_PARALLEL_FAILURE_ANY, BT_PARALLEL_SUCCESS_CHILD_ONE, FALSE, FALSE,\
									BT_LEAF(/datum/bt_node/ai_behavior/basic_melee_attack,\
										BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
									),\
									BT_LEAF(/datum/bt_node/ai_behavior/move_to_target,\
										BB_BASIC_MOB_CURRENT_TARGET, 1\
									)\
								)\
							),\
							"key" = BB_BASIC_MOB_RETALIATE_LIST,\
							"observed_keys" = list(BB_BASIC_MOB_RETALIATE_LIST),\
							"observer_abort" = BT_ABORT_LOWER_PRIORITY\
						)\
			)

/// Randomly picks targets; de-aggros randomly too.
/// capricious_retaliate manages BB_BASIC_MOB_RETALIATE_LIST; target_from_retaliate_list picks
/// the actual combat target. Both run in parallel so de-aggro can interrupt combat mid-flight.
/datum/bt_node/subtree/simple_capricious_combat
	behavior_tree_json = "simple_capricious_combat.bt.json"
	behavior_nodes = BT_PARALLEL(BT_PARALLEL_FAILURE_CHILD_ONE, BT_PARALLEL_SUCCESS_CHILD_ONE, TRUE, FALSE,\
						BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
							BT_SEQUENCE(\
								BT_LEAF(/datum/bt_node/ai_behavior/target_from_retaliate_list,\
									BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
								),\
								BT_PARALLEL(BT_PARALLEL_FAILURE_ANY, BT_PARALLEL_SUCCESS_CHILD_ONE, FALSE, FALSE,\
									BT_LEAF(/datum/bt_node/ai_behavior/basic_melee_attack,\
										BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
									),\
									BT_LEAF(/datum/bt_node/ai_behavior/move_to_target,\
										BB_BASIC_MOB_CURRENT_TARGET, 1\
									)\
								)\
							),\
							"key" = BB_BASIC_MOB_RETALIATE_LIST,\
							"observed_keys" = list(BB_BASIC_MOB_RETALIATE_LIST),\
							"observer_abort" = BT_ABORT_SELF\
						),\
						BT_LEAF(/datum/bt_node/ai_behavior/capricious_retaliate,\
							BB_TARGETING_STRATEGY, TRUE\
						)\
					)

/// Finds nearest potential target and flees from them
/datum/bt_node/subtree/simple_fearful_combat
	behavior_tree_json = "simple_fearful_combat.bt.json"
	behavior_nodes = BT_SELECTOR(\
						BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
							BT_LEAF(/datum/bt_node/ai_behavior/run_away_from_target,\
								BB_BASIC_MOB_CURRENT_TARGET, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
							),\
							"key" = BB_BASIC_MOB_CURRENT_TARGET,\
							"observed_keys" = list(BB_BASIC_MOB_CURRENT_TARGET),\
							"observer_abort" = BT_ABORT_SELF\
						),\
						BT_LEAF(/datum/bt_node/ai_behavior/find_potential_targets/nearest,\
							BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
						)\
			)

/// Flees from attackers (from the retaliate list) only
/datum/bt_node/subtree/simple_skittish_combat
	behavior_tree_json = "simple_skittish_combat.bt.json"
	behavior_nodes = BT_SELECTOR(\
						BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
							BT_LEAF(/datum/bt_node/ai_behavior/run_away_from_target,\
								BB_BASIC_MOB_CURRENT_TARGET, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
							),\
							"key" = BB_BASIC_MOB_CURRENT_TARGET,\
							"observed_keys" = list(BB_BASIC_MOB_CURRENT_TARGET),\
							"observer_abort" = BT_ABORT_SELF\
						),\
						BT_LEAF(/datum/bt_node/ai_behavior/target_from_retaliate_list/nearest,\
							BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
						)\
			)

/// Melee + obstacles, full priority order
/datum/bt_node/subtree/simple_hostile_obstacles_combat
	behavior_tree_json = "simple_hostile_obstacles_combat.bt.json"
	behavior_nodes = BT_SELECTOR(\
						BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
							BT_PARALLEL(BT_PARALLEL_FAILURE_ANY, BT_PARALLEL_SUCCESS_CHILD_ONE, FALSE, FALSE,\
								BT_SELECTOR(\
									BT_LEAF(/datum/bt_node/ai_behavior/attack_obstructions, BB_BASIC_MOB_CURRENT_TARGET),\
									BT_LEAF(/datum/bt_node/ai_behavior/basic_melee_attack,\
										BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
									)\
								),\
								BT_LEAF(/datum/bt_node/ai_behavior/move_to_target,\
									BB_BASIC_MOB_CURRENT_TARGET, 1\
								)\
							),\
							"key" = BB_BASIC_MOB_CURRENT_TARGET,\
							"observed_keys" = list(BB_BASIC_MOB_CURRENT_TARGET),\
							"observer_abort" = BT_ABORT_SELF\
						),\
						BT_LEAF(/datum/bt_node/ai_behavior/find_potential_targets,\
							BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
						)\
			)

// =============================================================================
// Ported simple_* controllers
// =============================================================================

/// Find a target, walk at target, attack intervening obstacles
/datum/ai_controller/basic_controller/simple/simple_hostile_obstacles
	behavior_tree_json = "simple_hostile_obstacles.bt.json"
	behavior_nodes = BT_SELECTOR(\
		BT_SUBTREE(/datum/bt_node/subtree/escape_captivity),\
		BT_SUBTREE(/datum/bt_node/subtree/simple_hostile_obstacles_combat),\
	)

/// Find a target, maintain distance, shoot them
/datum/ai_controller/basic_controller/simple/simple_ranged
	behavior_tree_json = "simple_ranged.bt.json"
	behavior_nodes = BT_SELECTOR(\
		BT_SUBTREE(/datum/bt_node/subtree/escape_captivity),\
		BT_SUBTREE(/datum/bt_node/subtree/simple_ranged_combat),\
	)

/datum/ai_controller/basic_controller/simple/simple_ranged_retaliate
	behavior_tree_json = "simple_ranged_retaliate.bt.json"
	behavior_nodes = BT_SELECTOR(\
		BT_SUBTREE(/datum/bt_node/subtree/escape_captivity),\
		BT_SUBTREE(/datum/bt_node/subtree/simple_ranged_retaliate_combat),\
	)

/// Find a target, walk towards it AND shoot it
/datum/ai_controller/basic_controller/simple/simple_skirmisher
	behavior_tree_json = "simple_skirmisher.bt.json"
	behavior_nodes = BT_SELECTOR(\
		BT_SUBTREE(/datum/bt_node/subtree/escape_captivity),\
		BT_SUBTREE(/datum/bt_node/subtree/simple_skirmisher_combat),\
	)

/// Use an ability on target on cooldown
/datum/ai_controller/basic_controller/simple/simple_ability
	behavior_tree_json = "simple_ability.bt.json"
	// @bt-generated begin
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			/datum/bt_node/subtree/escape_captivity,\
			/datum/bt_node/subtree/simple_ability_combat\
		)\
	)
	// @bt-generated end

/datum/ai_controller/basic_controller/simple/simple_ability_retaliate
	behavior_tree_json = "simple_ability_retaliate.bt.json"
	behavior_nodes = BT_SELECTOR(\
		BT_SUBTREE(/datum/bt_node/subtree/escape_captivity),\
		BT_SUBTREE(/datum/bt_node/subtree/simple_ability_retaliate_combat),\
	)

/// Use an ability on target on cooldown, then try to punch them
/datum/ai_controller/basic_controller/simple/simple_ability_melee
	behavior_tree_json = "simple_ability_melee.bt.json"
	behavior_nodes = BT_SELECTOR(\
		BT_SUBTREE(/datum/bt_node/subtree/escape_captivity),\
		BT_SUBTREE(/datum/bt_node/subtree/simple_ability_melee_combat),\
	)

/// Use an ability on target on cooldown, then try to shoot them
/datum/ai_controller/basic_controller/simple/simple_ability_ranged
	behavior_tree_json = "simple_ability_ranged.bt.json"
	behavior_nodes = BT_SELECTOR(\
		BT_SUBTREE(/datum/bt_node/subtree/escape_captivity),\
		BT_SUBTREE(/datum/bt_node/subtree/simple_ability_ranged_combat),\
	)

/// Fight back if attacked
/datum/ai_controller/basic_controller/simple/simple_retaliate
	behavior_tree_json = "simple_retaliate.bt.json"
	ai_traits = DEFAULT_AI_FLAGS | STOP_MOVING_WHEN_PULLED
	behavior_nodes = BT_SELECTOR(\
		BT_SUBTREE(/datum/bt_node/subtree/escape_captivity),\
		BT_SUBTREE(/datum/bt_node/subtree/simple_retaliate_combat),\
	)

/// Get pissed at random people for no reason
/datum/ai_controller/basic_controller/simple/simple_capricious
	behavior_tree_json = "simple_capricious.bt.json"
	ai_traits = DEFAULT_AI_FLAGS | STOP_MOVING_WHEN_PULLED
	behavior_nodes = BT_SELECTOR(\
		BT_SUBTREE(/datum/bt_node/subtree/escape_captivity),\
		BT_SUBTREE(/datum/bt_node/subtree/simple_capricious_combat),\
	)

/// Runs away from anyone it sees
/datum/ai_controller/basic_controller/simple/simple_fearful
	behavior_tree_json = "simple_fearful.bt.json"
	ai_traits = PASSIVE_AI_FLAGS
	behavior_nodes = BT_SELECTOR(\
		BT_SUBTREE(/datum/bt_node/subtree/simple_fearful_combat),\
	)

/// Runs away when attacked
/datum/ai_controller/basic_controller/simple/simple_skittish
	behavior_tree_json = "simple_skittish.bt.json"
	ai_traits = PASSIVE_AI_FLAGS
	behavior_nodes = BT_SELECTOR(\
		BT_SUBTREE(/datum/bt_node/subtree/simple_skittish_combat),\
	)

/// Does what it is told and protects da boss
/// TODO: port pet command system to BT so pet_planning functions correctly
/datum/ai_controller/basic_controller/simple/simple_goon
	behavior_tree_json = "simple_goon.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)

	behavior_nodes = BT_SELECTOR(\
		BT_SUBTREE(/datum/bt_node/subtree/escape_captivity),\
		BT_LEAF(/datum/bt_node/ai_behavior/pet_planning),\
	)

/// Literally does nothing except random speech
/datum/ai_controller/basic_controller/talk
	behavior_tree_json = "talk.bt.json"
	idle_behavior = null
	behavior_nodes = BT_SELECTOR(\
		BT_LEAF(/datum/bt_node/ai_behavior/random_speech_blackboard)\
	)
