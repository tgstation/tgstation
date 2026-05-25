#define DEFAULT_LINES "default_lines"
#define SPECIAL_LINES "special_lines"

/datum/ai_controller/basic_controller/bot/ed209
	behavior_tree_json = "ed209.bt.json"
	// @bt-generated begin
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			/datum/bt_node/subtree/escape_captivity/pacifist,\
			/datum/bt_node/subtree/bot_respond_to_summon,\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_set,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/decorator/secbot_target_valid,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/composite/parallel,\
								"failure_policy" = BT_PARALLEL_FAILURE_ANY,\
								"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,\
								"repeat_secondary" = FALSE,\
								"finish_on_primary" = FALSE,\
								"__c" = list(\
									list("__t" = /datum/bt_node/ai_behavior/basic_melee_attack/interact_once/bot/ed209, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)),\
									list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, 1))\
								)\
							)\
						)\
					)\
				),\
				"key" = BB_BASIC_MOB_CURRENT_TARGET\
			),\
			list("__t" = /datum/bt_node/ai_behavior/find_potential_targets, "default_behavior_args" = list(BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)),\
			/datum/bt_node/subtree/bot_patrol\
		)\
	)
	// @bt-generated end
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/secbot,
		BB_UNREACHABLE_LIST_COOLDOWN = 1 MINUTES,
		BB_ALWAYS_IGNORE_FACTION = TRUE,
	)
	reset_keys = list(
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_BOT_SUMMON_TARGET,
	)


/datum/ai_controller/basic_controller/bot/ed209/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	RegisterSignal(new_pawn, COMSIG_AI_BLACKBOARD_KEY_SET(BB_BASIC_MOB_CURRENT_TARGET), PROC_REF(on_target_set))


/datum/ai_controller/basic_controller/bot/ed209/proc/on_target_set()
	SIGNAL_HANDLER
	var/datum/action/cooldown/bot_announcement/announcement = blackboard[BB_ANNOUNCE_ABILITY]
	var/static/list/lines_to_pick = list(
		DEFAULT_LINES = list(
			"Scumbag alert!",
			"Threat detected!"
		),
		SPECIAL_LINES = list(
			"Why y'all causin trouble in my town?",
			"Fill your hands, you son of a bitch.",
			"Aint nobody causin trouble in MY jurisdiction."
		)

	)
	var/mob/living/basic/bot/secbot/ed209/my_bot = pawn
	var/list/final_list = my_bot.sheriffized ? lines_to_pick[SPECIAL_LINES] : lines_to_pick[DEFAULT_LINES]
	INVOKE_ASYNC(announcement, TYPE_PROC_REF(/datum/action/cooldown/bot_announcement, announce), pick(final_list))

/// Keeps returning RUNNING (DELAY) even without a hit so the parallel movement leg stays alive.
/datum/bt_node/ai_behavior/basic_melee_attack/interact_once/bot/ed209
	action_cooldown = 0.5 SECONDS

/datum/bt_node/ai_behavior/basic_melee_attack/interact_once/bot/ed209/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	if(!(. & AI_BEHAVIOR_DELAY))
		return AI_BEHAVIOR_DELAY


#undef DEFAULT_LINES
#undef SPECIAL_LINES
