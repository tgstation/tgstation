/datum/ai_controller/basic_controller/bot/firebot
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
													list("__t" = /datum/bt_node/ai_behavior/announce_fire_detected, "default_behavior_args" = list()),\
													list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_CURRENT_TARGET, 1, TRUE, /datum/ai_movement/basic_avoidance)),\
													list("__t" = /datum/bt_node/ai_behavior/bot_interact/extinguish, "default_behavior_args" = list(BB_CURRENT_TARGET))\
												)\
											)\
										),\
										"observer_abort" = BT_ABORT_BOTH,\
										"key" = BB_CURRENT_TARGET\
									),\
									/datum/bt_node/subtree/bot_patrol\
								)\
							),\
							list(\
								"__t" = /datum/bt_node/decorator/bb_key_set,\
								"__c" = list(\
									list(\
										"__t" = /datum/bt_node/composite/selector,\
										"__c" = list(\
											list("__t" = /datum/bt_node/ai_behavior/find_person_on_fire, "default_behavior_args" = list(BB_CURRENT_TARGET)),\
											list("__t" = /datum/bt_node/ai_behavior/search_burning_turfs, "default_behavior_args" = list(BB_CURRENT_TARGET))\
										)\
									)\
								),\
								"invert" = TRUE,\
								"key" = BB_CURRENT_TARGET\
							)\
						)\
					)\
				)\
			),\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_set,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/selector,\
						"__c" = list(\
							list("__t" = /datum/bt_node/ai_behavior/handle_firebot_speech, "default_behavior_args" = list()),\
							/datum/bt_node/subtree/bot_salute_authority\
						)\
					)\
				),\
				"invert" = TRUE,\
				"key" = BB_CURRENT_TARGET\
			)\
		)\
	)
