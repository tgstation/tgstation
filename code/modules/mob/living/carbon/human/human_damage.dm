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
	del(body_standing)
	body_standing = list()
	del(body_lying)
	body_lying = list()

	for(var/name in organs)
		var/datum/organ/external/O = organs[name]
		if(!O.destroyed)
			O.update_icon()
			var/icon/DI = new /icon('dam_human.dmi', O.damage_state)			// the damage icon for whole human
			DI.Blend(new /icon('dam_mask.dmi', O.icon_name), ICON_MULTIPLY)		// mask with this organ's pixels
		//		world << "[O.icon_name] [O.damage_state] \icon[DI]"
			body_standing += DI
			DI = new /icon('dam_human.dmi', "[O.damage_state]-2")				// repeat for lying icons
			DI.Blend(new /icon('dam_mask.dmi', "[O.icon_name]2"), ICON_MULTIPLY)
		//		world << "[O.r_name]2 [O.d_i_state]-2 \icon[DI]"
			body_lying += DI


/mob/living/carbon/human/apply_damage(var/damage = 0,var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0, var/sharp = 0, var/used_weapon = null)
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
	if(!organ || organ.destroyed)	return 0
	if(blocked)
		damage = (damage/(blocked+1))

	switch(damagetype)
		if(BRUTE)
			organ.take_damage(damage, 0, sharp, used_weapon)
		if(BURN)
			organ.take_damage(0, damage, sharp, used_weapon)

	if(used_weapon)
		organ.add_wound(used_weapon, damage)

	UpdateDamageIcon()
	updatehealth()
	update_clothing()
	return 1