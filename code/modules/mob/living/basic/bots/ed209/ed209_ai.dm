#define DEFAULT_LINES "default_lines"
#define SPECIAL_LINES "special_lines"

/datum/ai_controller/basic_controller/bot/ed209
	behavior_tree_json = "code/modules/mob/living/basic/bots/ed209/ed209.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/secbot,
		BB_UNREACHABLE_LIST_COOLDOWN = 1 MINUTES,
		BB_ALWAYS_IGNORE_FACTION = TRUE,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 2,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 3
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
	RegisterSignal(new_pawn, COMSIG_AI_BLACKBOARD_KEY_SET(BB_CURRENT_TARGET), PROC_REF(on_target_set))


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

#undef DEFAULT_LINES
#undef SPECIAL_LINES
