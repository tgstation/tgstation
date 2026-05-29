/datum/ai_controller/basic_controller/bot/secbot
	behavior_tree_json = "secbot.bt.json"
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

/datum/targeting_strategy/basic/secbot/can_attack(mob/living/living_mob, atom/the_target, vision_range)
	var/datum/ai_controller/basic_controller/bot/my_controller = living_mob.ai_controller
	if(isnull(my_controller))
		return FALSE
	if(!ishuman(the_target) || LAZYACCESS(my_controller.blackboard[BB_TEMPORARY_IGNORE_LIST], the_target))
		return FALSE
	var/mob/living/carbon/human/human_target = the_target
	if(human_target.handcuffed || human_target.stat != CONSCIOUS)
		return FALSE
	if(locate(human_target) in my_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST])
		return TRUE
	var/mob/living/basic/bot/secbot/my_bot = living_mob
	if(human_target.IsParalyzed() && !(my_bot.security_mode_flags & SECBOT_HANDCUFF_TARGET))
		return FALSE
	var/assess_flags = my_bot.judgement_criteria()
	var/assessed_threat = human_target.assess_threat(assess_flags)
	if(assessed_threat > THREAT_ASSESS_DANGEROUS)
		my_controller.set_blackboard_key(BB_CURRENT_CRIMINAL_ASSESSMENT, assessed_threat)
	return (assessed_threat > THREAT_ASSESS_DANGEROUS)

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
	INVOKE_ASYNC(announcement, TYPE_PROC_REF(/datum/action/cooldown/bot_announcement, announce), "Level [threat_level] infraction alert!")
	playsound(pawn, pick(
		'sound/mobs/non-humanoids/beepsky/criminal.ogg',
		'sound/mobs/non-humanoids/beepsky/justice.ogg',
		'sound/mobs/non-humanoids/beepsky/freeze.ogg',
	), 50, FALSE)
	var/mob/living/basic/bot/secbot/my_bot = pawn
	my_bot.update_bot_mode(new_mode = BOT_HUNT)

/datum/ai_controller/basic_controller/bot/secbot/proc/on_clear_target()
	SIGNAL_HANDLER
	clear_blackboard_key(BB_CURRENT_CRIMINAL_ASSESSMENT)

/// Removes a handcuffed target from the retaliate list so the bot stops pursuing them.
/datum/bt_node/ai_behavior/basic_melee_attack/interact_once/bot

/datum/bt_node/ai_behavior/basic_melee_attack/interact_once/bot/finish_action(datum/ai_controller/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	var/mob/living/carbon/human/human_target = controller.blackboard[target_key]
	if(!isnull(human_target) && human_target.handcuffed)
		controller.remove_from_blackboard_lazylist_key(BB_BASIC_MOB_RETALIATE_LIST, human_target)
		controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
	return ..()
