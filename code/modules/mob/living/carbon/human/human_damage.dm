/mob/living/carbon/human/proc/HealDamage(zone, brute, burn)
	var/datum/organ/external/E = get_organ(zone)
	if(istype(E, /datum/organ/external))
		if (E.heal_damage(brute, burn))
			UpdateDamageIcon()
	else
		return 0
	return

// new damage icon system
// now constructs damage icon for each organ from mask * damage field

/mob/living/carbon/human/UpdateDamageIcon()
	var/icon/standing = new /icon('dam_human.dmi', "00")
	var/icon/lying = new /icon('dam_human.dmi', "00-2")
	for(var/datum/organ/external/O in organs)
		var/icon/DI = new /icon('dam_human.dmi', O.damage_state)			// the damage icon for whole human
		DI.Blend(new /icon('dam_mask.dmi', O.icon_name), ICON_MULTIPLY)		// mask with this organ's pixels
		standing.Blend(DI,ICON_OVERLAY)
		DI = new /icon('dam_human.dmi', "[O.damage_state]-2")				// repeat for lying icons
		DI.Blend(new /icon('dam_mask.dmi', "[O.icon_name]2"), ICON_MULTIPLY)
		lying.Blend(DI,ICON_OVERLAY)
	damageicon_standing = new /image("icon" = standing, "layer" = DAMAGE_LAYER)
	damageicon_lying = new /image("icon" = lying, "layer" = DAMAGE_LAYER)


/mob/living/carbon/human/proc/get_organ(var/zone)
	if(!zone)	zone = "chest"
	for(var/datum/organ/external/O in organs)
		if(O.name == zone)
			return O
	return null


/mob/living/carbon/human/apply_damage(var/damage = 0,var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0)
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
			organ.take_damage(damage, 0)
		if(BURN)
			organ.take_damage(0, damage)
	UpdateDamageIcon()
	updatehealth()
	return 1