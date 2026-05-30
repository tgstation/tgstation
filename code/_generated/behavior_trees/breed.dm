/datum/bt_node/subtree/pet_command/breed
	behavior_nodes = list(\
		"__t" = /datum/bt_node/decorator/bb_key_set,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/composite/sequence,\
				"__c" = list(\
					list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_CURRENT_PET_TARGET, 1, FALSE)),\
					list("__t" = /datum/bt_node/ai_behavior/ai_interact, "default_behavior_args" = list(BB_CURRENT_PET_TARGET, FALSE)),\
					list("__t" = /datum/bt_node/ai_behavior/clear_pet_command, "default_behavior_args" = list())\
				)\
			)\
		),\
		"key" = BB_CURRENT_PET_TARGET,\
		"observer_abort" = BT_ABORT_BOTH\
	)
