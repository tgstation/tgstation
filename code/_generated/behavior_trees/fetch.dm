/datum/bt_node/subtree/pet_command/fetch
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/composite/sequence,\
				"__c" = list(\
					list("__t" = /datum/bt_node/ai_behavior/forget_failed_fetches, "default_behavior_args" = list()),\
					list(\
						"__t" = /datum/bt_node/decorator/bb_key_set,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/composite/sequence,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_CURRENT_PET_TARGET, 1, FALSE)),\
									list("__t" = /datum/bt_node/ai_behavior/fetch_seek, "default_behavior_args" = list(BB_CURRENT_PET_TARGET)),\
									list("__t" = /datum/bt_node/ai_behavior/pick_up_item_virtual, "default_behavior_args" = list(BB_CURRENT_PET_TARGET, BB_SIMPLE_CARRY_ITEM))\
								)\
							)\
						),\
						"key" = BB_CURRENT_PET_TARGET,\
						"observer_abort" = BT_ABORT_BOTH\
					)\
				)\
			),\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_set,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/decorator/bb_key_set,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/composite/sequence,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_FETCH_DELIVER_TO, 1, FALSE)),\
									list("__t" = /datum/bt_node/ai_behavior/pass_item_virtual, "default_behavior_args" = list(BB_FETCH_DELIVER_TO, BB_SIMPLE_CARRY_ITEM)),\
									list("__t" = /datum/bt_node/ai_behavior/clear_pet_command, "default_behavior_args" = list())\
								)\
							)\
						),\
						"key" = BB_FETCH_DELIVER_TO,\
						"observer_abort" = BT_ABORT_BOTH\
					)\
				),\
				"key" = BB_SIMPLE_CARRY_ITEM,\
				"observer_abort" = BT_ABORT_BOTH\
			),\
			list("__t" = /datum/bt_node/ai_behavior/clear_pet_command, "default_behavior_args" = list())\
		)\
	)
