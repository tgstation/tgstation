/datum/bt_node/subtree/bot_salute_authority
	behavior_nodes = list(\
		"__t" = /datum/bt_node/decorator/cooldown,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/composite/sequence,\
				"__c" = list(\
					list("__t" = /datum/bt_node/ai_behavior/find_valid_authority, "default_behavior_args" = list(BB_SALUTE_TARGET)),\
					list("__t" = /datum/bt_node/ai_behavior/salute_authority, "default_behavior_args" = list(BB_SALUTE_TARGET, BB_SALUTE_MESSAGES))\
				)\
			)\
		),\
		"cooldown_key" = BB_SALUTE_COOLDOWN,\
		"cooldown_duration" = 60\
	)
