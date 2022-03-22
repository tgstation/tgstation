//Here are the procs used to modify status effects of a mob.
//The effects include: stun, knockdown, unconscious, sleeping, resting, jitteriness, dizziness, ear damage,
//eye_blind, eye_blurry, druggy, TRAIT_BLIND trait, TRAIT_NEARSIGHT trait, and TRAIT_HUSK trait.


/mob/living/carbon/IsParalyzed(include_stamcrit = TRUE)
	return ..() || (include_stamcrit && HAS_TRAIT_FROM(src, TRAIT_INCAPACITATED, STAMINA))

/mob/living/carbon/proc/enter_stamcrit()
	if(!(status_flags & CANKNOCKDOWN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE))
		return
	if(HAS_TRAIT_FROM(src, TRAIT_INCAPACITATED, STAMINA)) //Already in stamcrit
		return
	if(absorb_stun(0)) //continuous effect, so we don't want it to increment the stuns absorbed.
		return
	to_chat(src, span_notice("You're too exhausted to keep going..."))
	ADD_TRAIT(src, TRAIT_INCAPACITATED, STAMINA)
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, STAMINA)
	ADD_TRAIT(src, TRAIT_FLOORED, STAMINA)
	if(getStaminaLoss() < 120) // Puts you a little further into the initial stamcrit, makes stamcrit harder to outright counter with chems.
		adjustStaminaLoss(30, FALSE)


/mob/living/carbon/adjust_drugginess(amount)
	druggy = max(druggy+amount, 0)
	if(druggy)
		overlay_fullscreen("high", /atom/movable/screen/fullscreen/high)
		throw_alert(ALERT_HIGH, /atom/movable/screen/alert/high)
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "high", /datum/mood_event/high)
		sound_environment_override = SOUND_ENVIRONMENT_DRUGGED
	else
		clear_fullscreen("high")
		clear_alert(ALERT_HIGH)
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "high")
		sound_environment_override = SOUND_ENVIRONMENT_NONE

/mob/living/carbon/set_drugginess(amount)
	druggy = max(amount, 0)
	if(druggy)
		overlay_fullscreen("high", /atom/movable/screen/fullscreen/high)
		throw_alert(ALERT_HIGH, /atom/movable/screen/alert/high)
	else
		clear_fullscreen("high")
		clear_alert(ALERT_HIGH)

/mob/living/carbon/adjust_disgust(amount)
	disgust = clamp(disgust+amount, 0, DISGUST_LEVEL_MAXEDOUT)

/mob/living/carbon/set_disgust(amount)
	disgust = clamp(amount, 0, DISGUST_LEVEL_MAXEDOUT)


////////////////////////////////////////TRAUMAS/////////////////////////////////////////

/mob/living/carbon/proc/get_traumas()
	. = list()
	var/obj/item/organ/brain/B = getorganslot(ORGAN_SLOT_BRAIN)
	if(B)
		. = B.traumas

/mob/living/carbon/proc/has_trauma_type(brain_trauma_type, resilience)
	var/obj/item/organ/brain/B = getorganslot(ORGAN_SLOT_BRAIN)
	if(B)
		. = B.has_trauma_type(brain_trauma_type, resilience)

/mob/living/carbon/proc/gain_trauma(datum/brain_trauma/trauma, resilience, ...)
	var/obj/item/organ/brain/B = getorganslot(ORGAN_SLOT_BRAIN)
	if(B)
		var/list/arguments = list()
		if(args.len > 2)
			arguments = args.Copy(3)
		. = B.brain_gain_trauma(trauma, resilience, arguments)

/mob/living/carbon/proc/gain_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience)
	var/obj/item/organ/brain/B = getorganslot(ORGAN_SLOT_BRAIN)
	if(B)
		. = B.gain_trauma_type(brain_trauma_type, resilience)

/mob/living/carbon/proc/cure_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience)
	var/obj/item/organ/brain/B = getorganslot(ORGAN_SLOT_BRAIN)
	if(B)
		. = B.cure_trauma_type(brain_trauma_type, resilience)

/mob/living/carbon/proc/cure_all_traumas(resilience)
	var/obj/item/organ/brain/B = getorganslot(ORGAN_SLOT_BRAIN)
	if(B)
		. = B.cure_all_traumas(resilience)
