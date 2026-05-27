/datum/ai_controller/basic_controller/bot/vibebot
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
										"__t" = /datum/bt_node/composite/sequence,\
										"__c" = list(\
											list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_VIBEBOT_PARTY_TARGET, 1, TRUE, null)),\
											list("__t" = /datum/bt_node/ai_behavior/vibebot_party, "default_behavior_args" = list(BB_VIBEBOT_PARTY_ABILITY, BB_VIBEBOT_PARTY_TARGET))\
										)\
									)\
								),\
								"key" = BB_VIBEBOT_PARTY_TARGET\
							),\
							/datum/bt_node/subtree/bot_patrol\
						)\
					),\
					list("__t" = /datum/bt_node/ai_behavior/find_party_friends, "default_behavior_args" = list(BB_VIBEBOT_PARTY_TARGET))\
				)\
			)\
		)\
	)
