

/mob/living/carbon/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked = 0)
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
			adjustStaminaLoss(damage * hit_percent)
	return 1


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
		take_overall_damage(amount, 0, updating_health)
	else
		heal_overall_damage(-amount, 0, 0, 1, updating_health)
	return amount

/mob/living/carbon/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	if(amount > 0)
		take_overall_damage(0, amount, updating_health)
	else
		heal_overall_damage(0, -amount, 0, 1, updating_health)
	return amount


/mob/living/carbon/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && has_dna() && TOXINLOVER in dna.species.species_traits) //damage becomes healing and healing becomes damage
		amount = -amount
		if(amount > 0)
			blood_volume -= 5*amount
		else
			blood_volume -= amount
	return ..()

////////////////////////////////////////////

//Returns a list of damaged bodyparts
/mob/living/carbon/proc/get_damaged_bodyparts(brute, burn)
	var/list/obj/item/bodypart/parts = list()
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		if((brute && BP.brute_dam) || (burn && BP.burn_dam))
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
/mob/living/carbon/heal_bodypart_damage(brute, burn, only_robotic = 0, only_organic = 1)
	var/list/obj/item/bodypart/parts = get_damaged_bodyparts(brute,burn)
	if(!parts.len)
		return
	var/obj/item/bodypart/picked = pick(parts)
	if(picked.heal_damage(brute, burn, only_robotic, only_organic))
		update_damage_overlays()

//Damages ONE bodypart randomly selected from damagable ones.
//It automatically updates damage overlays if necessary
//It automatically updates health status
/mob/living/carbon/take_bodypart_damage(brute, burn)
	var/list/obj/item/bodypart/parts = get_damageable_bodyparts()
	if(!parts.len)
		return
	var/obj/item/bodypart/picked = pick(parts)
	if(picked.receive_damage(brute,burn))
		update_damage_overlays()


//Heal MANY bodyparts, in random order
/mob/living/carbon/heal_overall_damage(brute, burn, only_robotic = 0, only_organic = 1, updating_health = 1)
	var/list/obj/item/bodypart/parts = get_damaged_bodyparts(brute,burn)

	var/update = 0
	while(parts.len && (brute>0 || burn>0) )
		var/obj/item/bodypart/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		update |= picked.heal_damage(brute,burn, only_robotic, only_organic, 0)

		brute -= (brute_was-picked.brute_dam)
		burn -= (burn_was-picked.burn_dam)

		parts -= picked
	if(updating_health)
		updatehealth()
	if(update)
		update_damage_overlays()

// damage MANY bodyparts, in random order
/mob/living/carbon/take_overall_damage(brute, burn, updating_health = 1)
	if(status_flags & GODMODE)
		return	//godmode

	var/list/obj/item/bodypart/parts = get_damageable_bodyparts()
	var/update = 0
	while(parts.len && (brute>0 || burn>0) )
		var/obj/item/bodypart/picked = pick(parts)
		var/brute_per_part = round(brute/parts.len, 0.01)
		var/burn_per_part = round(burn/parts.len, 0.01)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam


		update |= picked.receive_damage(brute_per_part,burn_per_part, 0)

		brute	-= (picked.brute_dam - brute_was)
		burn	-= (picked.burn_dam - burn_was)

		parts -= picked
	if(updating_health)
		updatehealth()
	if(update)
		update_damage_overlays()



/mob/living/carbon/adjustStaminaLoss(amount, updating_stamina = 1)
	if(status_flags & GODMODE)
		return 0
	staminaloss = Clamp(staminaloss + amount, 0, maxHealth*2)
	if(updating_stamina)
		update_stamina()


/mob/living/carbon/setStaminaLoss(amount, updating_stamina = 1)
	if(status_flags & GODMODE)
		return 0
	staminaloss = amount
	if(updating_stamina)
		update_stamina()
