/datum/bt_node/subtree/generic_play_instrument
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_set,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/selector,\
						"__c" = list(\
							list("__t" = /datum/bt_node/ai_behavior/keep_playing_instrument, "default_behavior_args" = list(BB_SONG_INSTRUMENT)),\
							list(\
								"__t" = /datum/bt_node/composite/sequence,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/setup_instrument, "default_behavior_args" = list(BB_SONG_INSTRUMENT, "song_lines")),\
									list("__t" = /datum/bt_node/ai_behavior/play_instrument, "default_behavior_args" = list(BB_SONG_INSTRUMENT))\
								)\
							)\
						)\
					)\
				),\
				"key" = BB_SONG_INSTRUMENT\
			),\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_set,\
				"__c" = list(\
					list("__t" = /datum/bt_node/ai_behavior/find_and_set/in_hands, "default_behavior_args" = list(BB_SONG_INSTRUMENT, /obj/item/instrument))\
				),\
				"key" = BB_SONG_INSTRUMENT,\
				"invert" = TRUE\
			)\
		)\
	)
