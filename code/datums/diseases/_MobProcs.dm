
/mob/living/proc/HasDisease(datum/disease/D)
	for(var/thing in diseases)
		var/datum/disease/DD = thing
		if(D.IsSame(DD))
			return TRUE
	return FALSE


/mob/living/proc/CanContractDisease(datum/disease/D)
	if(stat == DEAD && !D.process_dead)
		return FALSE

	if(D.GetDiseaseID() in disease_resistances)
		return FALSE

	if(HasDisease(D))
		return FALSE

	if(!(D.infectable_biotypes & mob_biotypes))
		return FALSE


	if(!(type in D.viable_mobtypes))
		return FALSE

	return TRUE


/mob/living/proc/ContactContractDisease(datum/disease/D)
	if(!CanContractDisease(D))
		return FALSE
	D.try_infect(src)


/mob/living/carbon/ContactContractDisease(datum/disease/D, target_zone)
	if(!CanContractDisease(D))
		return FALSE
	// Base chance of contracting considering disease's transmittability.
	if(prob(15 / D.permeability_mod))
		return FALSE
	// Positive satiety makes it harder to contract the disease.
	if(satiety > 0 && prob(satiety / 10))
		return FALSE

	// If we're not manually supplying a zone, pull one at random.
	if(target_zone)
		target_zone = check_zone(target_zone)
	else
		target_zone = ran_zone()

	// The body coverage flags we care about.
	var/target_parts = 0
	for(var/part in zone2body_parts_covered(target_zone))
		target_parts |= part
	// The multiplicative protection value that our equipment providers for this zone.
	var/permeability_product = 1

	// Cycle through inventory and determine if the virus passes through the mob's equipment.
	var/list/items = get_equipped_items()
	for(var/obj/item/I in items)
		// Does this item provide relevant coverage?
		if(!(target_parts & I.body_parts_covered))
			continue
		permeability_product *= I.permeability_coefficient;

	if(prob(permeability_product * 100))
		return D.try_infect(src)

	return FALSE

/mob/living/proc/AirborneContractDisease(datum/disease/D, force_spread)
	if(!CanContractDisease(D))
		return FALSE
	// Feasibility / force check.
	if(!force_spread && !(D.spread_flags & DISEASE_SPREAD_AIRBORNE))
		return FALSE
	// Base chance.
	if(!prob((50 * D.permeability_mod) - 1))
		return FALSE

	// Hood and mask check.
	var/target_parts = 0
	for(var/part in zone2body_parts_covered(BODY_ZONE_HEAD))
		target_parts |= part
	var/permeability_product = 1
	var/list/items = get_equipped_items()
	for(var/obj/item/I in items)
		// Does this item provide relevant coverage?
		if(!(target_parts & I.body_parts_covered))
			continue
		permeability_product *= I.permeability_coefficient;

	if(prob(permeability_product * 100))
		return ForceContractDisease(D)

/mob/living/carbon/AirborneContractDisease(datum/disease/D, force_spread)
	if(internal)
		return FALSE
	if(HAS_TRAIT(src, TRAIT_NOBREATH))
		return FALSE
	..()

//Proc to use when you 100% want to try to infect someone (ignoreing protective clothing and such), as long as they aren't immune
/mob/living/proc/ForceContractDisease(datum/disease/D, make_copy = TRUE, del_on_fail = FALSE)
	if(!CanContractDisease(D))
		if(del_on_fail)
			qdel(D)
		return FALSE
	if(!D.try_infect(src, make_copy))
		if(del_on_fail)
			qdel(D)
		return FALSE
	return TRUE


/mob/living/carbon/human/CanContractDisease(datum/disease/D)
	if(dna)
		if(HAS_TRAIT(src, TRAIT_VIRUSIMMUNE) && !D.bypasses_immunity)
			return FALSE

	for(var/thing in D.required_organs)
		if(!((locate(thing) in bodyparts) || (locate(thing) in internal_organs)))
			return FALSE
	return ..()

/mob/living/proc/CanSpreadAirborneDisease()
	return !is_mouth_covered()

/mob/living/carbon/CanSpreadAirborneDisease()
	return !((head && (head.flags_cover & HEADCOVERSMOUTH) && (head.armor.getRating(BIO) >= 25)) || (wear_mask && (wear_mask.flags_cover & MASKCOVERSMOUTH) && (wear_mask.armor.getRating(BIO) >= 25)))

/mob/living/proc/set_shocked()
	flags_1 |= SHOCKED_1

/mob/living/proc/reset_shocked()
	flags_1 &= ~ SHOCKED_1
