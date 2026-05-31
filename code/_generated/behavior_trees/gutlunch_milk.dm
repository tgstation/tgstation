/datum/ai_controller/basic_controller/gutlunch/gutlunch_milk
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			/datum/bt_node/subtree/escape_captivity/pacifist,\
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
									list("__t" = /datum/bt_node/ai_behavior/run_away_from_target, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION))\
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
					list("__t" = /datum/bt_node/ai_behavior/target_from_retaliate_list, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION, FALSE))\
				)\
			)\
		)\
	)
