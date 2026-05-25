#define BOT_PATIENT_PATH_LIMIT 20

/// Find and treat a patient — used by both the speak-mode parallel and the silent fallback branch.
/datum/bt_node/subtree/medbot_treat_patient
	behavior_tree_json = "medbot_treat_patient.bt.json"
	// @bt-generated begin
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_set,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/parallel,\
						"failure_policy" = BT_PARALLEL_FAILURE_ANY,\
						"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,\
						"repeat_secondary" = FALSE,\
						"finish_on_primary" = FALSE,\
						"__c" = list(\
							list("__t" = /datum/bt_node/ai_behavior/tend_to_patient, "default_behavior_args" = list(BB_PATIENT_TARGET)),\
							list("__t" = /datum/bt_node/ai_behavior/move_to_target, "default_behavior_args" = list(BB_PATIENT_TARGET, 0))\
						)\
					)\
				),\
				"key" = BB_PATIENT_TARGET\
			),\
			list("__t" = /datum/bt_node/ai_behavior/find_suitable_patient, "default_behavior_args" = list(BB_PATIENT_TARGET))\
		)\
	)
	// @bt-generated end

/// Find a patient in hard-crit and announce them on radio.
/datum/bt_node/subtree/medbot_find_and_announce_crit
	behavior_tree_json = "medbot_find_and_announce_crit.bt.json"
	// @bt-generated begin
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			list(\
				"__t" = /datum/bt_node/decorator/bb_key_set,\
				"__c" = list(\
					list("__t" = /datum/bt_node/ai_behavior/announce_patient, "default_behavior_args" = list(BB_PATIENT_IN_CRIT))\
				),\
				"key" = BB_PATIENT_IN_CRIT\
			),\
			list("__t" = /datum/bt_node/ai_behavior/find_patient_in_crit, "default_behavior_args" = list(BB_PATIENT_IN_CRIT))\
		)\
	)
	// @bt-generated end

/datum/ai_controller/basic_controller/bot/medbot
	behavior_tree_json = "medbot.bt.json"
	// @bt-generated begin
	behavior_nodes = list(\
		"__t" = /datum/bt_node/composite/selector,\
		"__c" = list(\
			/datum/bt_node/subtree/escape_captivity/pacifist,\
			/datum/bt_node/subtree/bot_respond_to_summon,\
			list(\
				"__t" = /datum/bt_node/decorator/bot_medical_flag,\
				"__c" = list(\
					list(\
						"__t" = /datum/bt_node/composite/parallel,\
						"failure_policy" = BT_PARALLEL_FAILURE_CHILD_ONE,\
						"success_policy" = BT_PARALLEL_SUCCESS_CHILD_ONE,\
						"repeat_secondary" = TRUE,\
						"finish_on_primary" = FALSE,\
						"__c" = list(\
							list(\
								"__t" = /datum/bt_node/composite/selector,\
								"__c" = list(\
									list(\
										"__t" = /datum/bt_node/decorator/bot_medical_flag,\
										"__c" = list(\
											/datum/bt_node/subtree/medbot_find_and_announce_crit\
										),\
										"flag" = MEDBOT_DECLARE_CRIT\
									),\
									list(\
										"__t" = /datum/bt_node/decorator/bot_medical_flag,\
										"__c" = list(\
											/datum/bt_node/subtree/medbot_treat_patient\
										),\
										"flag" = MEDBOT_TIPPED_MODE,\
										"invert" = TRUE\
									)\
								)\
							),\
							list("__t" = /datum/bt_node/ai_behavior/handle_medbot_speech, "default_behavior_args" = list(BB_ANNOUNCE_ABILITY))\
						)\
					)\
				),\
				"flag" = MEDBOT_SPEAK_MODE\
			),\
			list(\
				"__t" = /datum/bt_node/decorator/bot_medical_flag,\
				"__c" = list(\
					/datum/bt_node/subtree/medbot_treat_patient\
				),\
				"flag" = MEDBOT_TIPPED_MODE,\
				"invert" = TRUE\
			),\
			/datum/bt_node/subtree/bot_salute_authority,\
			list(\
				"__t" = /datum/bt_node/decorator/key_off_cooldown,\
				"__c" = list(\
					/datum/bt_node/subtree/bot_patrol\
				),\
				"cooldown_key" = MEDBOT_STATIONARY_MODE\
			)\
		)\
	)
	// @bt-generated end
	ai_movement = /datum/ai_movement/jps/bot/medbot
	reset_keys = list(
		BB_PATIENT_TARGET,
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

// =============================================================================
// Find suitable patient (pure search)
// =============================================================================

/datum/bt_node/ai_behavior/find_suitable_patient
	action_cooldown = 2 SECONDS

/datum/bt_node/ai_behavior/find_suitable_patient/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key)
	var/mob/living/basic/bot/medbot/bot_pawn = controller.pawn
	var/threshold = bot_pawn.heal_threshold
	var/heal_type = bot_pawn.damage_type_healer
	var/mode_flags = bot_pawn.medical_mode_flags
	var/access_flags = bot_pawn.bot_access_flags
	var/search_range = (mode_flags & MEDBOT_STATIONARY_MODE) ? 1 : 7
	var/list/ignore_keys = controller.blackboard[BB_TEMPORARY_IGNORE_LIST]
	for(var/mob/living/carbon/human/treatable_target in oview(search_range, controller.pawn))
		if(LAZYACCESS(ignore_keys, treatable_target) || treatable_target.stat == DEAD)
			continue
		if((access_flags & BOT_COVER_EMAGGED) && treatable_target.stat == CONSCIOUS)
			controller.set_if_can_reach(key = target_key, target = treatable_target, distance = BOT_PATIENT_PATH_LIMIT, bypass_add_to_blacklist = (search_range == 1))
			break
		if((heal_type == HEAL_ALL_DAMAGE))
			if(treatable_target.get_total_damage() > threshold)
				controller.set_if_can_reach(key = target_key, target = treatable_target, distance = BOT_PATIENT_PATH_LIMIT, bypass_add_to_blacklist = (search_range == 1))
				break
			continue
		if(treatable_target.get_current_damage_of_type(damagetype = heal_type) > threshold)
			controller.set_if_can_reach(key = target_key, target = treatable_target, distance = BOT_PATIENT_PATH_LIMIT, bypass_add_to_blacklist = (search_range == 1))
			break

	if(controller.blackboard_key_exists(target_key))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[bot_pawn] find_suitable_patient: no patient found in range [search_range] (threshold=[threshold], heal_type=[heal_type], emagged=[!!(access_flags & BOT_COVER_EMAGGED)])")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/bt_node/ai_behavior/find_suitable_patient/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if(!succeeded || QDELETED(controller.pawn) || get_dist(controller.pawn, controller.blackboard[target_key]) <= 1)
		return
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[BB_ANNOUNCE_ABILITY]
	announcement?.announce(pick(controller.blackboard[BB_WAIT_SPEECH]))

// =============================================================================
// Tend to patient
// =============================================================================

/datum/bt_node/ai_behavior/tend_to_patient

/datum/bt_node/ai_behavior/tend_to_patient/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key)
	var/mob/living/carbon/human/patient = controller.blackboard[target_key]
	if(QDELETED(patient) || patient.stat == DEAD)
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[controller.pawn] tend_to_patient: patient gone (deleted=[QDELETED(patient)], stat=[patient?.stat])")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(get_dist(controller.pawn, patient) > 0)
		return AI_BEHAVIOR_INSTANT
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

/datum/bt_node/ai_behavior/tend_to_patient/finish_action(datum/ai_controller/basic_controller/bot/controller, succeeded, target_key)
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

// =============================================================================
// Medbot speech
// =============================================================================

/datum/bt_node/ai_behavior/handle_medbot_speech
	action_cooldown = 20 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/bt_node/ai_behavior/handle_medbot_speech/perform(seconds_per_tick, datum/ai_controller/controller, announce_key)
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

// =============================================================================
// Critical patient finder + announcer
// =============================================================================

/datum/bt_node/ai_behavior/find_patient_in_crit

/datum/bt_node/ai_behavior/find_patient_in_crit/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/source = controller.pawn
	for(var/mob/living/carbon/human/patient in oview(7, source))
		if(patient.stat < UNCONSCIOUS || isnull(patient.mind))
			continue
		if(!can_see(source, patient, 7))
			continue
		EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[source] found crit patient: [patient]", get_turf(patient), "Crit!")
		EVLOG_LINES(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "Crit patient", get_turf(source), get_turf(patient))
		controller.set_blackboard_key(target_key, patient)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[source] find_patient_in_crit: no crit patients in range")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/bt_node/ai_behavior/announce_patient
	action_cooldown = 3 MINUTES
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/bt_node/ai_behavior/announce_patient/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key)
	var/mob/living/living_target = controller.blackboard[target_key]
	if(QDELETED(living_target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[BB_ANNOUNCE_ABILITY]
	if(QDELETED(announcement))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/text_to_announce = "Medical emergency! [living_target] is in critical condition at [get_area(living_target)]!"
	announcement.announce(text_to_announce, controller.blackboard[BB_RADIO_CHANNEL])
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/announce_patient/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

#undef BOT_PATIENT_PATH_LIMIT
