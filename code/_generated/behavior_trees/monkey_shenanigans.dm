/datum/bt_node/subtree/monkey_shenanigans
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/decorator/random_chance,\
				"__c" = list(\
					list("__t" = /datum/bt_node/ai_behavior/use_in_hand, "default_behavior_args" = list())\
				),\
				"chance" = 0.05\
			),\
			list(\
				"__t" = /datum/bt_node/decorator/random_chance,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/selector,\
						"__c" = list(\
							list("__t" = /datum/bt_node/ai_behavior/monkey_find_press_target, "default_behavior_args" = list("BB_monkey_current_press_target")),\
							list(\
								"__t" = /datum/bt_node/decorator/bb_key_set,\
								"__c" = list(\
									list(\
										"__t" = /datum/bt_node/decorator/random_chance,\
										"__c" = list(\
											list(\
												"__t" = /datum/bt_node/composite/sequence,\
												"__c" = list(\
													list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list("BB_monkey_current_press_target", 1, TRUE)),\
													list("__t" = /datum/bt_node/ai_behavior/use_on_object, "default_behavior_args" = list("BB_monkey_current_press_target")),\
													list("__t" = /datum/bt_node/ai_behavior/set_bb_key, "default_behavior_args" = list("BB_monkey_current_press_target"))\
												)\
											)\
										),\
										"chance" = 0.5\
									)\
								),\
								"key" = "BB_monkey_current_press_target"\
							)\
						)\
					)\
				),\
				"chance" = 0.2\
			),\
			list(\
				"__t" = /datum/bt_node/composite/selector,\
				"__c" = list(\
					list("__t" = /datum/bt_node/ai_behavior/find_and_set/pawn_must_hold_item, "default_behavior_args" = list("BB_monkey_current_give_target", /mob/living/carbon/human, 2)),\
					list(\
						"__t" = /datum/bt_node/decorator/bb_key_set,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/decorator/random_chance_from_key,\
								"__c" = list(\
									list(\
										"__t" = /datum/bt_node/composite/sequence,\
										"__c" = list(\
											list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list("BB_monkey_current_give_target", 1, TRUE)),\
											list("__t" = /datum/bt_node/ai_behavior/give, "default_behavior_args" = list("BB_monkey_current_give_target"))\
										)\
									)\
								),\
								"chance_key" = "BB_monkey_give_chance"\
							)\
						),\
						"key" = "BB_monkey_current_give_target"\
					)\
				)\
			),\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_equals,\
				"__c" = list(\
					/datum/bt_node/subtree/monkey_find_weapon\
				),\
				"key" = "BB_monkey_tamed",\
				"value" = FALSE\
			)\
		)\
	)
