/// Basetype with normal parameters
/datum/ai_controller/basic_controller/simple
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

/// Find a target, walk at target, attack intervening obstacles
/datum/ai_controller/basic_controller/simple/simple_hostile_obstacles
	behavior_nodes = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Find a target, walk at target, attack intervening obstacles
/datum/ai_controller/basic_controller/simple/simple_ranged
	behavior_nodes = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/ranged_skirmish,
	)

/datum/ai_controller/basic_controller/simple/simple_ranged_retaliate
	behavior_nodes = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/ranged_skirmish,
	)

/// Find a target, walk towards it AND shoot it
/datum/ai_controller/basic_controller/simple/simple_skirmisher
	behavior_nodes = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/ranged_skirmish,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Use an ability on target on cooldown
/datum/ai_controller/basic_controller/simple/simple_ability
	behavior_nodes = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/targeted_mob_ability,
	)

/datum/ai_controller/basic_controller/simple/simple_ability_retaliate
	behavior_nodes = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/targeted_mob_ability,
	)

/// Use an ability on target on cooldown, then try to punch them
/datum/ai_controller/basic_controller/simple/simple_ability_melee
	behavior_nodes = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

// =============================================================================
// BT equivalents of simple_hostile
// =============================================================================

/**
 * Selector: tries melee first (gated on having a target), falls back to find_potential_targets
 * only when no target is set. The bb_key_set decorator aborts the attack branch reactively when
 * the target is cleared so the selector can immediately fall through to target-finding.
 *
 * The attack branch runs as a BT_PARALLEL: basic_melee_attack/basic_melee (A) handles attacking when
 * adjacent; move_to_target (B) drives locomotion independently each tick. Both behaviors run
 * every process() cycle — process() no longer returns after the first behavior.
 */
/datum/bt_node/subtree/simple_hostile_combat
	behavior_nodes = BT_SELECTOR(\
						BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
							BT_PARALLEL(BT_PARALLEL_FAILURE_ONE,\
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
	behavior_nodes = BT_SELECTOR(\
		BT_SUBTREE(/datum/bt_node/subtree/escape_captivity),\
		BT_SUBTREE(/datum/bt_node/subtree/simple_hostile_combat),\
	)

/// Use an ability on target on cooldown, then try to shoot them
/datum/ai_controller/basic_controller/simple/simple_ability_ranged
	behavior_nodes = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/targeted_mob_ability,
		/datum/ai_planning_subtree/ranged_skirmish,
	)

/// Fight back if attacked
/datum/ai_controller/basic_controller/simple/simple_retaliate
	ai_traits = DEFAULT_AI_FLAGS | STOP_MOVING_WHEN_PULLED
	behavior_nodes = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Get pissed at random people for no reason
/datum/ai_controller/basic_controller/simple/simple_capricious
	ai_traits = DEFAULT_AI_FLAGS | STOP_MOVING_WHEN_PULLED
	behavior_nodes = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/capricious_retaliate,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Runs away from anyone it sees
/datum/ai_controller/basic_controller/simple/simple_fearful
	ai_traits = PASSIVE_AI_FLAGS
	behavior_nodes = list(
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		/datum/ai_planning_subtree/flee_target,
	)

/// Runs away when attacked
/datum/ai_controller/basic_controller/simple/simple_skittish
	ai_traits = PASSIVE_AI_FLAGS
	behavior_nodes = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
	)

/// Does what it is told and protects da boss
/datum/ai_controller/basic_controller/simple/simple_goon
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)

	behavior_nodes = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/pet_planning,
	)

/// Literally does nothing except random speedh
/datum/ai_controller/basic_controller/talk
	idle_behavior = null
	behavior_nodes = list(
		/datum/ai_planning_subtree/random_speech/blackboard,
	)
