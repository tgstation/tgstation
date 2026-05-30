/datum/bt_node/subtree/escape_captivity
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/decorator/pawn_buckled_to_obj,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/selector,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/decorator/buckle_target_dangerous,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/break_out_of_object/from_bb, "default_behavior_args" = list(BB_BASIC_MOB_ESCAPE_TARGET))\
								)\
							),\
							list("__t" = /datum/bt_node/ai_behavior/resist, "default_behavior_args" = list())\
						)\
					)\
				),\
				"observer_abort" = BT_ABORT_LOWER_PRIORITY\
			),\
			list(\
				"__t" = /datum/bt_node/decorator/pawn_contained_in_obj,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/selector,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/decorator/container_attackable,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/break_out_of_object/from_bb, "default_behavior_args" = list(BB_BASIC_MOB_ESCAPE_TARGET))\
								)\
							),\
							list("__t" = /datum/bt_node/ai_behavior/resist, "default_behavior_args" = list())\
						)\
					)\
				),\
				"observer_abort" = BT_ABORT_LOWER_PRIORITY\
			),\
			list(\
				"__t" = /datum/bt_node/decorator/pawn_grabbed_by_enemy,\
				"__c" = list(\
					list("__t" = /datum/bt_node/ai_behavior/resist, "default_behavior_args" = list())\
				),\
				"observer_abort" = BT_ABORT_LOWER_PRIORITY\
			),\
			list(\
				"__t" = /datum/bt_node/decorator/pawn_is_restrained,\
				"__c" = list(\
					list("__t" = /datum/bt_node/ai_behavior/resist, "default_behavior_args" = list())\
				),\
				"observer_abort" = BT_ABORT_LOWER_PRIORITY\
			)\
		)\
	)
