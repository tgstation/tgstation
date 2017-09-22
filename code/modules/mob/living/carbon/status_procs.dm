//Here are the procs used to modify status effects of a mob.
//The effects include: stun, knockdown, unconscious, sleeping, resting, jitteriness, dizziness, ear damage,
// eye damage, eye_blind, eye_blurry, druggy, BLIND disability, NEARSIGHT disability, and HUSK disability.

/mob/living/carbon/damage_eyes(amount)
	var/obj/item/organ/eyes/eyes = getorganslot("eye_sight")
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
	var/obj/item/organ/eyes/eyes = getorganslot("eye_sight")
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
	var/obj/item/organ/eyes/eyes = getorganslot("eye_sight")
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
	var/old_druggy = druggy
	if(amount>0)
		druggy += amount
		if(!old_druggy)
			overlay_fullscreen("high", /obj/screen/fullscreen/high)
			throw_alert("high", /obj/screen/alert/high)
	else if(old_druggy)
		druggy = max(druggy+amount, 0)
		if(!druggy)
			clear_fullscreen("high")
			clear_alert("high")
/mob/living/carbon/set_drugginess(amount)
	var/old_druggy = druggy
	druggy = amount
	if(amount>0)
		if(!old_druggy)
			overlay_fullscreen("high", /obj/screen/fullscreen/high)
			throw_alert("high", /obj/screen/alert/high)
	else if(old_druggy)
		clear_fullscreen("high")
		clear_alert("high")

/mob/living/carbon/adjust_disgust(amount)
	var/old_disgust = disgust
	if(amount>0)
		disgust = min(disgust+amount, DISGUST_LEVEL_MAXEDOUT)

	else if(old_disgust)
		disgust = max(disgust+amount, 0)

/mob/living/carbon/set_disgust(amount)
	if(amount >= 0)
		disgust = amount

/mob/living/carbon/cure_blind()
	if(disabilities & BLIND)
		disabilities &= ~BLIND
		adjust_blindness(-1)
		return 1
/mob/living/carbon/become_blind()
	if(!(disabilities & BLIND))
		disabilities |= BLIND
		blind_eyes(1)
		return 1

/mob/living/carbon/cure_nearsighted()
	if(disabilities & NEARSIGHT)
		disabilities &= ~NEARSIGHT
		clear_fullscreen("nearsighted")
		return 1

/mob/living/carbon/become_nearsighted()
	if(!(disabilities & NEARSIGHT))
		disabilities |= NEARSIGHT
		overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
		return 1

/mob/living/carbon/cure_husk()
	if(disabilities & HUSK)
		disabilities &= ~HUSK
		status_flags &= ~DISFIGURED
		update_body()
		return 1

/mob/living/carbon/become_husk()
	if(disabilities & HUSK)
		return
	disabilities |= HUSK
	status_flags |= DISFIGURED	//makes them unknown
	update_body()
	return 1
