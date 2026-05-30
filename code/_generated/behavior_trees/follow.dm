/datum/bt_node/subtree/pet_command/follow
	behavior_nodes = list(\
		"__t" = /datum/bt_node/decorator/bb_key_set,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/composite/subplan,\
				"success_policy" = BT_SUBPLAN_LOOP_ON_SUCCESS,\
				"failure_policy" = BT_SUBPLAN_FAIL_ON_FAILURE,\
				"__c" = list(\
					list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_CURRENT_PET_TARGET, 0, TRUE))\
				)\
			)\
		),\
		"key" = BB_CURRENT_PET_TARGET,\
		"observer_abort" = BT_ABORT_BOTH\
	)
