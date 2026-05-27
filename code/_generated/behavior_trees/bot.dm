/datum/ai_controller/basic_controller/bot
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			/datum/bt_node/subtree/escape_captivity/pacifist,\
			/datum/bt_node/subtree/bot_respond_to_summon,\
			/datum/bt_node/subtree/bot_salute_authority,\
			/datum/bt_node/subtree/bot_patrol\
		)\
	)
