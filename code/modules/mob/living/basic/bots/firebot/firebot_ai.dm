#define ANNOUNCEMENT_TIMER 10 SECONDS

/datum/ai_controller/basic_controller/bot/firebot
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/allow_turfs,
		BB_UNREACHABLE_LIST_COOLDOWN = 45 SECONDS,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/respond_to_summon,
		/datum/ai_planning_subtree/manage_unreachable_list,
		/datum/ai_planning_subtree/extinguishing_people,
		/datum/ai_planning_subtree/extinguishing_turfs,
		/datum/ai_planning_subtree/salute_authority,
		/datum/ai_planning_subtree/firebot_speech,
		/datum/ai_planning_subtree/find_patrol_beacon,
	)
	reset_keys = list(
		BB_FIREBOT_EXTINGUISH_TARGET,
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
	RegisterSignal(new_pawn, COMSIG_AI_BLACKBOARD_KEY_SET(BB_FIREBOT_EXTINGUISH_TARGET), PROC_REF(on_target_found))

///say a silly line whenever we find someone on fire
/datum/ai_controller/basic_controller/bot/firebot/proc/on_target_found()
	SIGNAL_HANDLER
	if(!COOLDOWN_FINISHED(src, announcement_cooldown))
		return

	var/datum/action/cooldown/bot_announcement/announcement = blackboard[BB_ANNOUNCE_ABILITY]
	if(isnull(announcement))
		return

	var/list/lines = blackboard[BB_FIREBOT_FIRE_DETECTED_LINES]
	if(!length(lines))
		return
	INVOKE_ASYNC(announcement, TYPE_PROC_REF(/datum/action/cooldown/bot_announcement, announce), pick(lines))
	COOLDOWN_START(src, announcement_cooldown, ANNOUNCEMENT_TIMER)


///subtree for extinguishing people
/datum/ai_planning_subtree/extinguishing_people

/datum/ai_planning_subtree/extinguishing_people/SelectBehaviors(datum/ai_controller/basic_controller/bot/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(BB_FIREBOT_EXTINGUISH_TARGET))
		controller.queue_behavior(/datum/ai_behavior/basic_melee_attack/interact_once/extinguish, BB_FIREBOT_EXTINGUISH_TARGET, BB_TARGETING_STRATEGY)
		return SUBTREE_RETURN_FINISH_PLANNING

	var/mob/living/basic/bot/firebot/living_bot = controller.pawn
	var/range = living_bot.firebot_mode_flags & FIREBOT_STATIONARY_MODE ? 1 : 5

	if(living_bot.firebot_mode_flags & FIREBOT_EXTINGUISH_PEOPLE)
		controller.queue_behavior(/datum/ai_behavior/bot_search/people_on_fire, BB_FIREBOT_EXTINGUISH_TARGET, controller.blackboard[BB_FIREBOT_CAN_EXTINGUISH], range)

///behavior for finding people on fire
/datum/ai_behavior/bot_search/people_on_fire

/datum/ai_behavior/bot_search/people_on_fire/valid_target(datum/ai_controller/basic_controller/bot/controller, mob/living/my_target)
	var/mob/living/basic/bot/living_bot = controller.pawn
	return (my_target.on_fire || (living_bot.bot_access_flags & BOT_COVER_EMAGGED))

///subtree for finding turfs to extinguish
/datum/ai_planning_subtree/extinguishing_turfs

/datum/ai_planning_subtree/extinguishing_turfs/SelectBehaviors(datum/ai_controller/basic_controller/bot/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(BB_FIREBOT_EXTINGUISH_TARGET))
		return

	var/mob/living/basic/bot/firebot/living_bot = controller.pawn
	var/should_bypass_blacklist = living_bot.firebot_mode_flags & FIREBOT_STATIONARY_MODE

	if(living_bot.firebot_mode_flags & FIREBOT_EXTINGUISH_FLAMES)
		controller.queue_behavior(/datum/ai_behavior/search_burning_turfs, BB_FIREBOT_EXTINGUISH_TARGET, should_bypass_blacklist)

///behavior to find burning turfs
/datum/ai_behavior/search_burning_turfs
	action_cooldown = 2 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/search_burning_turfs/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key, bypass_add_blacklist = FALSE)
	var/mob/living/living_pawn = controller.pawn
	var/list/ignore_list = controller.blackboard[BB_TEMPORARY_IGNORE_LIST]

	for(var/turf/possible_turf as anything in RANGE_TURFS(5, living_pawn))
		if(QDELETED(living_pawn))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
		if(!isopenturf(possible_turf))
			continue
		var/turf/open/open_turf = possible_turf
		if(!open_turf.active_hotspot)
			continue
		if(LAZYACCESS(ignore_list, possible_turf))
			continue
		if(controller.set_if_can_reach(target_key, possible_turf, bypass_add_to_blacklist = bypass_add_blacklist))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

///behavior to extinguish mobs or turfs
/datum/ai_behavior/basic_melee_attack/interact_once/extinguish

/datum/ai_behavior/basic_melee_attack/interact_once/extinguish/finish_action(datum/ai_controller/basic_controller/bot/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	var/atom/target = controller.blackboard[BB_FIREBOT_EXTINGUISH_TARGET]
	var/mob/living/basic/bot/living_bot = controller.pawn

	//if we couldnt path, or we successfully burnt someone, ignore them for a bit!
	if(!succeeded || (isliving(target) && (living_bot.bot_access_flags & BOT_COVER_EMAGGED)))
		controller.set_blackboard_key_assoc_lazylist(BB_TEMPORARY_IGNORE_LIST, target, TRUE)

	return ..()

///subtree to make us say funny idle lines
/datum/ai_planning_subtree/firebot_speech
	///chance we spout lines
	var/speech_prob = 3

/datum/ai_planning_subtree/firebot_speech/SelectBehaviors(datum/ai_controller/basic_controller/bot/controller, seconds_per_tick)
	if(controller.blackboard[BB_FIREBOT_EXTINGUISH_TARGET] || !SPT_PROB(speech_prob, seconds_per_tick))
		return
	var/mob/living/basic/bot/living_bot = controller.pawn
	var/list/idle_lines = (living_bot.bot_access_flags & BOT_COVER_EMAGGED) ? controller.blackboard[BB_FIREBOT_EMAGGED_LINES] : controller.blackboard[BB_FIREBOT_IDLE_LINES]
	controller.queue_behavior(/datum/ai_behavior/bot_speech, idle_lines, BB_ANNOUNCE_ABILITY)

#undef ANNOUNCEMENT_TIMER
