/datum/ai_controller/basic_controller/bot/ed209/syndicate
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_UNREACHABLE_LIST_COOLDOWN = 1 MINUTES,
	)
	behavior_tree_json = "ed209_nukie.bt.json"
	behavior_nodes = BT_SELECTOR(\
		BT_SUBTREE(/datum/bt_node/subtree/escape_captivity/pacifist),\
		BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
			BT_PARALLEL(BT_PARALLEL_FAILURE_ANY, BT_PARALLEL_SUCCESS_CHILD_ONE, FALSE, FALSE,\
				BT_LEAF(/datum/bt_node/ai_behavior/basic_ranged_attack,\
					BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
				),\
				BT_LEAF(/datum/bt_node/ai_behavior/move_to_target,\
					BB_BASIC_MOB_CURRENT_TARGET, 1\
				)\
			),\
			"key" = BB_BASIC_MOB_CURRENT_TARGET\
		),\
		BT_LEAF(/datum/bt_node/ai_behavior/find_potential_targets,\
			BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION\
		),\
		BT_SUBTREE(/datum/bt_node/subtree/bot_patrol),\
	)
	reset_keys = list(
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_BOT_SUMMON_TARGET,
	)
