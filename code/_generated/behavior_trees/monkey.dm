/datum/ai_controller/monkey
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/parallel,\
		"failure_policy" = BT_PARALLEL_FAILURE_CHILD_ONE,\
		"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,\
		"repeat_secondary" = TRUE,\
		"finish_on_primary" = TRUE,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/composite/selector,\
				"__c" = list(\
					/datum/bt_node/subtree/escape_captivity,\
					/datum/bt_node/subtree/monkey_combat,\
					/datum/bt_node/subtree/monkey_serve_food,\
					/datum/bt_node/subtree/generic_hunger,\
					/datum/bt_node/subtree/generic_play_instrument,\
					/datum/bt_node/subtree/monkey_shenanigans,\
					list("__t" = /datum/bt_node/ai_behavior/monkey_idle, "default_behavior_args" = list())\
				)\
			),\
			list(\
				"__t" = /datum/bt_node/composite/selector,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/decorator/bb_key_set,\
						"__c" = list(\
							list("__t" = /datum/bt_node/ai_behavior/monkey_set_combat_target, "default_behavior_args" = list("BB_monkey_current_attack_target", "BB_monkey_enemies"))\
						),\
						"key" = "BB_monkey_current_attack_target",\
						"invert" = TRUE\
					)\
				)\
			)\
		)\
	)
