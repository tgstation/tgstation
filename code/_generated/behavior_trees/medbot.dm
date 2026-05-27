/datum/ai_controller/basic_controller/bot/medbot
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			/datum/bt_node/subtree/escape_captivity/pacifist,\
			/datum/bt_node/subtree/bot_respond_to_summon,\
			list(\
				"__t" = /datum/bt_node/composite/parallel,\
				"failure_policy" = BT_PARALLEL_FAILURE_CHILD_ONE,\
				"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,\
				"repeat_secondary" = TRUE,\
				"finish_on_primary" = FALSE,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/selector,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/decorator/bot_medical_flag,\
								"__c" = list(\
									/datum/bt_node/subtree/medbot_find_and_announce_crit\
								),\
								"flag" = MEDBOT_DECLARE_CRIT\
							),\
							list(\
								"__t" = /datum/bt_node/decorator/bot_medical_flag,\
								"__c" = list(\
									/datum/bt_node/subtree/medbot_treat_patient\
								),\
								"flag" = MEDBOT_TIPPED_MODE,\
								"invert" = TRUE\
							)\
						)\
					),\
					list(\
						"__t" = /datum/bt_node/composite/selector,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/decorator/bot_medical_flag,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/handle_medbot_speech, "default_behavior_args" = list(BB_ANNOUNCE_ABILITY))\
								),\
								"flag" = MEDBOT_SPEAK_MODE\
							),\
							/datum/bt_node/subtree/bot_salute_authority\
						)\
					)\
				)\
			)\
		)\
	)
