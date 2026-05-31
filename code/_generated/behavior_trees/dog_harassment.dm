/datum/bt_node/subtree/dog_harassment
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_set,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/sequence,\
						"__c" = list(\
							list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_DOG_HARASS_TARGET, 1, FALSE)),\
							list("__t" = /datum/bt_node/ai_behavior/basic_melee_attack/dog, "default_behavior_args" = list(BB_DOG_HARASS_TARGET, BB_PET_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION))\
						)\
					)\
				),\
				"key" = BB_DOG_HARASS_TARGET,\
				"observer_abort" = BT_ABORT_BOTH\
			),\
			list("__t" = /datum/bt_node/ai_behavior/find_hated_dog_target, "default_behavior_args" = list(BB_DOG_HARASS_TARGET, BB_PET_TARGETING_STRATEGY))\
		)\
	)
