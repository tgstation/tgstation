

/mob/living/carbon/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked = FALSE)
	var/hit_percent = (100-blocked)/100
	if(!damage || hit_percent <= 0)
		return 0

	var/obj/item/bodypart/BP = null
	if(isbodypart(def_zone)) //we specified a bodypart object
		BP = def_zone
	else
		if(!def_zone)
			def_zone = ran_zone(def_zone)
		BP = get_bodypart(check_zone(def_zone))
		if(!BP)
			BP = bodyparts[1]

	switch(damagetype)
		if(BRUTE)
			if(BP)
				if(BP.receive_damage(damage * hit_percent, 0))
					update_damage_overlays()
			else //no bodypart, we deal damage with a more general method.
				adjustBruteLoss(damage * hit_percent)
		if(BURN)
			if(BP)
				if(BP.receive_damage(0, damage * hit_percent))
					update_damage_overlays()
			else
				adjustFireLoss(damage * hit_percent)
		if(TOX)
			adjustToxLoss(damage * hit_percent)
		if(OXY)
			adjustOxyLoss(damage * hit_percent)
		if(CLONE)
			adjustCloneLoss(damage * hit_percent)
		if(STAMINA)
			if(BP)
				if(BP.receive_damage(0, 0, damage * hit_percent))
					update_damage_overlays()
			else
				adjustStaminaLoss(damage * hit_percent)
		if(BRAIN)
			adjustBrainLoss(damage * hit_percent)
	return TRUE


//These procs fetch a cumulative total damage from all bodyparts
/mob/living/carbon/getBruteLoss()
	var/amount = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		amount += BP.brute_dam
	return amount

/mob/living/carbon/getFireLoss()
	var/amount = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		amount += BP.burn_dam
	return amount


/mob/living/carbon/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	if(amount > 0)
		take_overall_damage(amount, 0, 0, updating_health)
	else
		heal_overall_damage(abs(amount), 0, 0, FALSE, TRUE, updating_health)
	return amount

/mob/living/carbon/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	if(amount > 0)
		take_overall_damage(0, amount, 0, updating_health)
	else
		heal_overall_damage(0, abs(amount), 0, FALSE, TRUE, updating_health)
	return amount

/mob/living/carbon/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && has_trait(TRAIT_TOXINLOVER)) //damage becomes healing and healing becomes damage
		amount = -amount
		if(amount > 0)
			blood_volume -= 5*amount
		else
			blood_volume -= amount
	return ..()

/mob/living/carbon/getStaminaLoss()
	. = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		. += round(BP.stamina_dam * BP.stam_damage_coeff, DAMAGE_PRECISION)

/mob/living/carbon/adjustStaminaLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	if(amount > 0)
		take_overall_damage(0, 0, amount, updating_health)
	else
		heal_overall_damage(0, 0, abs(amount), FALSE, FALSE, updating_health)
	return amount

/mob/living/carbon/setStaminaLoss(amount, updating = TRUE, forced = FALSE)
	var/current = getStaminaLoss()
	var/diff = amount - current
	if(!diff)
		return
	adjustStaminaLoss(diff, updating, forced)

////////////////////////////////////////////

//Returns a list of damaged bodyparts
/mob/living/carbon/proc/get_damaged_bodyparts(brute = FALSE, burn = FALSE, stamina = FALSE, status)
	var/list/obj/item/bodypart/parts = list()
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		if(status && BP.status != status)
			continue
		if((brute && BP.brute_dam) || (burn && BP.burn_dam) || (stamina && BP.stamina_dam))
			parts += BP
	return parts

//Returns a list of damageable bodyparts
/mob/living/carbon/proc/get_damageable_bodyparts()
	var/list/obj/item/bodypart/parts = list()
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.brute_dam + BP.burn_dam < BP.max_damage)
			parts += BP
	return parts

//Heals ONE bodypart randomly selected from damaged ones.
//It automatically updates damage overlays if necessary
//It automatically updates health status
/mob/living/carbon/heal_bodypart_damage(brute = 0, burn = 0, stamina = 0, updating_health = TRUE, only_robotic = FALSE, only_organic = TRUE)
	var/list/obj/item/bodypart/parts = get_damaged_bodyparts(brute,burn)
	if(!parts.len)
		return
	var/obj/item/bodypart/picked = pick(parts)
	if(picked.heal_damage(brute, burn, stamina, only_robotic, only_organic))
		update_damage_overlays()

//Damages ONE bodypart randomly selected from damagable ones.
//It automatically updates damage overlays if necessary
//It automatically updates health status
/mob/living/carbon/take_bodypart_damage(brute = 0, burn = 0, stamina = 0)
	var/list/obj/item/bodypart/parts = get_damageable_bodyparts()
	if(!parts.len)
		return
	var/obj/item/bodypart/picked = pick(parts)
	if(picked.receive_damage(brute, burn, stamina))
		update_damage_overlays()

//Heal MANY bodyparts, in random order
/mob/living/carbon/heal_overall_damage(brute = 0, burn = 0, stamina = 0, only_robotic = FALSE, only_organic = TRUE, updating_health = TRUE)
	var/list/obj/item/bodypart/parts = get_damaged_bodyparts(brute, burn, stamina)

	var/update = NONE
	while(parts.len && (brute > 0 || burn > 0 || stamina > 0))
		var/obj/item/bodypart/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam
		var/stamina_was = picked.stamina_dam

		update |= picked.heal_damage(brute, burn, stamina, only_robotic, only_organic, FALSE)

		brute = round(brute - (brute_was - picked.brute_dam), DAMAGE_PRECISION)
		burn = round(burn - (burn_was - picked.burn_dam), DAMAGE_PRECISION)
		stamina = round(stamina - (stamina_was - picked.stamina_dam), DAMAGE_PRECISION)

		parts -= picked
	if(updating_health)
		updatehealth()
		update_stamina()
	if(update)
		update_damage_overlays()

// damage MANY bodyparts, in random order
/mob/living/carbon/take_overall_damage(brute = 0, burn = 0, stamina = 0, updating_health = TRUE)
	if(status_flags & GODMODE)
		return	//godmode

	var/list/obj/item/bodypart/parts = get_damageable_bodyparts()
	var/update = 0
	while(parts.len && (brute > 0 || burn > 0 || stamina > 0))
		var/obj/item/bodypart/picked = pick(parts)
		var/brute_per_part = round(brute/parts.len, DAMAGE_PRECISION)
		var/burn_per_part = round(burn/parts.len, DAMAGE_PRECISION)
		var/stamina_per_part = round(stamina/parts.len, DAMAGE_PRECISION)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam
		var/stamina_was = picked.stamina_dam


		update |= picked.receive_damage(brute_per_part, burn_per_part, stamina_per_part, FALSE)

		brute	= round(brute - (picked.brute_dam - brute_was), DAMAGE_PRECISION)
		burn	= round(burn - (picked.burn_dam - burn_was), DAMAGE_PRECISION)
		stamina = round(stamina - (picked.stamina_dam - stamina_was), DAMAGE_PRECISION)

		parts -= picked
	if(updating_health)
		updatehealth()
	if(update)
		update_damage_overlays()
	update_stamina()

/mob/living/carbon/getBrainLoss()
	. = 0
	var/obj/item/organ/brain/B = getorganslot(ORGAN_SLOT_BRAIN)
	if(B)
		. = B.get_brain_damage()

//Some sources of brain damage shouldn't be deadly
/mob/living/carbon/adjustBrainLoss(amount, maximum = BRAIN_DAMAGE_DEATH)
	if(status_flags & GODMODE)
		return FALSE
	var/prev_brainloss = getBrainLoss()
	var/obj/item/organ/brain/B = getorganslot(ORGAN_SLOT_BRAIN)
	if(!B)
		return
	B.adjust_brain_damage(amount, maximum)
	if(amount <= 0) //cut this early
		return
	var/brainloss = getBrainLoss()
	if(brainloss > BRAIN_DAMAGE_MILD)
		if(prob(amount * ((2 * (100 + brainloss - BRAIN_DAMAGE_MILD)) / 100))) //Base chance is the hit damage; for every point of damage past the threshold the chance is increased by 2%
			gain_trauma_type(BRAIN_TRAUMA_MILD)
	if(brainloss > BRAIN_DAMAGE_SEVERE)
		if(prob(amount * ((2 * (100 + brainloss - BRAIN_DAMAGE_SEVERE)) / 100))) //Base chance is the hit damage; for every point of damage past the threshold the chance is increased by 2%
			if(prob(20))
				gain_trauma_type(BRAIN_TRAUMA_SPECIAL)
			else
				gain_trauma_type(BRAIN_TRAUMA_SEVERE)

	if(prev_brainloss < BRAIN_DAMAGE_MILD && brainloss >= BRAIN_DAMAGE_MILD)
		to_chat(src, "<span class='warning'>You feel lightheaded.</span>")
	else if(prev_brainloss < BRAIN_DAMAGE_SEVERE && brainloss >= BRAIN_DAMAGE_SEVERE)
		to_chat(src, "<span class='warning'>You feel less in control of your thoughts.</span>")
	else if(prev_brainloss < (BRAIN_DAMAGE_DEATH - 20) && brainloss >= (BRAIN_DAMAGE_DEATH - 20))
		to_chat(src, "<span class='warning'>You can feel your mind flickering on and off...</span>")

/mob/living/carbon/setBrainLoss(amount)
	var/obj/item/organ/brain/B = getorganslot(ORGAN_SLOT_BRAIN)
	if(B)
		var/adjusted_amount = amount - B.get_brain_damage()
		B.adjust_brain_damage(adjusted_amount, null)
