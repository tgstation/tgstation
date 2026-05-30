/datum/bt_node/subtree/pet_command/play_dead
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/sequence,\
		"__c" = list(\
			list("__t" = /datum/bt_node/ai_behavior/play_dead, "default_behavior_args" = list()),\
			list("__t" = /datum/bt_node/ai_behavior/clear_pet_command, "default_behavior_args" = list())\
		)\
	)
