/datum/ai_controller/monkey
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			/datum/bt_node/subtree/escape_captivity,\
			/datum/bt_node/subtree/monkey_combat,\
			/datum/bt_node/subtree/monkey_serve_food,\
			/datum/bt_node/subtree/generic_hunger,\
			/datum/bt_node/subtree/generic_play_instrument,\
			/datum/bt_node/subtree/monkey_shenanigans\
		)\
	)
