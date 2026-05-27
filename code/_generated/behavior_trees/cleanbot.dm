/datum/ai_controller/basic_controller/bot/cleanbot
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			/datum/bt_node/subtree/escape_captivity/pacifist,\
			/datum/bt_node/subtree/bot_respond_to_summon,\
			list("__t" = /datum/bt_node/ai_behavior/pet_planning, "default_behavior_args" = list()),\
			list(\
				"__t" = /datum/bt_node/decorator/bot_is_emagged,\
				"__c" = list(\
					list(\
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
												"__t" = /datum/bt_node/composite/sequence,\
												"__c" = list(\
													list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_CURRENT_TARGET, 1, TRUE)),\
													list("__t" = /datum/bt_node/ai_behavior/execute_clean, "default_behavior_args" = list(BB_CURRENT_TARGET))\
												)\
											)\
										),\
										"key" = BB_CURRENT_TARGET,\
										"observer_abort" = BT_ABORT_BOTH\
									),\
									list(\
										"__t" = /datum/bt_node/composite/selector,\
										"__c" = list(\
											list(\
												"__t" = /datum/bt_node/decorator/bb_key_set,\
												"__c" = list(\
													list(\
														"__t" = /datum/bt_node/composite/sequence,\
														"__c" = list(\
															list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_FRIENDLY_JANITOR, 1, TRUE, /datum/ai_movement/basic_avoidance)),\
															list("__t" = /datum/bt_node/ai_behavior/befriend_target, "default_behavior_args" = list(BB_FRIENDLY_JANITOR, BB_FRIENDLY_MESSAGE))\
														)\
													)\
												),\
												"observer_abort" = BT_ABORT_BOTH,\
												"key" = BB_FRIENDLY_JANITOR\
											),\
											list(\
												"__t" = /datum/bt_node/decorator/bb_key_set,\
												"__c" = list(\
													list("__t" = /datum/bt_node/ai_behavior/find_friendly_janitor, "default_behavior_args" = list(BB_FRIENDLY_JANITOR))\
												),\
												"key" = BB_FRIENDLY_JANITOR,\
												"invert" = TRUE\
											)\
										)\
									),\
									list(\
										"__t" = /datum/bt_node/decorator/key_off_cooldown,\
										"__c" = list(\
											/datum/bt_node/subtree/bot_patrol\
										),\
										"cooldown_key" = BB_POST_CLEAN_COOLDOWN\
									)\
								)\
							),\
							list(\
								"__t" = /datum/bt_node/composite/selector,\
								"__c" = list(\
									list(\
										"__t" = /datum/bt_node/decorator/bb_key_set,\
										"__c" = list(\
											list("__t" = /datum/bt_node/ai_behavior/find_clean_target, "default_behavior_args" = list(BB_CURRENT_TARGET))\
										),\
										"key" = BB_CURRENT_TARGET,\
										"invert" = TRUE\
									),\
									/datum/bt_node/subtree/bot_salute_authority\
								)\
							)\
						)\
					)\
				),\
				"invert" = TRUE\
			),\
			list(\
				"__t" = /datum/bt_node/decorator/bot_is_emagged,\
				"__c" = list(\
					list(\
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
										"__t" = /datum/bt_node/decorator/key_off_cooldown,\
										"__c" = list(\
											list(\
												"__t" = /datum/bt_node/decorator/bb_key_set,\
												"__c" = list(\
													list(\
														"__t" = /datum/bt_node/composite/sequence,\
														"__c" = list(\
															list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_ACID_SPRAY_TARGET, 0, TRUE, /datum/ai_movement/basic_avoidance)),\
															list("__t" = /datum/bt_node/ai_behavior/execute_clean, "default_behavior_args" = list(BB_ACID_SPRAY_TARGET)),\
															list("__t" = /datum/bt_node/ai_behavior/set_bb_cooldown, "default_behavior_args" = list(BB_ACID_SPRAY_COOLDOWN, 30))\
														)\
													)\
												),\
												"key" = BB_ACID_SPRAY_TARGET,\
												"observer_abort" = BT_ABORT_BOTH\
											)\
										),\
										"cooldown_key" = BB_ACID_SPRAY_COOLDOWN\
									),\
									list("__t" = /datum/bt_node/ai_behavior/use_mob_ability, "default_behavior_args" = list(BB_CLEANBOT_FOAM)),\
									list(\
										"__t" = /datum/bt_node/decorator/key_off_cooldown,\
										"__c" = list(\
											/datum/bt_node/subtree/bot_patrol\
										),\
										"cooldown_key" = BB_POST_CLEAN_COOLDOWN\
									)\
								)\
							),\
							list(\
								"__t" = /datum/bt_node/decorator/bb_key_set,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/find_spray_target, "default_behavior_args" = list(BB_ACID_SPRAY_TARGET))\
								),\
								"key" = BB_ACID_SPRAY_TARGET,\
								"invert" = TRUE\
							)\
						)\
					)\
				)\
			)\
		)\
	)
