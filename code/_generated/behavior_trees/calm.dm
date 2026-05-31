/datum/ai_controller/basic_controller/lobstrosity/juvenile/calm
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			/datum/bt_node/subtree/escape_captivity/pacifist,\
			list("__t" = /datum/bt_node/subtree/fail, "override_id" = SUBPLAN_ID_PET_COMMAND),\
			/datum/bt_node/subtree/simple_retaliate_combat\
		)\
	)
