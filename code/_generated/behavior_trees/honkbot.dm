/datum/ai_controller/basic_controller/bot/honkbot
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
					/datum/bt_node/subtree/escape_captivity/pacifist,\
					/datum/bt_node/subtree/bot_respond_to_summon,\
					list(\
						"__t" = /datum/bt_node/composite/selector,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/decorator/bb_key_set,\
								"__c" = list(\
									list(\
										"__t" = /datum/bt_node/decorator/secbot_target_valid,\
										"__c" = list(\
											list(\
												"__t" = /datum/bt_node/composite/sequence,\
												"__c" = list(\
													list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, 1, TRUE, /datum/ai_movement/basic_avoidance)),\
													list("__t" = /datum/bt_node/ai_behavior/basic_melee_attack/interact_once/bot, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)),\
													list("__t" = /datum/bt_node/ai_behavior/basic_melee_attack/interact_once/bot, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION))\
												)\
											)\
										)\
									)\
								),\
								"observer_abort" = BT_ABORT_BOTH,\
								"key" = BB_BASIC_MOB_CURRENT_TARGET\
							),\
							list(\
								"__t" = /datum/bt_node/decorator/bb_key_set,\
								"__c" = list(\
									/datum/bt_node/subtree/honkbot_slip\
								),\
								"observer_abort" = BT_ABORT_BOTH,\
								"key" = BB_SLIPPERY_TARGET\
							),\
							list(\
								"__t" = /datum/bt_node/decorator/bb_key_set,\
								"__c" = list(\
									list(\
										"__t" = /datum/bt_node/composite/sequence,\
										"__c" = list(\
											list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_CLOWN_FRIEND, 1, TRUE, /datum/ai_movement/basic_avoidance)),\
											list("__t" = /datum/bt_node/ai_behavior/play_with_clown, "default_behavior_args" = list(BB_CLOWN_FRIEND))\
										)\
									)\
								),\
								"observer_abort" = BT_ABORT_BOTH,\
								"key" = BB_CLOWN_FRIEND\
							),\
							list(\
								"__t" = /datum/bt_node/composite/parallel,\
								"failure_policy" = BT_PARALLEL_FAILURE_CHILD_ONE,\
								"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,\
								"repeat_secondary" = TRUE,\
								"finish_on_primary" = TRUE,\
								"__c" = list(\
									/datum/bt_node/subtree/bot_patrol,\
									list(\
										"__t" = /datum/bt_node/composite/selector,\
										"__c" = list(\
											list("__t" = /datum/bt_node/ai_behavior/find_potential_targets, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)),\
											list(\
												"__t" = /datum/bt_node/composite/sequence,\
												"__c" = list(\
													list("__t" = /datum/bt_node/ai_behavior/find_slippery_item, "default_behavior_args" = list(BB_SLIPPERY_TARGET)),\
													list("__t" = /datum/bt_node/ai_behavior/bot_search/find_slip_victim, "default_behavior_args" = list(BB_SLIP_TARGET))\
												)\
											),\
											list("__t" = /datum/bt_node/ai_behavior/find_clown_friend, "default_behavior_args" = list(BB_CLOWN_FRIEND))\
										)\
									)\
								)\
							)\
						)\
					)\
				)\
			)\
		)\
	)
