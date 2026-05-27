/datum/bt_node/subtree/honkbot_slip
	behavior_nodes = list(\
		"__t" = /datum/bt_node/decorator/can_see_target,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/decorator/can_see_target,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/decorator/pawn_has_gravity,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/composite/sequence,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_SLIP_TARGET, 1, TRUE, /datum/ai_movement/basic_avoidance)),\
									list("__t" = /datum/bt_node/ai_behavior/grab_target, "default_behavior_args" = list(BB_SLIP_TARGET)),\
									list(\
										"__t" = /datum/bt_node/decorator/is_grabbing_target,\
										"__c" = list(\
											list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_SLIPPERY_TARGET, 0, TRUE, /datum/ai_movement/basic_avoidance))\
										),\
										"observer_abort" = BT_ABORT_SELF,\
										"key" = BB_SLIP_TARGET\
									),\
									list("__t" = /datum/bt_node/ai_behavior/release_and_slip, "default_behavior_args" = list(BB_SLIP_TARGET)),\
									list("__t" = /datum/bt_node/ai_behavior/perform_emote, "default_behavior_args" = list("flip"))\
								)\
							)\
						)\
					)\
				),\
				"key" = BB_SLIP_TARGET,\
				"range" = 5\
			)\
		),\
		"key" = BB_SLIPPERY_TARGET,\
		"range" = 5\
	)
