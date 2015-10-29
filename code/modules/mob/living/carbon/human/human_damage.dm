//Updates the mob's health from organs and mob damage variables
/mob/living/carbon/human/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
		return
	var/total_burn	= 0
	var/total_brute	= 0
	var/list/limblist = list_limbs()
	for(var/limbname in limblist)
		var/datum/organ/limb/O = getorgan(limbname)
		if(O.status & ORGAN_DESTROYED)
			total_brute += O.destroyed_dam
		else if(O.counts_for_damage())
			var/obj/item/organ/limb/L = O.organitem
			total_brute += L.brute_dam
			total_burn += L.burn_dam
	health = maxHealth - getOxyLoss() - getToxLoss() - getCloneLoss() - total_burn - total_brute
	//TODO: fix husking
	if( ((maxHealth - total_burn) < config.health_threshold_dead) && stat == DEAD )
		ChangeToHusk()
	med_hud_set_health()
	med_hud_set_status()
	return


//These procs fetch a cumulative total damage from all organs
/mob/living/carbon/human/getBruteLoss()
	var/amount = 0
	for(var/datum/organ/limb/O in organsystem.organlist)
		if(O.status & ORGAN_DESTROYED)
			amount += O.destroyed_dam //A destroyed limb is basically a severe brute wound, right?
		else if(O.counts_for_damage())
			var/obj/item/organ/limb/L = O.organitem
			amount += L.brute_dam
		//Else the organ is either ORGAN_REMOVED or something weird happened.
	return amount

/mob/living/carbon/human/getFireLoss()
	var/amount = 0
	for(var/datum/organ/limb/O in organsystem.organlist)
		if(O.counts_for_damage()) //A limb only counts for burns if it's actually there.
			var/obj/item/organ/limb/L = O.organitem
			amount += L.burn_dam
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

/mob/living/carbon/human/proc/hat_fall_prob()
	var/multiplier = 1
	var/obj/item/clothing/head/H = head
	var/loose = 40
	if(stat || (status_flags & FAKEDEATH))
		multiplier = 2
	if(H.body_parts_covered & (EYES | MOUTH) || H.flags_inv & (HIDEEYES | HIDEFACE))
		loose = 0
	return loose * multiplier

////////////////////////////////////////////

//Returns a list of damaged organs
/mob/living/carbon/human/proc/get_damaged_organs(var/brute, var/burn)
	var/list/obj/item/organ/limb/parts = list()
	for(var/datum/organ/limb/O in organsystem.organlist)
		if(O.counts_for_damage())
			var/obj/item/organ/limb/L = O.organitem
			if((brute && L.brute_dam) || (burn && L.burn_dam))
				parts += L
	return parts

//Returns a list of damageable organs
/mob/living/carbon/human/proc/get_damageable_organs()
	var/list/obj/item/organ/limb/parts = list()
	for(var/datum/organ/limb/O in organs)
		if(O.counts_for_damage())
			var/obj/item/organ/limb/L = O.organitem
			if(L.brute_dam + L.burn_dam < L.max_damage)
				parts += L
	return parts

//Heals ONE external organ, organ gets randomly selected from damaged ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/heal_organ_damage(var/brute, var/burn)
	var/list/obj/item/organ/limb/parts = get_damaged_organs(brute,burn)
	if(!parts.len)	return
	var/obj/item/organ/limb/picked = pick(parts)
	if(picked.heal_damage(brute,burn,0))
		update_damage_overlays(0)
	updatehealth()

//Damages ONE external organ, organ gets randomly selected from damagable ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/take_organ_damage(var/brute, var/burn)
	var/list/obj/item/organ/limb/parts = get_damageable_organs()
	if(!parts.len)	return
	var/obj/item/organ/limb/picked = pick(parts)
	if(picked.take_damage(brute,burn))
		update_damage_overlays(0)

	updatehealth()


//Heal MANY external organs, in random order
/mob/living/carbon/human/heal_overall_damage(var/brute, var/burn)
	var/list/obj/item/organ/limb/parts = get_damaged_organs(brute,burn)

	var/update = 0
	while(parts.len && (brute>0 || burn>0) )
		var/obj/item/organ/limb/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		update |= picked.heal_damage(brute,burn,0)

		brute -= (brute_was-picked.brute_dam)
		burn -= (burn_was-picked.burn_dam)

		parts -= picked
	updatehealth()
	if(update)	update_damage_overlays(0)

// damage MANY external organs, in random order
/mob/living/carbon/human/take_overall_damage(var/brute, var/burn)
	if(status_flags & GODMODE)	return	//godmode

	var/list/obj/item/organ/limb/parts = get_damageable_organs()
	var/update = 0
	while(parts.len && (brute>0 || burn>0) )
		var/obj/item/organ/limb/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam


		update |= picked.take_damage(brute,burn)

		brute	-= (picked.brute_dam - brute_was)
		burn	-= (picked.burn_dam - burn_was)

		parts -= picked

	updatehealth()

	if(update)	update_damage_overlays(0)

/mob/living/carbon/human/proc/restore_blood()
	if(!(NOBLOOD in dna.species.specflags))
		var/blood_volume = vessel.get_reagent_amount("blood")
		vessel.add_reagent("blood",560.0-blood_volume)

////////////////////////////////////////////


/mob/living/carbon/human/proc/get_organ(var/zone)
	if(!zone)	zone = "chest"
	if(organsystem)
		var/datum/organ/O = organsystem.getorgan("[zone]")
		return O
	else
		return null


/mob/living/carbon/human/apply_damage(var/damage = 0,var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0)
	if(dna)	// if you have a species, it will run the apply_damage code there instead
		dna.species.apply_damage(damage, damagetype, def_zone, blocked, src)
	else
		if((damagetype != BRUTE) && (damagetype != BURN))
			..(damage, damagetype, def_zone, blocked)
			return 1

		else
			blocked = (100-blocked)/100
			if(blocked <= 0)	return 0

			var/obj/item/organ/limb/organ = null
			if(islimb(def_zone))
				organ = def_zone
			else
				if(!def_zone)	def_zone = ran_zone(def_zone)
				organ = get_organ(check_zone(def_zone))
			if(!organ)	return 0

			damage = (damage * blocked)

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
