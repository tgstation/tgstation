/datum/bt_node/subtree/repairbot_emagged
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_set,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/sequence,\
						"__c" = list(\
							list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_ROBOT_TARGET, 0, TRUE, /datum/ai_movement/basic_avoidance)),\
							list("__t" = /datum/bt_node/ai_behavior/bot_interact/tip_robot, "default_behavior_args" = list(BB_ROBOT_TARGET)),\
							list("__t" = /datum/bt_node/ai_behavior/grab_target, "default_behavior_args" = list(BB_ROBOT_TARGET))\
						)\
					)\
				),\
				"key" = BB_ROBOT_TARGET\
			),\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_set,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/sequence,\
						"__c" = list(\
							list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_DECONSTRUCT_TARGET, 0, TRUE, /datum/ai_movement/basic_avoidance)),\
							list("__t" = /datum/bt_node/ai_behavior/bot_interact, "default_behavior_args" = list(BB_DECONSTRUCT_TARGET))\
						)\
					)\
				),\
				"key" = BB_DECONSTRUCT_TARGET\
			)\
		)\
	)
