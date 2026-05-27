/datum/bt_node/subtree/bot_patrol
	behavior_nodes = list(\
		"__t" = /datum/bt_node/decorator/key_off_cooldown,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/decorator/bot_mode_flag,\
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
											list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_BEACON_TARGET, 0, TRUE)),\
											list("__t" = /datum/bt_node/ai_behavior/arrive_at_beacon, "default_behavior_args" = list(BB_BEACON_TARGET))\
										)\
									)\
								),\
								"key" = BB_BEACON_TARGET\
							),\
							list(\
								"__t" = /datum/bt_node/decorator/bb_key_set,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/find_next_beacon_target, "default_behavior_args" = list(BB_BEACON_TARGET))\
								),\
								"key" = BB_PREVIOUS_BEACON_TARGET\
							),\
							list("__t" = /datum/bt_node/ai_behavior/find_first_beacon_target, "default_behavior_args" = list(BB_BEACON_TARGET))\
						)\
					)\
				),\
				"flag" = BOT_MODE_AUTOPATROL\
			)\
		),\
		"cooldown_key" = BB_BOT_BEACON_COOLDOWN\
	)
