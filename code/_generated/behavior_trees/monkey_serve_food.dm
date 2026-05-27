/datum/bt_node/subtree/monkey_serve_food
	behavior_nodes = list(\
		"__t" = /datum/bt_node/decorator/bb_key_set,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/composite/sequence,\
				"__c" = list(\
					list("__t" = /datum/bt_node/ai_behavior/monkey_find_patrons, "default_behavior_args" = list("BB_monkey_patrons_nearby", "BB_monkey_current_give_target")),\
					list(\
						"__t" = /datum/bt_node/composite/selector,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/decorator/bb_key_set,\
								"__c" = list(\
								),\
								"key" = "BB_monkey_current_served_item"\
							),\
							list(\
								"__t" = /datum/bt_node/decorator/bb_key_set,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/find_and_set/food_or_drink/to_serve, "default_behavior_args" = list("BB_monkey_current_served_item", /obj/item, 2))\
								),\
								"key" = "BB_monkey_current_served_item",\
								"invert" = TRUE\
							)\
						)\
					),\
					list(\
						"__t" = /datum/bt_node/composite/selector,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/composite/sequence,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list("BB_monkey_current_give_target", 1, FALSE)),\
									list("__t" = /datum/bt_node/ai_behavior/give, "default_behavior_args" = list("BB_monkey_current_give_target"))\
								)\
							),\
							list(\
								"__t" = /datum/bt_node/composite/sequence,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list("BB_monkey_current_served_item", 1, FALSE)),\
									list("__t" = /datum/bt_node/ai_behavior/pick_up, "default_behavior_args" = list("BB_monkey_current_served_item", TRUE))\
								)\
							)\
						)\
					)\
				)\
			)\
		),\
		"key" = "BB_monkey_tamed"\
	)
