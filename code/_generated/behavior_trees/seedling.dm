/datum/ai_controller/basic_controller/seedling
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			/datum/bt_node/subtree/escape_captivity/pacifist,\
			list("__t" = /datum/bt_node/subtree/fail, "override_id" = SUBPLAN_ID_PET_COMMAND),\
			list(\
				"__t" = /datum/bt_node/composite/subplan,\
				"success_policy" = BT_SUBPLAN_LOOP_ON_SUCCESS,\
				"failure_policy" = BT_SUBPLAN_FAIL_ON_FAILURE,\
				"__c" = list(\
					list("__t" = /datum/bt_node/ai_behavior/idle_random_walk, "default_behavior_args" = list())\
				)\
			)\
		)\
	)
