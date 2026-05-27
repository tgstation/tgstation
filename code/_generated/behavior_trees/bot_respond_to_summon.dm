/datum/bt_node/subtree/bot_respond_to_summon
	behavior_nodes = list(\
		"__t" = /datum/bt_node/decorator/bb_key_set,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/composite/sequence,\
				"__c" = list(\
					list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_BOT_SUMMON_TARGET, 0, TRUE)),\
					list("__t" = /datum/bt_node/ai_behavior/complete_summon_travel, "default_behavior_args" = list(BB_BOT_SUMMON_TARGET))\
				)\
			)\
		),\
		"key" = BB_BOT_SUMMON_TARGET\
	)
