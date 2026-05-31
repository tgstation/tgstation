/datum/ai_controller/basic_controller/goldgrub
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			/datum/bt_node/subtree/escape_captivity/pacifist,\
			list("__t" = /datum/bt_node/subtree/fail, "override_id" = SUBPLAN_ID_PET_COMMAND),\
			list("__t" = /datum/bt_node/ai_behavior/dig_away_from_danger, "default_behavior_args" = list()),\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_set,\
				"__c" = list(\
					list("__t" = /datum/bt_node/ai_behavior/burrow_through_ground, "default_behavior_args" = list())\
				),\
				"observer_abort" = BT_ABORT_BOTH,\
				"key" = BB_BASIC_MOB_CURRENT_TARGET\
			),\
			list(\
				"__t" = /datum/bt_node/composite/parallel,\
				"failure_policy" = BT_PARALLEL_FAILURE_CHILD_ONE,\
				"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,\
				"repeat_secondary" = TRUE,\
				"repeat_secondary_delay" = BASIC_MOB_FIND_ENEMY_RATE,\
				"finish_on_primary" = TRUE,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/selector,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/decorator/bb_key_set,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/run_away_from_target, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION))\
								),\
								"observer_abort" = BT_ABORT_BOTH,\
								"key" = BB_BASIC_MOB_CURRENT_TARGET\
							),\
							list(\
								"__t" = /datum/bt_node/decorator/bb_key_set,\
								"__c" = list(\
									list(\
										"__t" = /datum/bt_node/composite/sequence,\
										"__c" = list(\
											list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_BOULDER_TARGET, 1, FALSE)),\
											list("__t" = /datum/bt_node/ai_behavior/grub_eat, "default_behavior_args" = list(BB_BOULDER_TARGET))\
										)\
									)\
								),\
								"key" = BB_BOULDER_TARGET,\
								"observer_abort" = BT_ABORT_BOTH\
							),\
							list(\
								"__t" = /datum/bt_node/decorator/bb_key_set,\
								"__c" = list(\
									list(\
										"__t" = /datum/bt_node/composite/sequence,\
										"__c" = list(\
											list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_ORE_TARGET, 1, FALSE)),\
											list("__t" = /datum/bt_node/ai_behavior/grub_eat, "default_behavior_args" = list(BB_ORE_TARGET))\
										)\
									)\
								),\
								"key" = BB_ORE_TARGET,\
								"observer_abort" = BT_ABORT_BOTH\
							),\
							list(\
								"__t" = /datum/bt_node/decorator/bb_key_set,\
								"__c" = list(\
									list(\
										"__t" = /datum/bt_node/composite/sequence,\
										"__c" = list(\
											list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_VENT_TARGET, 1, FALSE)),\
											list("__t" = /datum/bt_node/ai_behavior/grub_eat, "default_behavior_args" = list(BB_VENT_TARGET))\
										)\
									)\
								),\
								"key" = BB_VENT_TARGET,\
								"observer_abort" = BT_ABORT_BOTH\
							),\
							list(\
								"__t" = /datum/bt_node/composite/selector,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/mine_wall, "default_behavior_args" = list(BB_TARGET_MINERAL_WALL)),\
									list("__t" = /datum/bt_node/ai_behavior/find_mineral_wall, "default_behavior_args" = list(BB_TARGET_MINERAL_WALL))\
								)\
							),\
							list(\
								"__t" = /datum/bt_node/decorator/bb_key_set,\
								"__c" = list(\
									list(\
										"__t" = /datum/bt_node/composite/sequence,\
										"__c" = list(\
											list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_LOW_PRIORITY_HUNTING_TARGET, 1, FALSE)),\
											list("__t" = /datum/bt_node/ai_behavior/pull_grub_egg, "default_behavior_args" = list(BB_LOW_PRIORITY_HUNTING_TARGET))\
										)\
									)\
								),\
								"key" = BB_LOW_PRIORITY_HUNTING_TARGET,\
								"observer_abort" = BT_ABORT_BOTH\
							),\
							list(\
								"__t" = /datum/bt_node/composite/subplan,\
								"success_policy" = BT_SUBPLAN_LOOP_ON_SUCCESS,\
								"failure_policy" = BT_SUBPLAN_FAIL_ON_FAILURE,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/idle_random_walk, "default_behavior_args" = list())\
								)\
							)\
						)\
					),\
					list(\
						"__t" = /datum/bt_node/composite/selector,\
						"__c" = list(\
							list("__t" = /datum/bt_node/ai_behavior/update_targets, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)),\
							list("__t" = /datum/bt_node/ai_behavior/find_ore, "default_behavior_args" = list()),\
							list("__t" = /datum/bt_node/ai_behavior/find_boulder, "default_behavior_args" = list()),\
							list("__t" = /datum/bt_node/ai_behavior/find_ore_vent, "default_behavior_args" = list()),\
							list("__t" = /datum/bt_node/ai_behavior/find_grub_egg, "default_behavior_args" = list())\
						)\
					)\
				)\
			)\
		)\
	)
