/datum/bt_node/subtree/monkey_find_weapon
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/sequence,\
		"__c" = list(\
			list("__t" = /datum/bt_node/ai_behavior/monkey_find_weapon, "default_behavior_args" = list()),\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_set,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/selector,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/decorator/bb_key_set,\
								"__c" = list(\
									list(\
										"__t" = /datum/bt_node/composite/sequence,\
										"__c" = list(\
											list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list("BB_monkey_pickuptarget", 1, TRUE)),\
											list("__t" = /datum/bt_node/ai_behavior/monkey_equip/pickpocket, "default_behavior_args" = list("BB_monkey_pickuptarget"))\
										)\
									)\
								),\
								"key" = "BB_monkey_pickup_is_pickpocket"\
							),\
							list(\
								"__t" = /datum/bt_node/composite/sequence,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list("BB_monkey_pickuptarget", 1, TRUE)),\
									list("__t" = /datum/bt_node/ai_behavior/monkey_equip/ground, "default_behavior_args" = list("BB_monkey_pickuptarget"))\
								)\
							)\
						)\
					)\
				),\
				"key" = "BB_monkey_pickuptarget"\
			)\
		)\
	)
