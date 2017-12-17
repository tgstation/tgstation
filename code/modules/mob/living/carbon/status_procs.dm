//Here are the procs used to modify status effects of a mob.
//The effects include: stun, knockdown, unconscious, sleeping, resting, jitteriness, dizziness, ear damage,
// eye damage, eye_blind, eye_blurry, druggy, BLIND disability, NEARSIGHT disability, and HUSK disability.

/mob/living/carbon/damage_eyes(amount)
	var/obj/item/organ/eyes/eyes = getorganslot(ORGAN_SLOT_EYES)
	if (!eyes)
		return
	if(amount>0)
		eyes.eye_damage = amount
		if(eyes.eye_damage > 20)
			if(eyes.eye_damage > 30)
				overlay_fullscreen("eye_damage", /obj/screen/fullscreen/impaired, 2)
			else
				overlay_fullscreen("eye_damage", /obj/screen/fullscreen/impaired, 1)

/mob/living/carbon/set_eye_damage(amount)
	var/obj/item/organ/eyes/eyes = getorganslot(ORGAN_SLOT_EYES)
	if (!eyes)
		return
	eyes.eye_damage = max(amount,0)
	if(eyes.eye_damage > 20)
		if(eyes.eye_damage > 30)
			overlay_fullscreen("eye_damage", /obj/screen/fullscreen/impaired, 2)
		else
			overlay_fullscreen("eye_damage", /obj/screen/fullscreen/impaired, 1)
	else
		clear_fullscreen("eye_damage")

/mob/living/carbon/adjust_eye_damage(amount)
	var/obj/item/organ/eyes/eyes = getorganslot(ORGAN_SLOT_EYES)
	if (!eyes)
		return
	eyes.eye_damage = max(eyes.eye_damage+amount, 0)
	if(eyes.eye_damage > 20)
		if(eyes.eye_damage > 30)
			overlay_fullscreen("eye_damage", /obj/screen/fullscreen/impaired, 2)
		else
			overlay_fullscreen("eye_damage", /obj/screen/fullscreen/impaired, 1)
	else
		clear_fullscreen("eye_damage")

/mob/living/carbon/adjust_drugginess(amount)
	druggy = max(druggy+amount, 0)
	if(druggy)
		overlay_fullscreen("high", /obj/screen/fullscreen/high)
		throw_alert("high", /obj/screen/alert/high)
	else
		clear_fullscreen("high")
		clear_alert("high")

/mob/living/carbon/set_drugginess(amount)
	druggy = max(amount, 0)
	if(druggy)
		overlay_fullscreen("high", /obj/screen/fullscreen/high)
		throw_alert("high", /obj/screen/alert/high)
	else
		clear_fullscreen("high")
		clear_alert("high")

/mob/living/carbon/adjust_disgust(amount)
	disgust = CLAMP(disgust+amount, 0, DISGUST_LEVEL_MAXEDOUT)

/mob/living/carbon/set_disgust(amount)
	disgust = CLAMP(amount, 0, DISGUST_LEVEL_MAXEDOUT)



/////////////////////////////////// DISABILITIES ////////////////////////////////////

/mob/living/carbon/add_disability(disability, source)
	if(!disabilities[disability])
		disabilities[disability] = list(source)
	else
		disabilities[disability] |= list(source)

/mob/living/carbon/remove_disability(disability, list/sources)
	if(!disabilities[disability])
		return

	if(LAZYLEN(sources))
		for(var/S in sources)
			if(S in disabilities[disability])
				disabilities[disability] -= S
	else
		disabilities[disability] = list()

	if(!LAZYLEN(disabilities[disability]))
		disabilities -= disability

/mob/living/carbon/has_disability(disability, list/sources)
	if(!disabilities[disability])
		return FALSE

	. = FALSE

	if(LAZYLEN(sources))
		for(var/S in sources)
			if(S in disabilities[disability])
				return TRUE
	else
		if(LAZYLEN(disabilities[disability]))
			return TRUE

/mob/living/carbon/remove_all_disabilities()
	disabilities = list()

/////////////////////////////////// DISABILITY PROCS ////////////////////////////////////

/mob/living/carbon/cure_blind(list/sources)
	remove_disability(BLIND, sources)
	if(!has_disability(BLIND))
		adjust_blindness(-1)

/mob/living/carbon/become_blind(source)
	if(!has_disability(BLIND))
		blind_eyes(1)
	add_disability(BLIND, source)

/mob/living/carbon/cure_nearsighted(list/sources)
	remove_disability(NEARSIGHT, sources)
	if(!has_disability(NEARSIGHT))
		clear_fullscreen("nearsighted")

/mob/living/carbon/become_nearsighted(source)
	if(!has_disability(NEARSIGHT))
		overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
	add_disability(NEARSIGHT, source)

/mob/living/carbon/cure_husk(list/sources)
	remove_disability(HUSK, sources)
	if(!has_disability(HUSK))
		status_flags &= ~DISFIGURED
		update_body()

/mob/living/carbon/become_husk(source)
	if(!has_disability(HUSK))
		status_flags |= DISFIGURED	//makes them unknown
		update_body()
	add_disability(HUSK, source)

/mob/living/carbon/proc/get_traumas()
	. = list()
	var/obj/item/organ/brain/B = getorganslot(ORGAN_SLOT_BRAIN)
	if(B)
		. = B.traumas

/mob/living/carbon/proc/has_trauma_type(brain_trauma_type, consider_permanent = FALSE)
	var/obj/item/organ/brain/B = getorganslot(ORGAN_SLOT_BRAIN)
	if(B)
		. = B.has_trauma_type(brain_trauma_type, consider_permanent)

/mob/living/carbon/proc/gain_trauma(datum/brain_trauma/trauma, permanent = FALSE, list/arguments)
	var/obj/item/organ/brain/B = getorganslot(ORGAN_SLOT_BRAIN)
	if(B)
		. = B.gain_trauma(trauma, permanent, arguments)

/mob/living/carbon/proc/gain_trauma_type(brain_trauma_type = /datum/brain_trauma, permanent = FALSE)
	var/obj/item/organ/brain/B = getorganslot(ORGAN_SLOT_BRAIN)
	if(B)
		. = B.gain_trauma_type(brain_trauma_type, permanent)

/mob/living/carbon/proc/cure_trauma_type(brain_trauma_type, cure_permanent = FALSE)
	var/obj/item/organ/brain/B = getorganslot(ORGAN_SLOT_BRAIN)
	if(B)
		. = B.cure_trauma_type(brain_trauma_type, cure_permanent)

/mob/living/carbon/proc/cure_all_traumas(cure_permanent = FALSE)
	var/obj/item/organ/brain/B = getorganslot(ORGAN_SLOT_BRAIN)
	if(B)
		. = B.cure_all_traumas(cure_permanent)

