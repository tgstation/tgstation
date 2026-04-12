/datum/ai_controller/basic_controller/bot/secbot
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_UNREACHABLE_LIST_COOLDOWN = 1 MINUTES,
		BB_ALWAYS_IGNORE_FACTION = TRUE,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity/pacifist,
		/datum/ai_planning_subtree/respond_to_summon,
		/datum/ai_planning_subtree/find_wanted_targets,
		/datum/ai_planning_subtree/arrest_target,
		/datum/ai_planning_subtree/find_patrol_beacon,
	)
	reset_keys = list(
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_BOT_SUMMON_TARGET,
	)

/datum/ai_controller/basic_controller/bot/secbot/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	RegisterSignal(new_pawn, COMSIG_AI_BLACKBOARD_KEY_SET(BB_BASIC_MOB_CURRENT_TARGET), PROC_REF(on_target_set))
	RegisterSignal(new_pawn, COMSIG_AI_BLACKBOARD_KEY_CLEARED(BB_BASIC_MOB_CURRENT_TARGET), PROC_REF(on_clear_target))

/datum/ai_controller/basic_controller/bot/secbot/proc/on_target_set()
	SIGNAL_HANDLER
	var/datum/action/cooldown/bot_announcement/announcement = blackboard[BB_ANNOUNCE_ABILITY]
	var/threat_level = 5 || blackboard[BB_CURRENT_CRIMINAL_ASSESSMENT]
	var/static/list/possible_sounds = list(
		'sound/mobs/non-humanoids/beepsky/criminal.ogg',
		'sound/mobs/non-humanoids/beepsky/justice.ogg',
		'sound/mobs/non-humanoids/beepsky/freeze.ogg',
	)
	INVOKE_ASYNC(announcement, TYPE_PROC_REF(/datum/action/cooldown/bot_announcement, announce), "Level [threat_level] infraction alert!")
	playsound(pawn, pick(possible_sounds), 50, FALSE)

/datum/ai_controller/basic_controller/bot/secbot/proc/on_clear_target()
	SIGNAL_HANDLER
	clear_blackboard_key(BB_CURRENT_CRIMINAL_ASSESSMENT)

/datum/ai_planning_subtree/arrest_target
	///what behavior do we use when arresting?
	var/datum/ai_behavior/arrest_behavior = /datum/ai_behavior/basic_melee_attack/interact_once/bot

/datum/ai_planning_subtree/arrest_target/SelectBehaviors(datum/ai_controller/basic_controller/bot/controller, seconds_per_tick)
	var/mob/living/carbon/my_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(QDELETED(my_target) || !istype(my_target) || my_target.handcuffed)
		controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		return

	var/bot_flags = retrieve_arrest_flags(controller)
	if(my_target.IsParalyzed() && !(bot_flags & SECBOT_HANDCUFF_TARGET))
		controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		return

	controller.queue_behavior(arrest_behavior, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_planning_subtree/arrest_target/proc/retrieve_arrest_flags(datum/ai_controller/basic_controller/bot/controller)
	var/mob/living/basic/bot/secbot/my_bot = controller.pawn
	return my_bot.security_mode_flags


/datum/ai_behavior/basic_melee_attack/interact_once/bot

/datum/ai_behavior/basic_melee_attack/interact_once/bot/finish_action(datum/ai_controller/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	var/mob/living/carbon/human/human_target = controller.blackboard[target_key]
	if(!isnull(human_target) && human_target.handcuffed)
		controller.remove_from_blackboard_lazylist_key(BB_BASIC_MOB_RETALIATE_LIST, human_target)
	return ..()


/datum/ai_planning_subtree/find_wanted_targets
	///what behavior do we use to search for targets?
	var/datum/ai_behavior/search_behavior =  /datum/ai_behavior/bot_search/wanted_targets

/datum/ai_planning_subtree/find_wanted_targets/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/static/list/can_arrest = typecacheof(list(/mob/living/carbon/human))
	if(!controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		controller.queue_behavior(search_behavior, BB_BASIC_MOB_CURRENT_TARGET, can_arrest)

/datum/ai_behavior/bot_search/wanted_targets

/datum/ai_behavior/bot_search/wanted_targets/valid_target(datum/ai_controller/basic_controller/bot/controller, mob/living/my_target)
	if(!ishuman(my_target))
		return FALSE
	var/mob/living/carbon/human/human_target = my_target
	if(human_target.handcuffed || human_target.stat != CONSCIOUS)
		return FALSE
	if(locate(human_target) in controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST])
		return TRUE
	var/bot_flags = retrieve_arrest_flags(controller)
	if(human_target.IsParalyzed() && !(bot_flags & SECBOT_HANDCUFF_TARGET))
		return FALSE
	var/mob/living/basic/bot/secbot/my_bot = controller.pawn
	var/assess_flags = my_bot.judgement_criteria()
	var/assessed_threat = human_target.assess_threat(assess_flags)
	if(assessed_threat > 0)
		controller.set_blackboard_key(BB_CURRENT_CRIMINAL_ASSESSMENT, assessed_threat)
	return (assessed_threat > 0)


/datum/ai_behavior/bot_search/wanted_targets/proc/retrieve_arrest_flags(datum/ai_controller/basic_controller/bot/controller) //should look into unifiyng honkbots and ed209s under secbot subtypes when the beepsky refactor comes
	var/mob/living/basic/bot/secbot/parent_bot = controller.pawn
	return parent_bot.security_mode_flags
