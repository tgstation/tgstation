/datum/bt_node/subtree/pet_command/untargeted_ability
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/sequence,\
		"__c" = list(\
			list("__t" = /datum/bt_node/ai_behavior/use_mob_ability, "default_behavior_args" = list(BB_PET_ACTIVE_ABILITY)),\
			list("__t" = /datum/bt_node/ai_behavior/clear_pet_command, "default_behavior_args" = list())\
		)\
	)
