/datum/ai_controller/basic_controller/bot/ed209/syndicate
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_UNREACHABLE_LIST_COOLDOWN = 1 MINUTES,
	)
	behavior_tree_json = "ed209_syndicate.bt.json"
	// @bt-generated begin
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
				"finish_on_primary" = TRUE,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/selector,\
						"__c" = list(\
							/datum/bt_node/subtree/simple_ranged_combat,\
							/datum/bt_node/subtree/bot_patrol\
						)\
					),\
					list("__t" = /datum/bt_node/ai_behavior/find_potential_targets, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION))\
				)\
			)\
		)\
	)
	// @bt-generated end
	reset_keys = list(
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_BOT_SUMMON_TARGET,
	)
