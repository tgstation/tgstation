/datum/bt_node/subtree/generic_hunger
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_set,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/selector,\
						"__c" = list(\
							list("__t" = /datum/bt_node/ai_behavior/consume, "default_behavior_args" = list("bb_food_target", BB_NEXT_HUNGRY)),\
							list(\
								"__t" = /datum/bt_node/composite/sequence,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list("bb_food_target", 1, FALSE)),\
									list("__t" = /datum/bt_node/ai_behavior/pick_up, "default_behavior_args" = list("bb_food_target", TRUE))\
								)\
							)\
						)\
					)\
				),\
				"key" = "bb_food_target"\
			),\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_set,\
				"__c" = list(\
					list("__t" = /datum/bt_node/ai_behavior/find_and_set/food_or_drink/to_eat, "default_behavior_args" = list("bb_food_target", /obj/item, 2))\
				),\
				"key" = "bb_food_target",\
				"invert" = TRUE\
			)\
		)\
	)
