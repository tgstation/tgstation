/datum/ai_controller/basic_controller/queen_bee
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/composite/selector,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/decorator/bb_key_set,\
						"__c" = list(\
							list("__t" = /datum/bt_node/ai_behavior/find_hive, "default_behavior_args" = list())\
						),\
						"key" = BB_CURRENT_HOME,\
						"invert" = TRUE\
					),\
					list(\
						"__t" = /datum/bt_node/composite/sequence,\
						"__c" = list(\
							list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_CURRENT_HOME, 1, FALSE)),\
							list("__t" = /datum/bt_node/ai_behavior/inhabit_hive, "default_behavior_args" = list())\
						)\
					)\
				)\
			),\
			list("__t" = /datum/bt_node/ai_behavior/enter_exit_hive/queen, "default_behavior_args" = list()),\
			/datum/bt_node/subtree/simple_hostile_combat\
		)\
	)
