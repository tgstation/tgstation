/datum/ai_controller/basic_controller/bot
	behavior_tree_json = "bot.bt.json"
	// @bt-generated begin
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			/datum/bt_node/subtree/escape_captivity/pacifist,\
			/datum/bt_node/subtree/bot_respond_to_summon,\
			/datum/bt_node/subtree/bot_salute_authority,\
			/datum/bt_node/subtree/bot_patrol\
		)\
	)
	// @bt-generated end
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_SALUTE_MESSAGES = list(
			"performs an elaborate salute for",
			"nods in appreciation towards",
		),
		BB_UNREACHABLE_LIST_COOLDOWN = 45 SECONDS,
	)

	ai_movement = /datum/ai_movement/jps/bot
	max_target_distance = AI_BOT_PATH_LENGTH
	can_idle = FALSE
	///minimum distance we need to be from our target in path calculations
	var/minimum_distance = 0
	///keys to be reset when the bot is reset
	var/list/reset_keys = list(
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_BOT_SUMMON_TARGET,
	)

/datum/targeting_strategy/basic/bot/can_attack(mob/living/living_mob, atom/the_target, vision_range)
	var/datum/ai_controller/basic_controller/bot/my_controller = living_mob.ai_controller
	if(isnull(my_controller))
		return FALSE
	if(!ishuman(the_target) || LAZYACCESS(my_controller.blackboard[BB_TEMPORARY_IGNORE_LIST], the_target))
		return FALSE
	var/mob/living/living_target = the_target
	if(isnull(living_target.mind))
		return FALSE
	if(get_turf(living_mob) == get_turf(living_target))
		return ..()
	var/list/path = get_path_to(living_mob, living_target, mintargetdist = my_controller.minimum_distance, max_distance = 10, access = my_controller.get_access())
	if(!length(path) || QDELETED(living_mob))
		my_controller?.add_to_blacklist(living_target)
		return FALSE
	return ..()

/datum/ai_controller/basic_controller/bot/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	RegisterSignal(new_pawn, COMSIG_BOT_RESET, PROC_REF(reset_bot))
	RegisterSignal(new_pawn, COMSIG_AI_BLACKBOARD_KEY_CLEARED(BB_BOT_SUMMON_TARGET), PROC_REF(clear_summon))
	RegisterSignal(new_pawn, COMSIG_MOB_AI_MOVEMENT_STARTED, PROC_REF(on_movement_start))

/datum/ai_controller/basic_controller/bot/proc/on_movement_start(mob/living/basic/bot/source, atom/target)
	SIGNAL_HANDLER

	if(current_movement_target == blackboard[BB_BEACON_TARGET])
		source.update_bot_mode(new_mode = BOT_PATROL)
		return

	source.clear_path_hud(remove_hud = FALSE)

/datum/ai_controller/basic_controller/bot/proc/add_to_blacklist(atom/target, duration)
	if(QDELETED(target))
		return
	var/final_duration = duration || blackboard[BB_UNREACHABLE_LIST_COOLDOWN]
	set_blackboard_key_assoc_lazylist(BB_TEMPORARY_IGNORE_LIST, target, TRUE)
	addtimer(CALLBACK(src, PROC_REF(remove_from_blacklist), target), final_duration)

/datum/ai_controller/basic_controller/bot/proc/remove_from_blacklist(atom/target)
	if(QDELETED(target))
		return
	remove_from_blackboard_lazylist_key(BB_TEMPORARY_IGNORE_LIST, target)

/datum/ai_controller/basic_controller/bot/proc/clear_summon()
	SIGNAL_HANDLER

	var/mob/living/basic/bot/bot_pawn = pawn
	bot_pawn.bot_reset()

/datum/ai_controller/basic_controller/bot/setup_able_to_run()
	. = ..()
	RegisterSignal(pawn, COMSIG_BOT_MODE_FLAGS_SET, PROC_REF(update_able_to_run))

/datum/ai_controller/basic_controller/bot/clear_able_to_run()
	UnregisterSignal(pawn, list(COMSIG_BOT_MODE_FLAGS_SET))
	return ..()

/datum/ai_controller/basic_controller/bot/get_able_to_run()
	var/mob/living/basic/bot/bot_pawn = pawn
	if(!(bot_pawn.bot_mode_flags & BOT_MODE_ON))
		return AI_UNABLE_TO_RUN
	return ..()

/datum/ai_controller/basic_controller/bot/get_access()
	var/mob/living/basic/bot/basic_bot = pawn
	return basic_bot.access_card?.access

/datum/ai_controller/basic_controller/bot/proc/reset_bot()
	SIGNAL_HANDLER
	CancelActions()
	if(!length(reset_keys))
		return
	for(var/key in reset_keys)
		clear_blackboard_key(key)

///set the target if we can reach them
/datum/ai_controller/basic_controller/bot/proc/set_if_can_reach(key, target, duration, distance = 10, bypass_add_to_blacklist = FALSE)
	if(can_reach_target(target, distance))
		EVLOG_MAPTEXT(src, EVLOG_CATEGORY_AI_TARGETING, "[pawn] has selected [target] as a target for blackboard key [key]!", get_turf(target), "Target: [target]")
		EVLOG_LINES(src, EVLOG_CATEGORY_AI_TARGETING, "Line to target", get_turf(pawn), get_turf(target))
		set_blackboard_key(key, target)
		return TRUE
	if(bypass_add_to_blacklist)
		return FALSE
	var/final_duration = duration || blackboard[BB_UNREACHABLE_LIST_COOLDOWN]
	EVLOG_MAPTEXT(src, EVLOG_CATEGORY_AI_TARGETING, "[pawn] has added [target] to its targetting blacklist!", get_turf(target), "Target: [target]")
	EVLOG_LINES(src, EVLOG_CATEGORY_AI_TARGETING, "Line to target", get_turf(pawn), get_turf(target))
	add_to_blacklist(target, final_duration)
	return FALSE

/datum/ai_controller/basic_controller/bot/proc/can_reach_target(target, distance = 10)
	if(!isdatum(target)) //we dont need to check if its not a datum!
		return TRUE
	if(get_turf(pawn) == get_turf(target))
		return TRUE
	var/list/path = get_path_to(pawn, target, simulated_only = !HAS_TRAIT(pawn, TRAIT_SPACEWALK), mintargetdist = minimum_distance, max_distance = distance, access = get_access())
	return (!!length(path))
