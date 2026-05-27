/datum/bt_node/subtree/simple_ability_retaliate_combat
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_set,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/sequence,\
						"__c" = list(\
							list("__t" = /datum/bt_node/ai_behavior/target_from_retaliate_list, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)),\
							list(\
								"__t" = /datum/bt_node/composite/parallel,\
								"failure_policy" = BT_PARALLEL_FAILURE_ANY,\
								"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,\
								"repeat_secondary" = FALSE,\
								"finish_on_primary" = FALSE,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/targeted_mob_ability, "default_behavior_args" = list(BB_TARGETED_ACTION, BB_BASIC_MOB_CURRENT_TARGET)),\
									list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, 3, FALSE))\
								)\
							)\
						)\
					)\
				),\
				"key" = BB_BASIC_MOB_RETALIATE_LIST,\
				"observer_abort" = BT_ABORT_LOWER_PRIORITY\
			)\
		)\
	)
