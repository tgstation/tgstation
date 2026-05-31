/datum/ai_controller/basic_controller/gutlunch/gutlunch_warrior
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			/datum/bt_node/subtree/escape_captivity,\
			list("__t" = /datum/bt_node/subtree/fail, "override_id" = SUBPLAN_ID_PET_COMMAND),\
			list("__t" = /datum/bt_node/ai_behavior/befriend_ashwalkers, "default_behavior_args" = list()),\
			/datum/bt_node/subtree/simple_retaliate_combat\
		)\
	)
