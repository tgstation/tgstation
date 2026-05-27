/datum/bt_node/subtree/simple_skirmisher_combat
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_set,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/parallel,\
						"failure_policy" = BT_PARALLEL_FAILURE_ANY,\
						"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,\
						"repeat_secondary" = FALSE,\
						"finish_on_primary" = FALSE,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/composite/selector,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/attack_obstructions, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET)),\
									list("__t" = /datum/bt_node/ai_behavior/basic_melee_attack, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)),\
									list("__t" = /datum/bt_node/ai_behavior/basic_ranged_attack, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION))\
								)\
							),\
							list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, 1, FALSE))\
						)\
					)\
				),\
				"key" = BB_BASIC_MOB_CURRENT_TARGET,\
				"observer_abort" = BT_ABORT_SELF\
			),\
			list("__t" = /datum/bt_node/ai_behavior/find_potential_targets, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION))\
		)\
	)
