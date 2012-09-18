//Updates the mob's health from organs and mob damage variables
/mob/living/carbon/human/updatehealth()
	if(nodamage)
		health = 100
		stat = CONSCIOUS
		return
	var/total_burn	= 0
	var/total_brute	= 0
	for(var/datum/organ/external/O in organs)	//hardcoded to streamline things a bit
		total_brute	+= O.brute_dam
		total_burn	+= O.burn_dam
	health = 100 - getOxyLoss() - getToxLoss() - getCloneLoss() - total_burn - total_brute
	//TODO: fix husking
	if( ((100 - total_burn) < config.health_threshold_dead) && stat == DEAD) //100 only being used as the magic human max health number, feel free to change it if you add a var for it -- Urist
		ChangeToHusk()
	return


//These procs fetch a cumulative total damage from all organs
/mob/living/carbon/human/getBruteLoss()
	var/amount = 0
	for(var/datum/organ/external/O in organs)
		amount += O.brute_dam
	return amount

/mob/living/carbon/human/getFireLoss()
	var/amount = 0
	for(var/datum/organ/external/O in organs)
		amount += O.burn_dam
	return amount


/mob/living/carbon/human/adjustBruteLoss(var/amount)
	if(amount > 0)
		take_overall_damage(amount, 0)
	else
		heal_overall_damage(-amount, 0)

/mob/living/carbon/human/adjustFireLoss(var/amount)
	if(amount > 0)
		take_overall_damage(0, amount)
	else
		heal_overall_damage(0, -amount)

/mob/living/carbon/human/Stun(amount)
	if(HULK in mutations)	return
	..()

/mob/living/carbon/human/Weaken(amount)
	if(HULK in mutations)	return
	..()

/mob/living/carbon/human/Paralyse(amount)
	if(HULK in mutations)	return
	..()

////////////////////////////////////////////

//Returns a list of damaged organs
/mob/living/carbon/human/proc/get_damaged_organs(var/brute, var/burn)
	var/list/datum/organ/external/parts = list()
	for(var/datum/organ/external/O in organs)
		if((brute && O.brute_dam) || (burn && O.burn_dam))
			parts += O
	return parts

//Returns a list of damageable organs
/mob/living/carbon/human/proc/get_damageable_organs()
	var/list/datum/organ/external/parts = list()
	for(var/datum/organ/external/O in organs)
		if(O.brute_dam + O.burn_dam < O.max_damage)
			parts += O
	return parts

//Heals ONE external organ, organ gets randomly selected from damaged ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/heal_organ_damage(var/brute, var/burn)
	var/list/datum/organ/external/parts = get_damaged_organs(brute,burn)
	if(!parts.len)	return
	var/datum/organ/external/picked = pick(parts)
	if(picked.heal_damage(brute,burn))
		UpdateDamageIcon()
	updatehealth()

//Damages ONE external organ, organ gets randomly selected from damagable ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/take_organ_damage(var/brute, var/burn, var/sharp = 0)
	var/list/datum/organ/external/parts = get_damageable_organs()
	if(!parts.len)	return
	var/datum/organ/external/picked = pick(parts)
	if(picked.take_damage(brute,burn,sharp))
		UpdateDamageIcon()
	updatehealth()


//Heal MANY external organs, in random order
/mob/living/carbon/human/heal_overall_damage(var/brute, var/burn)
	var/list/datum/organ/external/parts = get_damaged_organs(brute,burn)

	var/update = 0
	while(parts.len && (brute>0 || burn>0) )
		var/datum/organ/external/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		update |= picked.heal_damage(brute,burn)

		brute -= (brute_was-picked.brute_dam)
		burn -= (burn_was-picked.burn_dam)

		parts -= picked
	updatehealth()
	if(update)	UpdateDamageIcon()

// damage MANY external organs, in random order
/mob/living/carbon/human/take_overall_damage(var/brute, var/burn, var/sharp = 0)
	if(nodamage)	return	//godmode
	var/list/datum/organ/external/parts = get_damageable_organs()
	var/update = 0
	while(parts.len && (brute>0 || burn>0) )
		var/datum/organ/external/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		update |= picked.take_damage(brute,burn,sharp)

		brute	-= (picked.brute_dam - brute_was)
		burn	-= (picked.burn_dam - burn_was)

		parts -= picked
	updatehealth()
	if(update)	UpdateDamageIcon()


////////////////////////////////////////////

/mob/living/carbon/human/proc/HealDamage(zone, brute, burn)
	var/datum/organ/external/E = get_organ(zone)
	if(istype(E, /datum/organ/external))
		if (E.heal_damage(brute, burn))
			UpdateDamageIcon()
	else
		return 0
	return


/mob/living/carbon/human/proc/get_organ(var/zone)
	if(!zone)	zone = "chest"
	return organs_by_name[zone]

/mob/living/carbon/human/apply_damage(var/damage = 0,var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0, var/sharp = 0)
	if((damagetype != BRUTE) && (damagetype != BURN))
		..(damage, damagetype, def_zone, blocked)
		return 1

	if(blocked >= 2)	return 0

	var/datum/organ/external/organ = null
	if(isorgan(def_zone))
		organ = def_zone
	else
		if(!def_zone)	def_zone = ran_zone(def_zone)
		organ = get_organ(check_zone(def_zone))
	if(!organ)	return 0
	if(blocked)
		damage = (damage/(blocked+1))

	if(DERMALARMOR in augmentations)
		damage = damage - (round(damage*0.35)) // reduce damage by 35%

	switch(damagetype)
		if(BRUTE)
			if(organ.take_damage(damage, 0, sharp))
				UpdateDamageIcon()
		if(BURN)
			if(organ.take_damage(0, damage, sharp))
				UpdateDamageIcon()
	updatehealth()
	return 1
