/datum/ai_controller/basic_controller/simple/simple_retaliate
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			/datum/bt_node/subtree/escape_captivity,\
			/datum/bt_node/subtree/simple_retaliate_combat\
		)\
	)
