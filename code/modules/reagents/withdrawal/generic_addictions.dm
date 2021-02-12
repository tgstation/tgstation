///Opiods
/datum/addiction/opiods
	name = "opiod"
	withdrawal_stage_messages = list("I feel aches in my bodies..", "I need some opiods...", "It aches all over...I need some opiods!")

/datum/addiction/opiods/withdrawal_stage_1_process(mob/living/carbon/affected_carbon)
	. = ..()
	if(prob(40))
		affected_carbon.emote("yawn")

/datum/addiction/opiods/withdrawal_enters_stage_2(var/mob/living/carbon/affected_carbon)
	affected_carbon.apply_status_effect(STATUS_EFFECT_HIGHBLOODPRESSURE)

/datum/addiction/opiods/withdrawal_stage_3_process(var/mob/living/carbon/affected_carbon)
	if(affected_carbon.disgust < DISGUST_LEVEL_DISGUSTED)
		affected_carbon.adjust_disgust(5)


/datum/addiction/opiods/lose_addiction(var/mob/living/carbon/affected_carbon)
	affected_carbon.remove_status_effect(STATUS_EFFECT_HIGHBLOODPRESSURE)

///Stimulants

/datum/addiction/stimulants
	name = "stimulant"
	withdrawal_stage_messages = list("You feel a bit tired...You could really use a pick me up.", "You are getting a bit woozy...", "So...Tired...")

/datum/addiction/stimulants/withdrawal_enters_stage_1(var/mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.add_actionspeed_modifier(/datum/actionspeed_modifier/stimulants)

/datum/addiction/stimulants/withdrawal_enters_stage_2(var/mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.apply_status_effect(STATUS_EFFECT_WOOZY)

/datum/addiction/stimulants/withdrawal_enters_stage_3(var/mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.add_movespeed_modifier(/datum/movespeed_modifier/stimulants)

/datum/addiction/stimulants/lose_addiction(var/mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.remove_actionspeed_modifier(ACTIONSPEED_ID_STIMULANTS)
	affected_carbon.remove_status_effect(STATUS_EFFECT_WOOZY)
	affected_carbon.remove_movespeed_modifier(MOVESPEED_ID_STIMULANTS)

///Alcohol
/datum/addiction/alcohol
	name = "alcohol"
	withdrawal_stage_messages = list("I could use a drink...", "I hope the bar is still open...", "God I need a drink!")

/datum/addiction/alcohol/withdrawal_stage_1_process(var/mob/living/carbon/affected_carbon)
	affected_carbon.Jitter(10)

/datum/addiction/alcohol/withdrawal_stage_2_process(var/mob/living/carbon/affected_carbon)
	affected_carbon.Jitter(10)
	affected_carbon.hallucination = max(5 SECONDS, affected_carbon.hallucination)

/datum/addiction/alcohol/withdrawal_stage_3_process(var/mob/living/carbon/affected_carbon)
	affected_carbon.Jitter(10)
	affected_carbon.hallucination = max(5 SECONDS, affected_carbon.hallucination)
	if(prob(5)) // Once every 40 seconds in theory
		affected_carbon.apply_status_effect(STATUS_EFFECT_SEIZURE)

/datum/addiction/hallucinogens
	name = "hallucinogen"
	withdrawal_stage_messages = list("I feel so empty...", "I havn't seen the little elves in so long...", "I need to see the beautiful colors again!!")

/datum/addiction/hallucinogens/withdrawal_enters_stage_2(mob/living/carbon/affected_carbon)


/datum/addiction/hallucinogens/withdrawal_enters_stage_3(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.apply_status_effect(/datum/status_effect/trance, 40 SECONDS, TRUE)

/datum/addiction/maintenance_drugs
	name = "maintenance drug"
