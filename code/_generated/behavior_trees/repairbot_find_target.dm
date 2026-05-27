/datum/bt_node/subtree/repairbot_find_target
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/decorator/bot_is_emagged,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/selector,\
						"__c" = list(\
							list("__t" = /datum/bt_node/ai_behavior/bot_search/valid_robot, "default_behavior_args" = list(BB_ROBOT_TARGET)),\
							list("__t" = /datum/bt_node/ai_behavior/bot_search/deconstructable, "default_behavior_args" = list(BB_DECONSTRUCT_TARGET))\
						)\
					)\
				),\
				"invert" = FALSE\
			),\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_set,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/selector,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/composite/sequence,\
								"__c" = list(\
									list(\
										"__t" = /datum/bt_node/composite/selector,\
										"__c" = list(\
											list("__t" = /datum/bt_node/ai_behavior/bot_search/valid_plateless_turf/breached, "default_behavior_args" = list(BB_CURRENT_TARGET)),\
											list("__t" = /datum/bt_node/ai_behavior/bot_search/refillable_target, "default_behavior_args" = list(BB_CURRENT_TARGET)),\
											list("__t" = /datum/bt_node/ai_behavior/bot_search/valid_grille_target, "default_behavior_args" = list(BB_CURRENT_TARGET)),\
											list("__t" = /datum/bt_node/ai_behavior/bot_search/valid_plateless_turf, "default_behavior_args" = list(BB_CURRENT_TARGET)),\
											list("__t" = /datum/bt_node/ai_behavior/bot_search/valid_window_fix, "default_behavior_args" = list(BB_CURRENT_TARGET)),\
											list("__t" = /datum/bt_node/ai_behavior/bot_search/valid_girder, "default_behavior_args" = list(BB_CURRENT_TARGET))\
										)\
									),\
									list("__t" = /datum/bt_node/ai_behavior/set_bb_key, "default_behavior_args" = list(BB_REPAIRBOT_INTERACTION_TYPE, REPAIRBOT_INTERACTION_INTERACT)),\
									list("__t" = /datum/bt_node/ai_behavior/cancel_current_plan, "default_behavior_args" = list())\
								)\
							),\
							list(\
								"__t" = /datum/bt_node/composite/sequence,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/bot_search/valid_wall_target, "default_behavior_args" = list(BB_CURRENT_TARGET)),\
									list("__t" = /datum/bt_node/ai_behavior/set_bb_key, "default_behavior_args" = list(BB_REPAIRBOT_INTERACTION_TYPE, REPAIRBOT_INTERACTION_BUILD_GIRDERS)),\
									list("__t" = /datum/bt_node/ai_behavior/cancel_current_plan, "default_behavior_args" = list())\
								)\
							)\
						)\
					)\
				),\
				"observer_abort" = BT_ABORT_NONE,\
				"invert" = TRUE,\
				"key" = BB_CURRENT_TARGET\
			)\
		)\
	)
