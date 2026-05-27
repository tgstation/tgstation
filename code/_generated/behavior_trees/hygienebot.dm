/datum/ai_controller/basic_controller/bot/hygienebot
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			/datum/bt_node/subtree/escape_captivity/pacifist,\
			/datum/bt_node/subtree/bot_respond_to_summon,\
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
										"__t" = /datum/bt_node/composite/selector,\
										"__c" = list(\
											list(\
												"__t" = /datum/bt_node/decorator/key_off_cooldown,\
												"__c" = list(\
													list(\
														"__t" = /datum/bt_node/composite/sequence,\
														"__c" = list(\
															list("__t" = /datum/bt_node/ai_behavior/commence_trashtalk, "default_behavior_args" = list(BB_WASH_TARGET)),\
															list("__t" = /datum/bt_node/ai_behavior/set_bb_cooldown, "default_behavior_args" = list(BB_TRASH_TALK_COOLDOWN, 4))\
														)\
													)\
												),\
												"cooldown_key" = BB_TRASH_TALK_COOLDOWN\
											),\
											list(\
												"__t" = /datum/bt_node/composite/sequence,\
												"__c" = list(\
													list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_WASH_TARGET, 0, FALSE, /datum/ai_movement/basic_avoidance)),\
													list("__t" = /datum/bt_node/ai_behavior/wash_target, "default_behavior_args" = list(BB_WASH_TARGET))\
												)\
											)\
										)\
									)\
								),\
								"observer_abort" = BT_ABORT_BOTH,\
								"key" = BB_WASH_TARGET\
							),\
							/datum/bt_node/subtree/bot_salute_authority,\
							/datum/bt_node/subtree/bot_patrol\
						)\
					),\
					list("__t" = /datum/bt_node/ai_behavior/find_valid_wash_targets, "default_behavior_args" = list(BB_WASH_TARGET))\
				)\
			)\
		)\
	)
