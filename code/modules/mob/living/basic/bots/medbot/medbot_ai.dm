#define BOT_PATIENT_PATH_LIMIT 20

/// Find and treat a patient — used by both the speak-mode parallel and the silent fallback branch.
/datum/bt_node/subtree/medbot_treat_patient
	behavior_tree_json = "code/modules/mob/living/basic/bots/medbot/medbot_treat_patient.bt.json"

/// Find a patient in hard-crit and announce them on radio.
/datum/bt_node/subtree/medbot_find_and_announce_crit
	behavior_tree_json = "code/modules/mob/living/basic/bots/medbot/medbot_find_and_announce_crit.bt.json"

/datum/ai_controller/basic_controller/bot/medbot
	behavior_tree_json = "code/modules/mob/living/basic/bots/medbot/medbot.bt.json"
	ai_movement = /datum/ai_movement/jps/bot/medbot
	reset_keys = list(
		BB_CURRENT_TARGET,
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_BOT_SUMMON_TARGET,
	)

/datum/ai_movement/jps/bot/medbot
	maximum_length = BOT_PATIENT_PATH_LIMIT
	max_pathing_attempts = 20

// only AI isn't allowed to move when this flag is set, sentient players can
/datum/ai_movement/jps/bot/medbot/allowed_to_move(datum/move_loop/source)
	var/datum/ai_controller/controller = source.extra_info
	var/mob/living/basic/bot/medbot/bot_pawn = controller.pawn
	if(bot_pawn.medical_mode_flags & MEDBOT_STATIONARY_MODE)
		return FALSE
	return ..()

/datum/ai_movement/jps/bot/medbot/travel_to_beacon
	maximum_length = AI_BOT_PATH_LENGTH



/// Medbot's note_unreachable_target skips blacklisting while stationary, matching the old set_if_can_reach bypass.
/datum/ai_controller/basic_controller/bot/medbot/note_unreachable_target(atom/target)
	var/mob/living/basic/bot/medbot/bot_pawn = pawn
	if(bot_pawn.medical_mode_flags & MEDBOT_STATIONARY_MODE)
		return
	return ..()

/// Gathers nearby humans as patients; range is clamped to adjacent tiles when the medbot is in stationary mode. I should probably just make this a blackboard thing but I cannot be arsed right now.
/datum/target_source/oview_single_type/human_mob/medbot_patient

/datum/target_source/oview_single_type/human_mob/medbot_patient/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	var/mob/living/basic/bot/medbot/bot_pawn = pawn
	if(bot_pawn.medical_mode_flags & MEDBOT_STATIONARY_MODE)
		range = 1
	return ..(pawn, controller, range)

/// Valid if the patient needs the damage type this medbot heals (or is a conscious target while emagged).
/datum/targeting_strategy/treatable_patient/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/patient = target
	if(!istype(patient) || patient.stat == DEAD)
		return FALSE
	var/mob/living/basic/bot/medbot/bot_pawn = living_mob
	if((bot_pawn.bot_access_flags & BOT_COVER_EMAGGED) && patient.stat == CONSCIOUS)
		return TRUE
	if(bot_pawn.damage_type_healer == HEAL_ALL_DAMAGE)
		return patient.get_total_damage() > bot_pawn.heal_threshold
	return patient.get_current_damage_of_type(damagetype = bot_pawn.damage_type_healer) > bot_pawn.heal_threshold

/// Finds a patient to treat, announcing that the bot is on its way when the patient isn't already adjacent.
/datum/bt_node/ai_behavior/acquire_target/update_interaction_target/medbot_patient

/datum/bt_node/ai_behavior/acquire_target/update_interaction_target/medbot_patient/on_target_found(datum/ai_controller/controller, atom/target, datum/targeting_strategy/strategy)
	if(QDELETED(controller.pawn) || get_dist(controller.pawn, target) <= 1)
		return
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[BB_ANNOUNCE_ABILITY]
	announcement?.announce(pick(controller.blackboard[BB_WAIT_SPEECH]))



/datum/bt_node/ai_behavior/tend_to_patient
	var/target_key

/datum/bt_node/ai_behavior/tend_to_patient/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller)
	var/mob/living/carbon/human/patient = controller.blackboard[target_key]
	if(QDELETED(patient) || patient.stat == DEAD)
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[controller.pawn] tend_to_patient: patient gone (deleted=[QDELETED(patient)], stat=[patient?.stat])")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(get_dist(controller.pawn, patient) > 1)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED //We technically failed, but we want to try again so succeed.
	var/mob/living/basic/bot/medbot/bot_pawn = controller.pawn
	if(check_if_healed(patient, bot_pawn.heal_threshold, bot_pawn.damage_type_healer, bot_pawn.bot_access_flags))
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[bot_pawn] tend_to_patient: [patient] is fully healed")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	if(patient.stat >= HARD_CRIT && prob(5))
		var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[BB_ANNOUNCE_ABILITY]
		announcement?.announce(pick(controller.blackboard[BB_NEAR_DEATH_SPEECH]))
	EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[bot_pawn] healing [patient] (dmg=[patient.get_total_damage()])", get_turf(patient), "Heal")
	bot_pawn.melee_attack(patient)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/tend_to_patient/finish_action(datum/ai_controller/basic_controller/bot/controller, succeeded)
	. = ..()
	var/mob/living/basic/bot/medbot/bot_pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	var/is_stationary = bot_pawn.medical_mode_flags & MEDBOT_STATIONARY_MODE
	if(!succeeded)
		if(!isnull(target) && !is_stationary)
			controller.add_to_blacklist(target)
		controller.clear_blackboard_key(target_key)
		return
	if(QDELETED(target) || !check_if_healed(target, bot_pawn.heal_threshold, bot_pawn.damage_type_healer, bot_pawn.bot_access_flags))
		return
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[BB_ANNOUNCE_ABILITY]
	announcement?.announce(pick(controller.blackboard[BB_AFTERHEAL_SPEECH]))
	controller.clear_blackboard_key(target_key)

/datum/bt_node/ai_behavior/tend_to_patient/proc/check_if_healed(mob/living/carbon/human/patient, threshold, damage_type_healer, access_flags)
	if(access_flags & BOT_COVER_EMAGGED)
		return (patient.stat > CONSCIOUS)
	var/patient_damage = (damage_type_healer == HEAL_ALL_DAMAGE) ? patient.get_total_damage() : patient.get_current_damage_of_type(damagetype = damage_type_healer)
	return (patient_damage <= threshold)



/datum/bt_node/ai_behavior/handle_medbot_speech
	var/announce_key
	time_between_perform = 20 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/bt_node/ai_behavior/handle_medbot_speech/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/bot/medbot/bot_pawn = controller.pawn
	var/currently_tipped = bot_pawn.medical_mode_flags & MEDBOT_TIPPED_MODE
	var/speech_chance = ((bot_pawn.bot_access_flags & BOT_COVER_EMAGGED) || currently_tipped) ? 15 : 5
	if(!SPT_PROB(speech_chance, seconds_per_tick))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[announce_key]
	var/list/speech_to_pick_from
	if(currently_tipped)
		speech_to_pick_from = controller.blackboard[BB_WORRIED_ANNOUNCEMENTS]
	else if(bot_pawn.bot_access_flags & BOT_COVER_EMAGGED)
		speech_to_pick_from = controller.blackboard[BB_EMAGGED_SPEECH]
	else if(bot_pawn.mode == BOT_IDLE)
		speech_to_pick_from = controller.blackboard[BB_IDLE_SPEECH]
	var/mob/living/living_pawn = controller.pawn
	if(locate(/obj/item/clothing/head/costume/chicken) in living_pawn)
		speech_to_pick_from += MEDIBOT_VOICED_CHICKEN
	if(!length(speech_to_pick_from))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	announcement.announce(pick(speech_to_pick_from))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED



/// Valid if the patient is at least unconscious, has a mind, and is visible — used to announce medical emergencies.
/datum/targeting_strategy/crit_patient/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/patient = target
	if(!istype(patient) || patient.stat < UNCONSCIOUS || isnull(patient.mind))
		return FALSE
	return can_see(living_mob, patient, vision_range)

/datum/bt_node/ai_behavior/announce_patient
	var/target_key
	time_between_perform = 3 MINUTES
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/bt_node/ai_behavior/announce_patient/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller)
	var/mob/living/living_target = controller.blackboard[target_key]
	if(QDELETED(living_target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[BB_ANNOUNCE_ABILITY]
	if(QDELETED(announcement))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/text_to_announce = "Medical emergency! [living_target] is in critical condition at [get_area(living_target)]!"
	announcement.announce(text_to_announce, controller.blackboard[BB_RADIO_CHANNEL])
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/announce_patient/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(target_key)

#undef BOT_PATIENT_PATH_LIMIT
