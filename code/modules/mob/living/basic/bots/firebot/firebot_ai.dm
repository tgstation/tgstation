#define ANNOUNCEMENT_TIMER 10 SECONDS

/datum/ai_controller/basic_controller/bot/firebot
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/allow_turfs,
		BB_UNREACHABLE_LIST_COOLDOWN =  3 MINUTES,
	)
	behavior_tree_json = "code/modules/mob/living/basic/bots/firebot/firebot.bt.json"
	reset_keys = list(
		BB_CURRENT_TARGET,
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_BOT_SUMMON_TARGET,
	)
	///cooldown until we announce a fire again
	COOLDOWN_DECLARE(announcement_cooldown)

/datum/ai_controller/basic_controller/bot/firebot/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return

// =============================================================================
// Announce fire detected
// =============================================================================

/datum/bt_node/ai_behavior/announce_fire_detected

/datum/bt_node/ai_behavior/announce_fire_detected/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/firebot/controller)
	if(!COOLDOWN_FINISHED(controller, announcement_cooldown))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[BB_ANNOUNCE_ABILITY]
	if(isnull(announcement))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	var/list/lines = controller.blackboard[BB_FIREBOT_FIRE_DETECTED_LINES]
	if(!length(lines))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	INVOKE_ASYNC(announcement, TYPE_PROC_REF(/datum/action/cooldown/bot_announcement, announce), pick(lines))
	COOLDOWN_START(controller, announcement_cooldown, ANNOUNCEMENT_TIMER)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

// =============================================================================
// Find person on fire
// =============================================================================

/datum/bt_node/ai_behavior/find_person_on_fire
	var/target_key
	time_between_perform = 2 SECONDS

/datum/bt_node/ai_behavior/find_person_on_fire/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller)
	var/mob/living/basic/bot/firebot/living_bot = controller.pawn
	if(!(living_bot.firebot_mode_flags & FIREBOT_EXTINGUISH_PEOPLE))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/range = living_bot.firebot_mode_flags & FIREBOT_STATIONARY_MODE ? 1 : 5
	var/list/ignore_list = controller.blackboard[BB_TEMPORARY_IGNORE_LIST]
	var/list/can_extinguish = controller.blackboard[BB_FIREBOT_CAN_EXTINGUISH]
	for(var/mob/living/nearby_mob in oview(range, living_bot))
		if(LAZYACCESS(ignore_list, nearby_mob))
			continue
		if(!nearby_mob.on_fire && !(living_bot.bot_access_flags & BOT_COVER_EMAGGED))
			continue
		if(!is_type_in_list(nearby_mob, can_extinguish))
			continue
		if(controller.set_if_can_reach(key = target_key, target = nearby_mob, bypass_add_to_blacklist = (range == 1)))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

// =============================================================================
// Search burning turfs
// =============================================================================

/datum/bt_node/ai_behavior/search_burning_turfs
	var/target_key
	time_between_perform = 2 SECONDS

/datum/bt_node/ai_behavior/search_burning_turfs/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller)
	var/mob/living/basic/bot/firebot/living_bot = controller.pawn
	if(!(living_bot.firebot_mode_flags & FIREBOT_EXTINGUISH_FLAMES))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/bypass_blacklist = !!(living_bot.firebot_mode_flags & FIREBOT_STATIONARY_MODE)
	var/list/ignore_list = controller.blackboard[BB_TEMPORARY_IGNORE_LIST]
	for(var/turf/possible_turf as anything in RANGE_TURFS(5, living_bot))
		if(QDELETED(living_bot))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
		if(!isopenturf(possible_turf))
			continue
		var/turf/open/open_turf = possible_turf
		if(!open_turf.active_hotspot)
			continue
		if(LAZYACCESS(ignore_list, possible_turf))
			continue
		if(controller.set_if_can_reach(key = target_key, target = possible_turf, bypass_add_to_blacklist = bypass_blacklist))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

// =============================================================================
// Extinguish interact (bot_interact variant)
// =============================================================================

/datum/bt_node/ai_behavior/bot_interact/extinguish

/datum/bt_node/ai_behavior/bot_interact/extinguish/finish_action(datum/ai_controller/basic_controller/bot/controller, succeeded)
	. = ..()
	// if we couldn't reach OR we emagged a living target, blacklist them
	var/atom/target = controller.blackboard[target_key]
	var/mob/living/basic/bot/living_bot = controller.pawn
	if(!succeeded || (isliving(target) && (living_bot.bot_access_flags & BOT_COVER_EMAGGED)))
		controller.add_to_blacklist(target)

// =============================================================================
// Firebot idle speech
// =============================================================================

/datum/bt_node/ai_behavior/handle_firebot_speech
	time_between_perform = 20 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	var/speech_prob = 3

/datum/bt_node/ai_behavior/handle_firebot_speech/perform(seconds_per_tick, datum/ai_controller/controller)
	if(!SPT_PROB(speech_prob, seconds_per_tick))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/mob/living/basic/bot/living_bot = controller.pawn
	var/list/idle_lines = (living_bot.bot_access_flags & BOT_COVER_EMAGGED) ? controller.blackboard[BB_FIREBOT_EMAGGED_LINES] : controller.blackboard[BB_FIREBOT_IDLE_LINES]
	if(!length(idle_lines))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[BB_ANNOUNCE_ABILITY]
	announcement?.announce(pick(idle_lines))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

#undef ANNOUNCEMENT_TIMER
