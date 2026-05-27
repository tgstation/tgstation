/datum/bt_node/subtree/simple_fearful_combat
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_set,\
				"__c" = list(\
					list("__t" = /datum/bt_node/ai_behavior/run_away_from_target, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION))\
				),\
				"key" = BB_BASIC_MOB_CURRENT_TARGET,\
				"observer_abort" = BT_ABORT_SELF\
			),\
			list("__t" = /datum/bt_node/ai_behavior/find_potential_targets/nearest, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION))\
		)\
	)
