///Opioids
/datum/addiction/opioids
	name = "opioid"
	withdrawal_stage_messages = list("I feel aches in my bodies..", "I need some pain relief...", "It aches all over...I need some opioids!")

/datum/addiction/opioids/withdrawal_stage_1_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	if(DT_PROB(10, delta_time))
		affected_carbon.emote("yawn")

/datum/addiction/opioids/withdrawal_enters_stage_2(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.apply_status_effect(/datum/status_effect/high_blood_pressure)

/datum/addiction/opioids/withdrawal_stage_3_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	if(affected_carbon.disgust < DISGUST_LEVEL_DISGUSTED && DT_PROB(7.5, delta_time))
		affected_carbon.adjust_disgust(12.5 * delta_time)

/datum/addiction/opioids/end_withdrawal(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.remove_status_effect(/datum/status_effect/high_blood_pressure)
	affected_carbon.set_disgust(affected_carbon.disgust * 0.5) //half their disgust to help

///Stimulants

/datum/addiction/stimulants
	name = "stimulant"
	withdrawal_stage_messages = list("You feel a bit tired...You could really use a pick me up.", "You are getting a bit woozy...", "So...Tired...")

/datum/addiction/stimulants/withdrawal_enters_stage_1(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.add_actionspeed_modifier(/datum/actionspeed_modifier/stimulants)

/datum/addiction/stimulants/withdrawal_enters_stage_2(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.apply_status_effect(/datum/status_effect/woozy)

/datum/addiction/stimulants/withdrawal_enters_stage_3(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.add_movespeed_modifier(/datum/movespeed_modifier/stimulants)

/datum/addiction/stimulants/end_withdrawal(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.remove_actionspeed_modifier(ACTIONSPEED_ID_STIMULANTS)
	affected_carbon.remove_status_effect(/datum/status_effect/woozy)
	affected_carbon.remove_movespeed_modifier(MOVESPEED_ID_STIMULANTS)

///Alcohol
/datum/addiction/alcohol
	name = "alcohol"
	withdrawal_stage_messages = list("I could use a drink...", "Maybe the bar is still open?..", "God I need a drink!")

/datum/addiction/alcohol/withdrawal_stage_1_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	affected_carbon.set_jitter_if_lower(10 SECONDS * delta_time)

/datum/addiction/alcohol/withdrawal_stage_2_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	affected_carbon.set_jitter_if_lower(20 SECONDS * delta_time)
	affected_carbon.set_hallucinations_if_lower(10 SECONDS)

/datum/addiction/alcohol/withdrawal_stage_3_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	affected_carbon.set_jitter_if_lower(30 SECONDS * delta_time)
	affected_carbon.set_hallucinations_if_lower(10 SECONDS)
	if(DT_PROB(4, delta_time) && !HAS_TRAIT(affected_carbon, TRAIT_ANTICONVULSANT))
		affected_carbon.apply_status_effect(/datum/status_effect/seizure)

/datum/addiction/hallucinogens
	name = "hallucinogen"
	withdrawal_stage_messages = list("I feel so empty...", "I wonder what the machine elves are up to?..", "I need to see the beautiful colors again!!")

/datum/addiction/hallucinogens/withdrawal_enters_stage_2(mob/living/carbon/affected_carbon)
	. = ..()
	var/atom/movable/plane_master_controller/game_plane_master_controller = affected_carbon.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.add_filter("hallucinogen_wave", 10, wave_filter(300, 300, 3, 0, WAVE_SIDEWAYS))
	game_plane_master_controller.add_filter("hallucinogen_blur", 10, angular_blur_filter(0, 0, 3))


/datum/addiction/hallucinogens/withdrawal_enters_stage_3(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.apply_status_effect(/datum/status_effect/trance, 40 SECONDS, TRUE)

/datum/addiction/hallucinogens/end_withdrawal(mob/living/carbon/affected_carbon)
	. = ..()
	var/atom/movable/plane_master_controller/game_plane_master_controller = affected_carbon.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.remove_filter("hallucinogen_blur")
	game_plane_master_controller.remove_filter("hallucinogen_wave")
	affected_carbon.remove_status_effect(/datum/status_effect/trance, 40 SECONDS, TRUE)

/datum/addiction/maintenance_drugs
	name = "maintenance drug"
	withdrawal_stage_messages = list("", "", "")

/datum/addiction/maintenance_drugs/withdrawal_enters_stage_1(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.apply_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)

/datum/addiction/maintenance_drugs/withdrawal_stage_1_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	if(DT_PROB(7.5, delta_time))
		affected_carbon.emote("growls")

/datum/addiction/maintenance_drugs/withdrawal_enters_stage_2(mob/living/carbon/affected_carbon)
	. = ..()
	if(!ishuman(affected_carbon))
		return
	var/mob/living/carbon/human/affected_human = affected_carbon
	if(affected_human.gender == MALE)
		to_chat(affected_human, span_warning("Your chin itches."))
		affected_human.facial_hairstyle = "Beard (Full)"
		affected_human.update_body_parts()
	//Only like gross food
	affected_human.dna?.species.liked_food = GROSS
	affected_human.dna?.species.disliked_food = NONE
	affected_human.dna?.species.toxic_food = ~GROSS

/datum/addiction/maintenance_drugs/withdrawal_enters_stage_3(mob/living/carbon/affected_carbon)
	. = ..()
	if(!ishuman(affected_carbon))
		return
	to_chat(affected_carbon, span_warning("You feel yourself adapt to the darkness."))
	var/mob/living/carbon/human/affected_human = affected_carbon
	var/obj/item/organ/internal/eyes/empowered_eyes = affected_human.getorgan(/obj/item/organ/internal/eyes)
	if(empowered_eyes)
		ADD_TRAIT(affected_human, TRAIT_NIGHT_VISION, "maint_drug_addiction")
		empowered_eyes?.refresh()

/datum/addiction/maintenance_drugs/withdrawal_stage_3_process(mob/living/carbon/affected_carbon, delta_time)
	if(!ishuman(affected_carbon))
		return
	var/mob/living/carbon/human/affected_human = affected_carbon
	var/turf/T = get_turf(affected_human)
	var/lums = T.get_lumcount()
	if(lums > 0.5)
		affected_human.add_mood_event("too_bright", /datum/mood_event/bright_light)
		affected_human.adjust_dizzy_up_to(6 SECONDS, 80 SECONDS)
		affected_human.adjust_confusion_up_to(0.5 SECONDS * delta_time, 20 SECONDS)
	else
		affected_carbon.clear_mood_event("too_bright")

/datum/addiction/maintenance_drugs/end_withdrawal(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)
	if(!ishuman(affected_carbon))
		return
	var/mob/living/carbon/human/affected_human = affected_carbon
	affected_human.dna?.species.liked_food = initial(affected_human.dna?.species.liked_food)
	affected_human.dna?.species.disliked_food = initial(affected_human.dna?.species.disliked_food)
	affected_human.dna?.species.toxic_food = initial(affected_human.dna?.species.toxic_food)
	REMOVE_TRAIT(affected_human, TRAIT_NIGHT_VISION, "maint_drug_addiction")
	var/obj/item/organ/internal/eyes/eyes = affected_human.getorgan(/obj/item/organ/internal/eyes)
	eyes.refresh()

///Makes you a hypochondriac - I'd like to call it hypochondria, but "I could use some hypochondria" doesn't work
/datum/addiction/medicine
	name = "medicine"
	withdrawal_stage_messages = list("", "", "")
	/// Weakref to the "fake alert" hallucination we're giving to the addicted
	var/datum/weakref/fake_alert_ref
	/// Weakref to the "health doll screwup" hallucination we're giving to the addicted
	var/datum/weakref/health_doll_ref

/datum/addiction/medicine/withdrawal_enters_stage_1(mob/living/carbon/affected_carbon)
	. = ..()
	if(!ishuman(affected_carbon))
		return
	var/datum/hallucination/health_doll = affected_carbon.cause_hallucination( \
		/datum/hallucination/fake_health_doll, \
		"medicine addiction", \
		severity = 1, \
		duration = 120 MINUTES, \
	)
	if(!health_doll)
		return
	health_doll_ref = WEAKREF(health_doll)

/datum/addiction/medicine/withdrawal_stage_1_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	if(DT_PROB(10, delta_time))
		affected_carbon.emote("cough")

/datum/addiction/medicine/withdrawal_enters_stage_2(mob/living/carbon/affected_carbon)
	. = ..()
	var/list/possibilities = list()

	if(!HAS_TRAIT(affected_carbon, TRAIT_RESISTHEAT))
		possibilities += /datum/hallucination/fake_alert/hot
	if(!HAS_TRAIT(affected_carbon, TRAIT_RESISTCOLD))
		possibilities += /datum/hallucination/fake_alert/cold

	var/obj/item/organ/internal/lungs/lungs = affected_carbon.getorganslot(ORGAN_SLOT_LUNGS)
	if(lungs)
		if(lungs.safe_oxygen_min)
			possibilities += /datum/hallucination/fake_alert/need_oxygen
		if(lungs.safe_oxygen_max)
			possibilities += /datum/hallucination/fake_alert/bad_oxygen

	if(!length(possibilities))
		return

	var/datum/hallucination/fake_alert = affected_carbon.cause_hallucination( \
		pick(possibilities), \
		"medicine addiction", \
		duration = 120 MINUTES, \
	)
	if(!fake_alert)
		return
	fake_alert_ref = WEAKREF(fake_alert)

/datum/addiction/medicine/withdrawal_stage_2_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	var/datum/hallucination/fake_health_doll/hallucination = health_doll_ref?.resolve()
	if(QDELETED(hallucination))
		health_doll_ref = null
		return

	if(DT_PROB(10, delta_time))
		hallucination.add_fake_limb(severity = 1)
		return

	if(DT_PROB(5, delta_time))
		hallucination.increment_fake_damage()
		return

/datum/addiction/medicine/withdrawal_enters_stage_3(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.apply_status_effect(/datum/status_effect/grouped/screwy_hud/fake_crit, type)

/datum/addiction/medicine/withdrawal_stage_3_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	var/datum/hallucination/fake_health_doll/hallucination = health_doll_ref?.resolve()
	if(!QDELETED(hallucination) && DT_PROB(5, delta_time))
		hallucination.increment_fake_damage()
		return

	if(DT_PROB(15, delta_time))
		affected_carbon.emote("cough")
		return

	if(DT_PROB(65, delta_time))
		return

	if(affected_carbon.stat >= SOFT_CRIT)
		return

	var/obj/item/organ/organ = pick(affected_carbon.organs)
	if(organ.low_threshold)
		to_chat(affected_carbon, organ.low_threshold_passed)
		return

	else if (organ.high_threshold_passed)
		to_chat(affected_carbon, organ.high_threshold_passed)
		return

	to_chat(affected_carbon, span_warning("You feel a dull pain in your [organ.name]."))

/datum/addiction/medicine/end_withdrawal(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_crit, type)
	QDEL_NULL(fake_alert_ref)
	QDEL_NULL(health_doll_ref)

///Nicotine
/datum/addiction/nicotine
	name = "nicotine"
	addiction_relief_treshold = MIN_NICOTINE_ADDICTION_REAGENT_AMOUNT //much less because your intake is probably from ciggies
	withdrawal_stage_messages = list("Feel like having a smoke...", "Getting antsy. Really need a smoke now.", "I can't take it! Need a smoke NOW!")

	medium_withdrawal_moodlet = /datum/mood_event/nicotine_withdrawal_moderate
	severe_withdrawal_moodlet = /datum/mood_event/nicotine_withdrawal_severe

/datum/addiction/nicotine/withdrawal_enters_stage_1(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	affected_carbon.set_jitter_if_lower(10 SECONDS * delta_time)

/datum/addiction/nicotine/withdrawal_stage_2_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	affected_carbon.set_jitter_if_lower(20 SECONDS * delta_time)
	if(DT_PROB(10, delta_time))
		affected_carbon.emote("cough")

/datum/addiction/nicotine/withdrawal_stage_3_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	affected_carbon.set_jitter_if_lower(30 SECONDS * delta_time)
	if(DT_PROB(15, delta_time))
		affected_carbon.emote("cough")
