#define DEFAULT_LINES "default_lines"
#define SPECIAL_LINES "special_lines"

/datum/ai_controller/basic_controller/bot/ed209
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/secbot,
		BB_UNREACHABLE_LIST_COOLDOWN = 1 MINUTES,
		BB_ALWAYS_IGNORE_FACTION = TRUE,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity/pacifist,
		/datum/ai_planning_subtree/respond_to_summon,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/ranged_skirmish,
		/datum/ai_planning_subtree/arrest_target/ed209,
		/datum/ai_planning_subtree/find_patrol_beacon,
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
			"Why ya'll causin trouble in my town?",
			"Fill your hands, you son of a bitch.",
			"Aint nobody causin trouble in MY jurisdiction."
		)

	)
	var/mob/living/basic/bot/secbot/ed209/my_bot = pawn
	var/list/final_list = my_bot.sheriffized ? lines_to_pick[SPECIAL_LINES] : lines_to_pick[DEFAULT_LINES]
	INVOKE_ASYNC(announcement, TYPE_PROC_REF(/datum/action/cooldown/bot_announcement, announce), pick(final_list))

/datum/ai_planning_subtree/arrest_target/ed209
	arrest_behavior = /datum/ai_behavior/basic_melee_attack/interact_once/bot/ed209


/datum/ai_behavior/basic_melee_attack/interact_once/bot/ed209
	action_cooldown = 0.5 SECONDS

/datum/ai_behavior/basic_melee_attack/interact_once/bot/ed209/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	if(!(. & AI_BEHAVIOR_DELAY))
		return AI_BEHAVIOR_DELAY //this kinda sucks but we have to do this cause we need to shoot while moving to stun


#undef DEFAULT_LINES
#undef SPECIAL_LINES
