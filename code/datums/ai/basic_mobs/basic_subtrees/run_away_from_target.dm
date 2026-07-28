/// Flee from BB_CURRENT_TARGET, gated by BB_BASIC_MOB_STOP_FLEEING.
/// Computes a flee waypoint each loop via find_flee_location then moves to it.
/datum/bt_node/subtree/run_away_from_target
	behavior_tree_json = "code/datums/ai/basic_mobs/basic_subtrees/run_away_from_target.bt.json"

/// Flee variant that fires ranged attacks at the current target while moving.
/datum/bt_node/subtree/run_away_from_target/run_and_shoot
	behavior_tree_json = "code/datums/ai/basic_mobs/basic_subtrees/run_away_from_target_run_and_shoot.bt.json"
