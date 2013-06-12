//Updates the mob's health from organs and mob damage variables
/mob/living/carbon/human/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
		return
	var/total_burn	= 0
	var/total_brute	= 0
	for(var/datum/limb/O in organs)	//hardcoded to streamline things a bit
		total_brute	+= O.brute_dam
		total_burn	+= O.burn_dam
	health = maxHealth - getOxyLoss() - getToxLoss() - getCloneLoss() - total_burn - total_brute
	//TODO: fix husking
	if( ((maxHealth - total_burn) < config.health_threshold_dead) && stat == DEAD )
		ChangeToHusk()
	return


//These procs fetch a cumulative total damage from all organs
/mob/living/carbon/human/getBruteLoss()
	var/amount = 0
	for(var/datum/limb/O in organs)
		amount += O.brute_dam
	return amount

/mob/living/carbon/human/getFireLoss()
	var/amount = 0
	for(var/datum/limb/O in organs)
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
	var/list/datum/limb/parts = list()
	for(var/datum/limb/O in organs)
		if((brute && O.brute_dam) || (burn && O.burn_dam))
			parts += O
	return parts

//Returns a list of damageable organs
/mob/living/carbon/human/proc/get_damageable_organs()
	var/list/datum/limb/parts = list()
	for(var/datum/limb/O in organs)
		if(O.brute_dam + O.burn_dam < O.max_damage)
			parts += O
	return parts

//Heals ONE external organ, organ gets randomly selected from damaged ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/heal_organ_damage(var/brute, var/burn)
	var/list/datum/limb/parts = get_damaged_organs(brute,burn)
	if(!parts.len)	return
	var/datum/limb/picked = pick(parts)
	if(picked.heal_damage(brute,burn))
		update_damage_overlays(0)
	updatehealth()

//Damages ONE external organ, organ gets randomly selected from damagable ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/take_organ_damage(var/brute, var/burn)
	var/list/datum/limb/parts = get_damageable_organs()
	if(!parts.len)	return
	var/datum/limb/picked = pick(parts)
	if(picked.take_damage(brute,burn))
		update_damage_overlays(0)
	updatehealth()


//Heal MANY external organs, in random order
/mob/living/carbon/human/heal_overall_damage(var/brute, var/burn)
	var/list/datum/limb/parts = get_damaged_organs(brute,burn)

	var/update = 0
	while(parts.len && (brute>0 || burn>0) )
		var/datum/limb/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		update |= picked.heal_damage(brute,burn)

		brute -= (brute_was-picked.brute_dam)
		burn -= (burn_was-picked.burn_dam)

		parts -= picked
	updatehealth()
	if(update)	update_damage_overlays(0)

// damage MANY external organs, in random order
/mob/living/carbon/human/take_overall_damage(var/brute, var/burn)
	if(status_flags & GODMODE)	return	//godmode
	var/list/datum/limb/parts = get_damageable_organs()
	var/update = 0
	while(parts.len && (brute>0 || burn>0) )
		var/datum/limb/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam


		update |= picked.take_damage(brute,burn)

		brute	-= (picked.brute_dam - brute_was)
		burn	-= (picked.burn_dam - burn_was)

		parts -= picked
	updatehealth()
	if(update)	update_damage_overlays(0)


////////////////////////////////////////////

/mob/living/carbon/human/proc/HealDamage(zone, brute, burn)
	var/datum/limb/E = get_organ(zone)
	if(istype(E, /datum/limb))
		if (E.heal_damage(brute, burn))
			update_damage_overlays(0)
	else
		return 0
	return


/mob/living/carbon/human/proc/get_organ(var/zone)
	if(!zone)	zone = "chest"
	for(var/datum/limb/O in organs)
		if(O.name == zone)
			return O
	return null


/mob/living/carbon/human/apply_damage(var/damage = 0,var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0)
	if((damagetype != BRUTE) && (damagetype != BURN))
		..(damage, damagetype, def_zone, blocked)
		return 1

	if(blocked >= 2)	return 0

	var/datum/limb/organ = null
	if(isorgan(def_zone))
		organ = def_zone
	else
		if(!def_zone)	def_zone = ran_zone(def_zone)
		organ = get_organ(check_zone(def_zone))
	if(!organ)	return 0

	if(blocked)
		damage = (damage/(blocked+1))

	switch(damagetype)
		if(BRUTE)
			damageoverlaytemp = 20
			if(organ.take_damage(damage, 0))
				update_damage_overlays(0)
		if(BURN)
			damageoverlaytemp = 20
			if(organ.take_damage(0, damage))
				update_damage_overlays(0)

	// Will set our damageoverlay icon to the next level, which will then be set back to the normal level the next mob.Life().

	updatehealth()
	return 1
