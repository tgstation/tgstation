/datum/ai_controller/basic_controller/bot/repairbot
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/parallel,\
		"failure_policy" = BT_PARALLEL_FAILURE_CHILD_ONE,\
		"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,\
		"repeat_secondary" = TRUE,\
		"finish_on_primary" = TRUE,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/composite/selector,\
				"__c" = list(\
					/datum/bt_node/subtree/escape_captivity/pacifist,\
					list(\
						"__t" = /datum/bt_node/composite/parallel,\
						"failure_policy" = BT_PARALLEL_FAILURE_CHILD_ONE,\
						"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,\
						"repeat_secondary" = TRUE,\
						"finish_on_primary" = TRUE,\
						"__c" = list(\
							/datum/bt_node/subtree/repairbot_repair_target,\
							/datum/bt_node/subtree/repairbot_find_target\
						)\
					)\
				)\
			)\
		)\
	)
