/datum/ai_controller/basic_controller/pet_cult
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			/datum/bt_node/subtree/escape_captivity,\
			list("__t" = /datum/bt_node/subtree/fail, "override_id" = SUBPLAN_ID_PET_COMMAND),\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_set,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/sequence,\
						"__c" = list(\
							list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_FRIENDLY_CULTIST, 1, FALSE)),\
							list("__t" = /datum/bt_node/ai_behavior/befriend_target, "default_behavior_args" = list(BB_FRIENDLY_CULTIST, BB_FRIENDLY_MESSAGE))\
						)\
					)\
				),\
				"key" = BB_FRIENDLY_CULTIST,\
				"observer_abort" = BT_ABORT_BOTH\
			),\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_set,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/sequence,\
						"__c" = list(\
							list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_OCCUPIED_RUNE, 1, FALSE)),\
							list("__t" = /datum/bt_node/ai_behavior/activate_rune, "default_behavior_args" = list())\
						)\
					)\
				),\
				"key" = BB_OCCUPIED_RUNE,\
				"observer_abort" = BT_ABORT_BOTH\
			),\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_set,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/sequence,\
						"__c" = list(\
							list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_DEAD_CULTIST, 1, FALSE)),\
							list("__t" = /datum/bt_node/ai_behavior/drag_target, "default_behavior_args" = list(BB_DEAD_CULTIST)),\
							list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_NEARBY_RUNE, 0, FALSE)),\
							list("__t" = /datum/bt_node/ai_behavior/clear_key, "default_behavior_args" = list(BB_DEAD_CULTIST))\
						)\
					)\
				),\
				"key" = BB_DEAD_CULTIST,\
				"observer_abort" = BT_ABORT_BOTH\
			),\
			list(\
				"__t" = /datum/bt_node/composite/parallel,\
				"failure_policy" = BT_PARALLEL_FAILURE_CHILD_ONE,\
				"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,\
				"repeat_secondary" = TRUE,\
				"repeat_secondary_delay" = BASIC_MOB_FIND_ENEMY_RATE,\
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
													list("__t" = /datum/bt_node/ai_behavior/basic_melee_attack, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION))\
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
					list(\
						"__t" = /datum/bt_node/composite/selector,\
						"__c" = list(\
							list("__t" = /datum/bt_node/ai_behavior/update_targets, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)),\
							list("__t" = /datum/bt_node/ai_behavior/find_friendly_cultist, "default_behavior_args" = list()),\
							list("__t" = /datum/bt_node/ai_behavior/find_occupied_rune, "default_behavior_args" = list()),\
							list("__t" = /datum/bt_node/ai_behavior/find_dead_cultist, "default_behavior_args" = list())\
						)\
					)\
				)\
			)\
		)\
	)
