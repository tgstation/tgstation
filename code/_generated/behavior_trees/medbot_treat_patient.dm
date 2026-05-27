/datum/bt_node/subtree/medbot_treat_patient
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/parallel,\
		"failure_policy" = BT_PARALLEL_FAILURE_CHILD_ONE,\
		"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,\
		"repeat_secondary" = TRUE,\
		"finish_on_primary" = TRUE,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/composite/sequence,\
				"__c" = list(\
					list("__t" = /datum/bt_node/ai_behavior/announce_patient, "default_behavior_args" = list(BB_CURRENT_TARGET)),\
					list("__t" = /datum/bt_node/ai_behavior/tend_to_patient, "default_behavior_args" = list(BB_CURRENT_TARGET))\
				)\
			),\
			list("__t" = /datum/bt_node/ai_behavior/find_suitable_patient, "default_behavior_args" = list(BB_CURRENT_TARGET))\
		)\
	)
