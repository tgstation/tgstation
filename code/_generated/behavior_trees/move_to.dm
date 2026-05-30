/datum/bt_node/subtree/pet_command/move_to
	behavior_nodes = list(\
		"__t" = /datum/bt_node/decorator/bb_key_set,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/composite/sequence,\
				"__c" = list(\
					list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_CURRENT_PET_TARGET, 0, TRUE)),\
					list("__t" = /datum/bt_node/ai_behavior/clear_pet_command, "default_behavior_args" = list())\
				)\
			)\
		),\
		"key" = BB_CURRENT_PET_TARGET,\
		"observer_abort" = BT_ABORT_BOTH\
	)
