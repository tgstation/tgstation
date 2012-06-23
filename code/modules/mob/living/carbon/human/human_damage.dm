//Instead of setting real_name = "Unknown", use this when necessary.
//It will prevent the cloned-as-unknown bug and various other derpy things.
/mob/living/carbon/human/proc/disfigure_face()
	var/datum/organ/external/head/head = get_organ("head")
	if(head && !head.disfigured)
		head.disfigured = 1
		name = get_visible_name()
		src << "\red Your face has become disfigured."
		warn_flavor_changed()

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
	// first check whether something actually changed about damage appearance
	var/damage_appearance = ""

	for(var/name in organs)
		var/datum/organ/external/O = organs[name]
		if(O.destroyed) damage_appearance += "d"
		else
			damage_appearance += O.damage_state

	if(damage_appearance == previous_damage_appearance)
		// nothing to do here
		return

	previous_damage_appearance = damage_appearance

	var/icon/standing = new /icon('dam_human.dmi', "00")
	var/icon/lying = new /icon('dam_human.dmi', "00-2")

	for(var/name in organs)
		var/datum/organ/external/O = organs[name]
		if(!O.destroyed)
			O.update_icon()
			var/icon/DI = new /icon('dam_human.dmi', O.damage_state)			// the damage icon for whole human
			DI.Blend(new /icon('dam_mask.dmi', O.icon_name), ICON_MULTIPLY)		// mask with this organ's pixels
		//		world << "[O.icon_name] [O.damage_state] \icon[DI]"
			standing.Blend(DI,ICON_OVERLAY)
			DI = new /icon('dam_human.dmi', "[O.damage_state]-2")				// repeat for lying icons
			DI.Blend(new /icon('dam_mask.dmi', "[O.icon_name]2"), ICON_MULTIPLY)
		//		world << "[O.r_name]2 [O.d_i_state]-2 \icon[DI]"
			lying.Blend(DI,ICON_OVERLAY)
	damageicon_standing = new /image("icon" = standing, "layer" = DAMAGE_LAYER)
	damageicon_lying = new /image("icon" = lying, "layer" = DAMAGE_LAYER)


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

	if(DERMALARMOR in augmentations)
		damage = damage - (round(damage*0.35)) // reduce damage by 35%

	switch(damagetype)
		if(BRUTE)
			organ.take_damage(damage, 0, sharp, used_weapon)
		if(BURN)
			organ.take_damage(0, damage, sharp, used_weapon)

	if(used_weapon)
		organ.add_wound(used_weapon, damage)

	UpdateDamageIcon()
	updatehealth()
	return 1