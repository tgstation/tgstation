#define BOT_PATIENT_PATH_LIMIT 20
/datum/ai_controller/basic_controller/bot/medbot
	planning_subtrees = list(
		/datum/ai_planning_subtree/respond_to_summon,
		/datum/ai_planning_subtree/handle_medbot_speech,
		/datum/ai_planning_subtree/find_and_hunt_target/patients_in_crit,
		/datum/ai_planning_subtree/treat_wounded_target,
		/datum/ai_planning_subtree/salute_authority,
		/datum/ai_planning_subtree/find_patrol_beacon/medbot,
	)
	ai_movement = /datum/ai_movement/jps/bot/medbot
	reset_keys = list(
		BB_PATIENT_TARGET,
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_BOT_SUMMON_TARGET,
	)
	ai_traits = PAUSE_DURING_DO_AFTER

/datum/ai_movement/jps/bot/medbot
	maximum_length = BOT_PATIENT_PATH_LIMIT
	max_pathing_attempts = 20

// only AI isnt allowed to move when this flag is set, sentient players can
/datum/ai_movement/jps/bot/medbot/allowed_to_move(datum/move_loop/source)
	var/datum/ai_controller/controller = source.extra_info
	var/mob/living/basic/bot/medbot/bot_pawn = controller.pawn
	if(bot_pawn.medical_mode_flags & MEDBOT_STATIONARY_MODE)
		return FALSE
	return ..()

/datum/ai_movement/jps/bot/medbot/travel_to_beacon
	maximum_length = AI_BOT_PATH_LENGTH


/datum/ai_planning_subtree/treat_wounded_target

/datum/ai_planning_subtree/treat_wounded_target/SelectBehaviors(datum/ai_controller/basic_controller/bot/controller, seconds_per_tick)
	var/mob/living/basic/bot/medbot/bot_pawn = controller.pawn
	if(bot_pawn.medical_mode_flags & MEDBOT_TIPPED_MODE)
		controller.clear_blackboard_key(BB_PATIENT_TARGET)
		return
	var/is_stationary = bot_pawn.medical_mode_flags & MEDBOT_STATIONARY_MODE
	if(controller.blackboard_key_exists(BB_PATIENT_TARGET))
		controller.queue_behavior(/datum/ai_behavior/tend_to_patient, BB_PATIENT_TARGET, bot_pawn.heal_threshold, bot_pawn.damage_type_healer, bot_pawn.bot_access_flags, is_stationary)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.queue_behavior(/datum/ai_behavior/find_suitable_patient, BB_PATIENT_TARGET, bot_pawn.heal_threshold, bot_pawn.damage_type_healer, bot_pawn.medical_mode_flags, bot_pawn.bot_access_flags)

/datum/ai_behavior/find_suitable_patient
	var/search_range = 7
	action_cooldown = 2 SECONDS

/datum/ai_behavior/find_suitable_patient/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key, threshold, heal_type, mode_flags, access_flags)
	search_range = (mode_flags & MEDBOT_STATIONARY_MODE) ? 1 : initial(search_range)
	var/list/ignore_keys = controller.blackboard[BB_TEMPORARY_IGNORE_LIST]
	for(var/mob/living/carbon/human/treatable_target in oview(search_range, controller.pawn))
		if(LAZYACCESS(ignore_keys, treatable_target) || treatable_target.stat == DEAD)
			continue
		if((access_flags & BOT_COVER_EMAGGED) && treatable_target.stat == CONSCIOUS)
			controller.set_if_can_reach(key = BB_PATIENT_TARGET, target = treatable_target, distance = BOT_PATIENT_PATH_LIMIT, bypass_add_to_blacklist = (search_range == 1))
			break
		if((heal_type == HEAL_ALL_DAMAGE))
			if(treatable_target.get_total_damage() > threshold)
				controller.set_if_can_reach(key = BB_PATIENT_TARGET, target = treatable_target, distance = BOT_PATIENT_PATH_LIMIT, bypass_add_to_blacklist = (search_range == 1))
				break
			continue
		if(treatable_target.get_current_damage_of_type(damagetype = heal_type) > threshold)
			controller.set_if_can_reach(key = BB_PATIENT_TARGET, target = treatable_target, distance = BOT_PATIENT_PATH_LIMIT, bypass_add_to_blacklist = (search_range == 1))
			break

	if(controller.blackboard_key_exists(BB_PATIENT_TARGET))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	else
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/ai_behavior/find_suitable_patient/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if(!succeeded || QDELETED(controller.pawn) ||get_dist(controller.pawn, controller.blackboard[target_key]) <= 1)
		return
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[BB_ANNOUNCE_ABILITY]
	announcement?.announce(pick(controller.blackboard[BB_WAIT_SPEECH]))

/datum/ai_behavior/tend_to_patient
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/tend_to_patient/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/tend_to_patient/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key, threshold, damage_type_healer, access_flags, is_stationary)
	var/mob/living/carbon/human/patient = controller.blackboard[target_key]
	if(QDELETED(patient) || patient.stat == DEAD)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(check_if_healed(patient, threshold, damage_type_healer, access_flags))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	var/mob/living/basic/bot/bot_pawn = controller.pawn
	if(patient.stat >= HARD_CRIT && prob(5))
		var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[BB_ANNOUNCE_ABILITY]
		announcement?.announce(pick(controller.blackboard[BB_NEAR_DEATH_SPEECH]))
	bot_pawn.melee_attack(patient)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

// only clear the target if they get healed
/datum/ai_behavior/tend_to_patient/finish_action(datum/ai_controller/basic_controller/bot/controller, succeeded, target_key, threshold, damage_type_healer, access_flags, is_stationary)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(!succeeded)

		if(!isnull(target) && !is_stationary)
			controller.add_to_blacklist(target)

		controller.clear_blackboard_key(target_key)
		return

	if(QDELETED(target) || !check_if_healed(target, threshold, damage_type_healer, access_flags))
		return

	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[BB_ANNOUNCE_ABILITY]
	announcement?.announce(pick(controller.blackboard[BB_AFTERHEAL_SPEECH]))
	controller.clear_blackboard_key(target_key)

/datum/ai_behavior/tend_to_patient/proc/check_if_healed(mob/living/carbon/human/patient, threshold, damage_type_healer, access_flags)
	if(access_flags & BOT_COVER_EMAGGED)
		return (patient.stat > CONSCIOUS)
	var/patient_damage = (damage_type_healer == HEAL_ALL_DAMAGE) ? patient.get_total_damage() : patient.get_current_damage_of_type(damagetype = damage_type_healer)
	return (patient_damage <= threshold)


/datum/ai_planning_subtree/handle_medbot_speech
	var/speech_chance = 5

/datum/ai_planning_subtree/handle_medbot_speech/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/bot/medbot/bot_pawn = controller.pawn
	//we cant speak!
	if(!(bot_pawn.medical_mode_flags & MEDBOT_SPEAK_MODE))
		return

	var/currently_tipped = bot_pawn.medical_mode_flags & MEDBOT_TIPPED_MODE
	speech_chance = ((bot_pawn.bot_access_flags & BOT_COVER_EMAGGED) || currently_tipped) ? 15 : initial(speech_chance)

	if(!SPT_PROB(speech_chance, seconds_per_tick))
		return

	controller.queue_behavior(/datum/ai_behavior/handle_medbot_speech, BB_ANNOUNCE_ABILITY, bot_pawn.mode, bot_pawn.bot_access_flags, currently_tipped)

/datum/ai_behavior/handle_medbot_speech
	action_cooldown = 20 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/handle_medbot_speech/perform(seconds_per_tick, datum/ai_controller/controller, announce_key, mode, cover_flags, currently_tipped)
	. = ..()
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[announce_key]
	var/list/speech_to_pick_from

	if(currently_tipped)
		speech_to_pick_from = controller.blackboard[BB_WORRIED_ANNOUNCEMENTS]
	else if(cover_flags & BOT_COVER_EMAGGED)
		speech_to_pick_from = controller.blackboard[BB_EMAGGED_SPEECH]
	else if(mode == BOT_IDLE)
		speech_to_pick_from = controller.blackboard[BB_IDLE_SPEECH]
	var/mob/living/living_pawn = controller.pawn

	if(locate(/obj/item/clothing/head/costume/chicken) in living_pawn)
		speech_to_pick_from += MEDIBOT_VOICED_CHICKEN

	if(!length(speech_to_pick_from))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	announcement.announce(pick(speech_to_pick_from))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_planning_subtree/find_and_hunt_target/patients_in_crit
	target_key = BB_PATIENT_IN_CRIT
	hunting_behavior = /datum/ai_behavior/announce_patient
	finding_behavior = /datum/ai_behavior/find_hunt_target/patient_in_crit
	hunt_targets = list(/mob/living/carbon/human)
	finish_planning = FALSE

/datum/ai_planning_subtree/find_and_hunt_target/patients_in_crit/SelectBehaviors(datum/ai_controller/basic_controller/bot/controller, seconds_per_tick)
	var/mob/living/basic/bot/medbot/bot_pawn = controller.pawn
	if(!(bot_pawn.medical_mode_flags & MEDBOT_DECLARE_CRIT))
		return
	return ..()

/datum/ai_behavior/find_hunt_target/patient_in_crit

/datum/ai_behavior/find_hunt_target/patient_in_crit/valid_dinner(mob/living/source, mob/living/carbon/human/patient, radius)
	if(patient.stat < UNCONSCIOUS || isnull(patient.mind))
		return FALSE
	return can_see(source, patient, radius)

/datum/ai_behavior/announce_patient
	action_cooldown = 3 MINUTES
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/announce_patient/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller, target_key)
	var/mob/living/living_target = controller.blackboard[target_key]
	if(QDELETED(living_target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[BB_ANNOUNCE_ABILITY]
	if(QDELETED(announcement))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/text_to_announce = "Medical emergency! [living_target] is in critical condition at [get_area(living_target)]!"
	announcement.announce(text_to_announce, controller.blackboard[BB_RADIO_CHANNEL])
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/announce_patient/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/datum/ai_planning_subtree/find_patrol_beacon/medbot
	///travel towards beacon behavior
	travel_behavior = /datum/ai_behavior/travel_towards/beacon/medbot

/datum/ai_planning_subtree/find_patrol_beacon/medbot/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/bot/medbot/bot_pawn = controller.pawn
	if(bot_pawn.medical_mode_flags & MEDBOT_STATIONARY_MODE)
		return
	return ..()


/datum/ai_behavior/travel_towards/beacon/medbot
	new_movement_type = /datum/ai_movement/jps/bot/medbot/travel_to_beacon

#undef BOT_PATIENT_PATH_LIMIT
