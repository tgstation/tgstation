/datum/bt_node/subtree/pet_command/targeted_ability
	behavior_nodes = list(\
		"__t" = /datum/bt_node/decorator/bb_key_set,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/composite/parallel,\
				"failure_policy" = BT_PARALLEL_FAILURE_CHILD_ONE,\
				"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,\
				"repeat_secondary" = TRUE,\
				"finish_on_primary" = TRUE,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/subplan,\
						"success_policy" = BT_SUBPLAN_LOOP_ON_SUCCESS,\
						"failure_policy" = BT_SUBPLAN_LOOP_ON_FAILURE,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/composite/sequence,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/targeted_mob_ability, "default_behavior_args" = list(BB_TARGETED_ACTION, BB_CURRENT_PET_TARGET)),\
									list("__t" = /datum/bt_node/ai_behavior/clear_pet_command, "default_behavior_args" = list())\
								)\
							)\
						)\
					),\
					list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_CURRENT_PET_TARGET, 1, FALSE))\
				)\
			)\
		),\
		"key" = BB_CURRENT_PET_TARGET,\
		"observer_abort" = BT_ABORT_BOTH\
	)
