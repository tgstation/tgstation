/datum/bt_node/subtree/repairbot_repair_target
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/decorator/bot_is_emagged,\
				"__c" = list(\
					/datum/bt_node/subtree/repairbot_emagged\
				),\
				"observer_abort" = BT_ABORT_BOTH\
			),\
			list(\
				"__t" = /datum/bt_node/decorator/bot_is_emagged,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/decorator/bb_key_set,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/composite/sequence,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_CURRENT_TARGET, 1, TRUE, /datum/ai_movement/basic_avoidance)),\
									list(\
										"__t" = /datum/bt_node/composite/selector,\
										"__c" = list(\
											list(\
												"__t" = /datum/bt_node/decorator/bb_key_equals,\
												"__c" = list(\
													list("__t" = /datum/bt_node/ai_behavior/bot_interact, "default_behavior_args" = list(BB_CURRENT_TARGET))\
												),\
												"key" = BB_REPAIRBOT_INTERACTION_TYPE,\
												"value" = REPAIRBOT_INTERACTION_INTERACT\
											),\
											list(\
												"__t" = /datum/bt_node/decorator/bb_key_equals,\
												"__c" = list(\
													list("__t" = /datum/bt_node/ai_behavior/targeted_mob_ability/build_girder, "default_behavior_args" = list(BB_GIRDER_BUILD_ABILITY, BB_CURRENT_TARGET))\
												),\
												"key" = BB_REPAIRBOT_INTERACTION_TYPE,\
												"value" = REPAIRBOT_INTERACTION_BUILD_GIRDERS\
											)\
										)\
									)\
								)\
							)\
						),\
						"key" = BB_CURRENT_TARGET\
					)\
				),\
				"observer_abort" = BT_ABORT_SELF,\
				"invert" = TRUE\
			),\
			/datum/bt_node/subtree/bot_salute_authority,\
			/datum/bt_node/subtree/bot_patrol\
		)\
	)
