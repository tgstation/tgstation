/datum/ai_controller/basic_controller/talk
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			list("__t" = /datum/bt_node/ai_behavior/random_speech_blackboard, "default_behavior_args" = list())\
		)\
	)
