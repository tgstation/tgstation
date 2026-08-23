///Tries to escape activity, has observers to cancel if needed
/datum/bt_node/subtree/escape_captivity
	behavior_tree_json = "code/datums/ai/basic_mobs/basic_subtrees/escape_captivity.bt.json"

/// Pacifist variant: never attacks objects, only resists.
/datum/bt_node/subtree/escape_captivity/pacifist
	behavior_tree_json = "code/datums/ai/basic_mobs/basic_subtrees/escape_captivity_pacifist.bt.json"
