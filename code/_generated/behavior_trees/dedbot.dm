/datum/ai_controller/basic_controller/bot/dedbot
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			/datum/bt_node/subtree/escape_captivity,\
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
											list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, 1, TRUE, /datum/ai_movement/basic_avoidance)),\
											list("__t" = /datum/bt_node/ai_behavior/targeted_mob_ability/melee, "default_behavior_args" = list(BB_DEDBOT_SLASH, BB_BASIC_MOB_CURRENT_TARGET))\
										)\
									)\
								),\
								"observer_abort" = BT_ABORT_BOTH,\
								"key" = BB_BASIC_MOB_CURRENT_TARGET\
							),\
							/datum/bt_node/subtree/bot_respond_to_summon,\
							/datum/bt_node/subtree/bot_patrol\
						)\
					),\
					list("__t" = /datum/bt_node/ai_behavior/update_targets, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION))\
				)\
			)\
		)\
	)
