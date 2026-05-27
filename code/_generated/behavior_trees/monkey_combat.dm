/datum/bt_node/subtree/monkey_combat
	behavior_nodes = list(\
		"__t" = /datum/bt_node/decorator/bb_key_set,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/composite/selector,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/decorator/pawn_health_below,\
						"__c" = list(\
							list("__t" = /datum/bt_node/ai_behavior/run_away_from_target, "default_behavior_args" = list("BB_monkey_current_attack_target"))\
						),\
						"health_threshold" = 40\
					),\
					/datum/bt_node/subtree/monkey_find_weapon,\
					list(\
						"__t" = /datum/bt_node/decorator/cooldown,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/composite/sequence,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/recruit_monkeys, "default_behavior_args" = list("BB_monkey_current_attack_target"))\
								)\
							)\
						),\
						"cooldown_key" = "BB_monkey_recruit_cooldown",\
						"cooldown_duration" = 60\
					),\
					list(\
						"__t" = /datum/bt_node/decorator/mob_stat_at_least,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/composite/sequence,\
								"__c" = list(\
									list(\
										"__t" = /datum/bt_node/decorator/bb_key_set,\
										"__c" = list(\
											list("__t" = /datum/bt_node/ai_behavior/find_and_set, "default_behavior_args" = list("BB_monkey_target_disposal", /obj/machinery/disposal, 9))\
										),\
										"key" = "BB_monkey_target_disposal",\
										"invert" = TRUE\
									),\
									list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list("BB_monkey_current_attack_target", 1, TRUE)),\
									list("__t" = /datum/bt_node/ai_behavior/grab_target, "default_behavior_args" = list("BB_monkey_current_attack_target")),\
									list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list("BB_monkey_target_disposal", 1, TRUE)),\
									list("__t" = /datum/bt_node/ai_behavior/stuff_in_disposal, "default_behavior_args" = list("BB_monkey_current_attack_target", "BB_monkey_target_disposal"))\
								)\
							)\
						),\
						"observer_abort" = BT_ABORT_LOWER_PRIORITY,\
						"invert" = FALSE,\
						"key" = "BB_monkey_current_attack_target",\
						"min_stat" = UNCONSCIOUS\
					),\
					list(\
						"__t" = /datum/bt_node/composite/parallel,\
						"failure_policy" = BT_PARALLEL_FAILURE_CHILD_ONE,\
						"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,\
						"repeat_secondary" = TRUE,\
						"finish_on_primary" = TRUE,\
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
											list("__t" = /datum/bt_node/ai_behavior/monkey_attack_mob, "default_behavior_args" = list("BB_monkey_current_attack_target"))\
										)\
									),\
									list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list("BB_monkey_current_attack_target", 1, TRUE))\
								)\
							),\
							list(\
								"__t" = /datum/bt_node/decorator/cooldown,\
								"__c" = list(\
									list(\
										"__t" = /datum/bt_node/decorator/random_chance,\
										"__c" = list(\
											list("__t" = /datum/bt_node/ai_behavior/battle_screech/monkey, "default_behavior_args" = list())\
										),\
										"chance" = 0.25\
									)\
								),\
								"cooldown_key" = BB_BATTLE_SCREECH_COOLDOWN,\
								"cooldown_duration" = 5\
							)\
						)\
					)\
				)\
			)\
		),\
		"key" = "BB_monkey_current_attack_target",\
		"observer_abort" = BT_ABORT_LOWER_PRIORITY\
	)
