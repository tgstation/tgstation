/datum/bt_node/subtree/simple_ability_melee_combat
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/parallel,\
		"failure_policy" = BT_PARALLEL_FAILURE_CHILD_ONE,\
		"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,\
		"repeat_secondary" = TRUE,\
		"finish_on_primary" = TRUE,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/composite/selector,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/decorator/bb_key_set,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/composite/parallel,\
								"failure_policy" = BT_PARALLEL_FAILURE_ANY,\
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
												"__t" = /datum/bt_node/composite/selector,\
												"__c" = list(\
													list("__t" = /datum/bt_node/ai_behavior/attack_obstructions, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET)),\
													list("__t" = /datum/bt_node/ai_behavior/targeted_mob_ability, "default_behavior_args" = list(BB_TARGETED_ACTION, BB_BASIC_MOB_CURRENT_TARGET)),\
													list("__t" = /datum/bt_node/ai_behavior/basic_melee_attack, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION))\
												)\
											)\
										)\
									),\
									list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, 1, FALSE))\
								)\
							)\
						),\
						"observer_abort" = BT_ABORT_BOTH,\
						"key" = BB_BASIC_MOB_CURRENT_TARGET\
					),\
					list(\
						"__t" = /datum/bt_node/composite/subplan,\
						"success_policy" = BT_SUBPLAN_LOOP_ON_SUCCESS,\
						"failure_policy" = BT_SUBPLAN_FAIL_ON_FAILURE,\
						"__c" = list(\
							list("__t" = /datum/bt_node/ai_behavior/idle_random_walk, "default_behavior_args" = list())\
						)\
					)\
				)\
			),\
			list("__t" = /datum/bt_node/ai_behavior/update_targets, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION))\
		)\
	)
