/mob/living/verb/succumb()
	set hidden = 1
	if ((src.health < 0 && src.health > -95.0))
		src.adjustOxyLoss(src.health + 200)
		src.health = 100 - src.getOxyLoss() - src.getToxLoss() - src.getFireLoss() - src.getBruteLoss()
		src << "\blue You have given up life and succumbed to death."


/mob/living/proc/updatehealth()
	if(!src.nodamage)
		src.health = 100 - src.getOxyLoss() - src.getToxLoss() - src.getFireLoss() - src.getBruteLoss() - src.getCloneLoss() -src.halloss
	else
		src.health = 100
		src.stat = 0


//sort of a legacy burn method for /electrocute, /shock, and the e_chair
/mob/living/proc/burn_skin(burn_amount, used_weapon = null)
	if(istype(src, /mob/living/carbon/human))
		if(MSHOCK in src.mutations)
			return 0
		//world << "DEBUG: burn_skin(), mutations=[mutations]"
		if (COLD_RESISTANCE in src.mutations) //fireproof
			return 0
		var/mob/living/carbon/human/H = src	//make this damage method divide the damage to be done among all the body parts, then burn each body part for that much damage. will have better effect then just randomly picking a body part
		var/divided_damage = (burn_amount)/(H.organs.len)
		for(var/name in H.organs)
			apply_damage(divided_damage, BURN, name, 0, 0, "Skin Burns")
		H.UpdateDamageIcon()
		H.updatehealth()
		return 1
	else if(istype(src, /mob/living/carbon/monkey))
		if (COLD_RESISTANCE in src.mutations) //fireproof
			return 0
		var/mob/living/carbon/monkey/M = src
		M.adjustFireLoss(burn_amount)
		M.updatehealth()
		return 1
	else if(istype(src, /mob/living/silicon/ai))
		return 0

/mob/living/proc/adjustBodyTemp(actual, desired, incrementboost)
	var/temperature = actual
	var/difference = abs(actual-desired)	//get difference
	var/increments = difference/10 //find how many increments apart they are
	var/change = increments*incrementboost	// Get the amount to change by (x per increment)

	// Too cold
	if(actual < desired)
		temperature += change
		if(actual > desired)
			temperature = desired
	// Too hot
	if(actual > desired)
		temperature -= change
		if(actual < desired)
			temperature = desired
//	if(istype(src, /mob/living/carbon/human))
//		world << "[src] ~ [src.bodytemperature] ~ [temperature]"
	return temperature

/mob/proc/get_contents()

/mob/living/get_contents()
	var/list/L = list()
	L += src.contents
	for(var/obj/item/weapon/storage/S in L)
		L |= S.return_inv()
	for(var/obj/item/weapon/gift/G in L)
		L |= G.gift
		if (istype(G.gift, /obj/item/weapon/storage))
			L |= G.gift:return_inv()
	for(var/obj/item/weapon/evidencebag/E in L)
		L |= E:contents
	for(var/obj/item/smallDelivery/S in L)
		L |= S.wrapped
	return L

/mob/living/proc/check_contents_for(A)
	var/list/L = list()
	L += src.contents
	for(var/obj/item/weapon/storage/S in L)
		L |= S.return_inv()
	for(var/obj/item/weapon/gift/G in L)
		L |= G.gift
		if (istype(G.gift, /obj/item/weapon/storage))
			L |= G.gift:return_inv()
	for(var/obj/item/weapon/evidencebag/E in L)
		L |= E:contents
	for(var/obj/item/smallDelivery/S in L)
		L |= S.wrapped
	if(hasorgans(src))
		for(var/named in src:organs)
			var/datum/organ/external/O = src:organs[named]
			for(var/obj/item/weapon/implant/I in O.implant)
				L |= I
				if(istype(I, /obj/item/weapon/implant/compressed))
					L |= I:scanned

	for(var/obj/B in L)
		if(B.type == A)
			return 1
	return 0

/mob/living/proc/check_contents_for_reagent(A)
	var/list/L = list()
	L += src.contents
	for(var/obj/item/weapon/storage/S in L)
		L |= S.return_inv()
	for(var/obj/item/weapon/gift/G in L)
		L |= G.gift
		if (istype(G.gift, /obj/item/weapon/storage))
			L |= G.gift:return_inv()
	for(var/obj/item/weapon/evidencebag/E in L)
		L |= E:contents
	for(var/obj/item/smallDelivery/S in L)
		L |= S.wrapped
	if(hasorgans(src))
		for(var/named in src:organs)
			var/datum/organ/external/O = src:organs[named]
			for(var/obj/item/weapon/implant/I in O.implant)
				L |= I
				if(istype(I, /obj/item/weapon/implant/compressed))
					L |= I:scanned

	for(var/obj/item/weapon/reagent_containers/B in L)
		for(var/datum/reagent/R in B.reagents.reagent_list)
			if(R.type == A)
				return 1
	return 0


/mob/living/proc/electrocute_act(var/shock_damage, var/obj/source, var/siemens_coeff = 1.0)
	  return 0 //only carbon liveforms have this proc

/mob/living/emp_act(severity)
	var/list/L = src.get_contents()
	for(var/obj/O in L)
		O.emp_act(severity)
	..()

/mob/living/proc/get_organ_target()
	var/mob/shooter = src
	var/t = shooter:zone_sel.selecting
	if ((t in list( "eyes", "mouth" )))
		t = "head"
	var/datum/organ/external/def_zone = ran_zone(t)
	return def_zone


// heal ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/heal_organ_damage(var/brute, var/burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/take_organ_damage(var/brute, var/burn)
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

// heal MANY external organs, in random order
/mob/living/proc/heal_overall_damage(var/brute, var/burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage MANY external organs, in random order
/mob/living/proc/take_overall_damage(var/brute, var/burn)
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

/mob/living/proc/revive()
	if(istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		for(var/A in H.organs)
			var/datum/organ/external/affecting = null
			if(!H.organs[A])    continue
			affecting = H.organs[A]
			if(!istype(affecting, /datum/organ/external))    continue
			affecting.heal_damage(1000, 1000)    //fixes getting hit after ingestion, killing you when game updates organ health
			affecting.status &= ~ORGAN_BROKEN
			affecting.status &= ~ORGAN_SPLINTED
			affecting.status &= ~ORGAN_DESTROYED
			affecting.wounds.Cut()
		H.UpdateDamageIcon()
		H.update_body()
	//src.fireloss = 0
	src.setToxLoss(0)
	//src.bruteloss = 0
	src.setOxyLoss(0)
	SetParalysis(0)
	SetStunned(0)
	SetWeakened(0)
	src.radiation = 0
	src.nutrition = 400
	src.bodytemperature = initial(src.bodytemperature)
	//src.health = 100
	if(ishuman(src))
		src.heal_overall_damage(1000, 1000)
		//M.updatehealth()
		src.buckled = initial(src.buckled)
		src.handcuffed = initial(src.handcuffed)
		if(istype(src,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = src
			for(var/name in H.organs)
				var/datum/organ/external/e = H.organs[name]
				e.brute_dam = 0.0
				e.burn_dam = 0.0
				e.status &= ~ORGAN_BANDAGED
				e.max_damage = initial(e.max_damage)
				e.status &= ~ORGAN_BLEEDING
				e.open = 0
				e.status &= ~ORGAN_BROKEN
				e.status &= ~ORGAN_SPLINTED
				e.status &= ~ORGAN_DESTROYED
				e.perma_injury = 0
				e.update_icon()
				e.wounds.Cut()
			del(H.vessel)
			H.vessel = new/datum/reagents(560)
			H.vessel.my_atom = H
			H.vessel.add_reagent("blood",560)
			spawn(1)
				H.fixblood()
			H.pale = 0
			H.update_body()
			H.update_face()
			H.UpdateDamageIcon()
		if (src.stat > 1)
			src.stat=0
		..()
	src.heal_overall_damage(1000, 1000)
	src.buckled = initial(src.buckled)
	src.handcuffed = initial(src.handcuffed)
	if(src.stat > 1)
		src.stat = CONSCIOUS
	..()
	return

/mob/living/proc/UpdateDamageIcon()
		return

/mob/living/proc/check_if_buckled()
	if (buckled)
		if(buckled == /obj/structure/stool/bed || istype(buckled, /obj/machinery/conveyor))
			lying = 1
		if(lying)
			var/h = hand
			hand = 0
			drop_item()
			hand = 1
			drop_item()
			hand = h
		density = 1
	else
		density = !lying
//Bullshit ERP horseshit causing runtimes.  Eat a dick.
/*
/mob/living/proc/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC"
	set src in view()

	if(config.allow_Metadata)
		usr << "[src]'s Metainfo:"

		if(src.storedpreferences)
			usr << "[src]'s OOC Notes:  [src.storedpreferences.metadata]"

		else
			usr << "[src] does not have any stored infomation!"

	else
		usr << "OOC Metadata is not supported by this server!"

	return*/

/mob/living/attack_animal(mob/M)
	attack_paw(M)	// treat it like a normal non-human attack

/mob/living/verb/change_flavor_text()
	set name = "Change Flavor Text"
	set category = "OOC"

	src.update_flavor_text()


/mob/living/var/life_tick = 0
