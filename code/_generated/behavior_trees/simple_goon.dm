/datum/ai_controller/basic_controller/simple/simple_goon
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			/datum/bt_node/subtree/escape_captivity,\
			list("__t" = /datum/bt_node/ai_behavior/pet_planning, "default_behavior_args" = list())\
		)\
	)
