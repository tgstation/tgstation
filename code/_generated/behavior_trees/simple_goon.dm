/datum/ai_controller/basic_controller/simple/simple_goon
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			/datum/bt_node/subtree/escape_captivity,\
			list("__t" = /datum/bt_node/subtree/fail, "override_id" = SUBPLAN_ID_PET_COMMAND)\
		)\
	)
