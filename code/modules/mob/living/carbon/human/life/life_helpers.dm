//Miscellaneous procs in life.dm that did not directly belong in one of the .dm

/mob/living/carbon/human/calculate_affecting_pressure(var/pressure)
	..()
	var/pressure_difference = abs( pressure - ONE_ATMOSPHERE )
	var/list/clothing_items = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes)

	//mainly used in horror form, but other things work as well
	var/species_difference = 0
	if(species)
		species_difference = species.pressure_resistance

	var/body_parts_protected = 0
	for(var/obj/item/equipment in clothing_items)
		if(equipment && equipment.pressure_resistance >= pressure_difference)
			body_parts_protected |= equipment.body_parts_covered
	pressure_difference = max(pressure_difference - species_difference,0)
	pressure_difference *= (1 - ((return_cover_protection(body_parts_protected))**5)) // if one part of your suit's not up to scratch, we can assume the rest of the suit isn't as effective.
	if(pressure > ONE_ATMOSPHERE)
		return ONE_ATMOSPHERE + pressure_difference
	else
		return ONE_ATMOSPHERE - pressure_difference

//This proc returns a number made up of the flags for body parts which you are protected on. (such as HEAD, UPPER_TORSO, LOWER_TORSO, etc. See setup.dm for the full list)
/mob/living/carbon/human/get_heat_protection_flags(temperature) //Temperature is the temperature you're being exposed to.
	var/thermal_protection_flags = 0
	//Handle normal clothing
	if(head)
		if(head.max_heat_protection_temperature && head.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= head.body_parts_covered
	if(wear_suit)
		if(wear_suit.max_heat_protection_temperature && wear_suit.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= wear_suit.body_parts_covered
	if(w_uniform)
		if(w_uniform.max_heat_protection_temperature && w_uniform.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= w_uniform.body_parts_covered
	if(shoes)
		if(shoes.max_heat_protection_temperature && shoes.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= shoes.body_parts_covered
	if(gloves)
		if(gloves.max_heat_protection_temperature && gloves.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= gloves.body_parts_covered
	if(wear_mask)
		if(wear_mask.max_heat_protection_temperature && wear_mask.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= wear_mask.body_parts_covered

	return thermal_protection_flags

/mob/living/carbon/human/get_thermal_protection_flags()
	var/thermal_protection_flags = 0
	if(head)
		thermal_protection_flags |= head.body_parts_covered
	if(wear_suit)
		thermal_protection_flags |= wear_suit.body_parts_covered
	if(w_uniform)
		thermal_protection_flags |= w_uniform.body_parts_covered
	if(shoes)
		thermal_protection_flags |= shoes.body_parts_covered
	if(gloves)
		thermal_protection_flags |= gloves.body_parts_covered
	if(wear_mask)
		thermal_protection_flags |= wear_mask.body_parts_covered

	return thermal_protection_flags

/mob/living/carbon/human/get_heat_protection(var/thermal_protection_flags) //Temperature is the temperature you're being exposed to.
	if(M_RESIST_HEAT in mutations)
		return 1
	return get_thermal_protection(thermal_protection_flags)

/mob/living/carbon/human/get_cold_protection()

	if(M_RESIST_COLD in mutations)
		return 1 //Fully protected from the cold.

	var/thermal_protection = 0.0

	if(head)
		thermal_protection += head.return_thermal_protection()
	if(wear_suit)
		thermal_protection += wear_suit.return_thermal_protection()
	if(w_uniform)
		thermal_protection += w_uniform.return_thermal_protection()
	if(shoes)
		thermal_protection += shoes.return_thermal_protection()
	if(gloves)
		thermal_protection += gloves.return_thermal_protection()
	if(wear_mask)
		thermal_protection += wear_mask.return_thermal_protection()

	var/max_protection = get_thermal_protection(get_thermal_protection_flags())
	return min(thermal_protection,max_protection)


/*
/mob/living/carbon/human/proc/add_fire_protection(var/temp)
	var/fire_prot = 0
	if(head)
		if(head.protective_temperature > temp)
			fire_prot += (head.protective_temperature/10)
	if(wear_mask)
		if(wear_mask.protective_temperature > temp)
			fire_prot += (wear_mask.protective_temperature/10)
	if(glasses)
		if(glasses.protective_temperature > temp)
			fire_prot += (glasses.protective_temperature/10)
	if(ears)
		if(ears.protective_temperature > temp)
			fire_prot += (ears.protective_temperature/10)
	if(wear_suit)
		if(wear_suit.protective_temperature > temp)
			fire_prot += (wear_suit.protective_temperature/10)
	if(w_uniform)
		if(w_uniform.protective_temperature > temp)
			fire_prot += (w_uniform.protective_temperature/10)
	if(gloves)
		if(gloves.protective_temperature > temp)
			fire_prot += (gloves.protective_temperature/10)
	if(shoes)
		if(shoes.protective_temperature > temp)
			fire_prot += (shoes.protective_temperature/10)

	return fire_prot

/mob/living/carbon/human/proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
	if(nodamage)
		return
//	to_chat(world, "body_part = [body_part], exposed_temperature = [exposed_temperature], exposed_intensity = [exposed_intensity]")
	var/discomfort = min(abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)

	if(exposed_temperature > bodytemperature)
		discomfort *= 4

	if(mutantrace == "plant")
		discomfort *= TEMPERATURE_DAMAGE_COEFFICIENT * 2 //I don't like magic numbers. I'll make mutantraces a datum with vars sometime later. -- Urist
	else
		discomfort *= TEMPERATURE_DAMAGE_COEFFICIENT //Dangercon 2011 - now with less magic numbers!
//	to_chat(world, "[discomfort]")

	switch(body_part)
		if(HEAD)
			apply_damage(2.5*discomfort, BURN, "head")
		if(UPPER_TORSO)
			apply_damage(2.5*discomfort, BURN, "chest")
		if(LEGS)
			apply_damage(0.6*discomfort, BURN, "l_leg")
			apply_damage(0.6*discomfort, BURN, "r_leg")
		if(ARMS)
			apply_damage(0.4*discomfort, BURN, "l_arm")
			apply_damage(0.4*discomfort, BURN, "r_arm")
*/

/mob/living/carbon/human/proc/get_covered_bodyparts()
	var/covered = 0

	if(head)
		covered |= head.body_parts_covered
	if(wear_suit)
		covered |= wear_suit.body_parts_covered
	if(w_uniform)
		covered |= w_uniform.body_parts_covered
	if(shoes)
		covered |= shoes.body_parts_covered
	if(gloves)
		covered |= gloves.body_parts_covered
	if(wear_mask)
		covered |= wear_mask.body_parts_covered

	return covered


/mob/living/carbon/human/proc/randorgan()
	var/randorgan = pick("head","chest","l_arm","r_arm","l_hand","r_hand","groin","l_leg","r_leg","l_foot","r_foot")
	//var/randorgan = pick("head","chest","groin")
	return randorgan

/mob/living/carbon/human/proc/earprot()
	var/detect = 0
	if(is_on_ears(/obj/item/clothing/ears/earmuffs)||is_on_ears(/obj/item/device/radio/headset/headset_earmuffs))
		detect = 1
	return detect

/mob/living/carbon/human/proc/has_reagent_in_blood(var/reagent_name,var/amount = -1)
	if(!reagents || !ticker)
		return 0
	return reagents.has_reagent(reagent_name,amount)

var/list/cover_protection_value_list = list()

proc/return_cover_protection(var/body_parts_covered)
	var/true_body_parts_covered = body_parts_covered
	true_body_parts_covered &= ~(IGNORE_INV|BEARD) // these being covered doesn't particularly matter so no need for them here
	if(cover_protection_value_list["[true_body_parts_covered]"])
		return cover_protection_value_list["[true_body_parts_covered]"]
	else
		var/total_protection = 0
		for(var/body_part in BODY_PARTS)
			if (body_part & true_body_parts_covered)
				total_protection += BODY_COVER_VALUE_LIST["[body_part]"]
		cover_protection_value_list["[true_body_parts_covered]"] = total_protection
		return total_protection