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


/// Firebot skips blacklisting unreachable targets while stationary, matching the old set_if_can_reach bypass.
/datum/ai_controller/basic_controller/bot/firebot/note_unreachable_target(atom/target)
	var/mob/living/basic/bot/firebot/bot_pawn = pawn
	if(bot_pawn.firebot_mode_flags & FIREBOT_STATIONARY_MODE)
		return
	return ..()

/// Gathers nearby living mobs to extinguish; empty unless people-extinguishing is on, range clamped to adjacent tiles when stationary.
/datum/target_source/oview_single_type/living_mob/firebot_people

/datum/target_source/oview_single_type/living_mob/firebot_people/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	var/mob/living/basic/bot/firebot/bot_pawn = pawn
	if(!(bot_pawn.firebot_mode_flags & FIREBOT_EXTINGUISH_PEOPLE))
		return list()
	if(bot_pawn.firebot_mode_flags & FIREBOT_STATIONARY_MODE)
		range = 1
	return ..(pawn, controller, range)

/// Valid if the mob is on fire (or anyone, while emagged) and is a type this firebot is allowed to extinguish.
/datum/targeting_strategy/extinguishable_person/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/target_mob = target
	if(!isliving(target_mob))
		return FALSE
	var/mob/living/basic/bot/firebot/bot_pawn = living_mob
	if(!target_mob.on_fire && !(bot_pawn.bot_access_flags & BOT_COVER_EMAGGED))
		return FALSE
	return is_type_in_list(target_mob, controller.blackboard[BB_FIREBOT_CAN_EXTINGUISH])


/// Gathers turfs in range; empty unless flame-extinguishing is enabled.
/datum/target_source/range_turfs/firebot_hotspots

/datum/target_source/range_turfs/firebot_hotspots/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	var/mob/living/basic/bot/firebot/bot_pawn = pawn
	if(!(bot_pawn.firebot_mode_flags & FIREBOT_EXTINGUISH_FLAMES))
		return list()
	return ..(pawn, controller, range)

/// Valid if the turf is an open turf with an active fire.
/datum/targeting_strategy/burning_hotspot/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	if(!isopenturf(target))
		return FALSE
	var/turf/open/open_turf = target
	return !!open_turf.active_hotspot



/datum/bt_node/ai_behavior/bot_interact/extinguish

/datum/bt_node/ai_behavior/bot_interact/extinguish/finish_action(datum/ai_controller/basic_controller/bot/controller, succeeded)
	. = ..()
	// if we couldn't reach OR we emagged a living target, blacklist them
	var/atom/target = controller.blackboard[target_key]
	var/mob/living/basic/bot/living_bot = controller.pawn
	if(!succeeded || (isliving(target) && (living_bot.bot_access_flags & BOT_COVER_EMAGGED)))
		controller.add_to_blacklist(target)



/datum/bt_node/ai_behavior/handle_firebot_speech
	time_between_perform = 20 SECONDS
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
