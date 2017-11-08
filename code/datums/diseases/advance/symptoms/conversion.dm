/datum/symptom/conversion
	name = "Basic Compensation Healing (does nothing)" //warning for adminspawn viruses
	desc = "You should not be seeing this."
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 0 //not obtainable
	base_message_chance = 20 //here used for the overlays
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/hide_healing = FALSE
	threshold_desc = "<b>Stage Speed 6:</b> Doubles compensation speed.<br>\
					  <b>Stage Speed 11:</b> Triples compensation speed.<br>\
					  <b>Stealth 4:</b> Healing will no longer be visible to onlookers."

/datum/symptom/conversion/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stealth"] >= 4) //invisible healing
		hide_healing = TRUE
	if(A.properties["stage_rate"] >= 6) //stronger healing
		power = 2
	if(A.properties["stage_rate"] >= 11) //even stronger healing
		power = 3

/datum/symptom/conversion/Activate(datum/disease/advance/A)
	if(!..())
		return
	 //100% chance to activate for slow but consistent healing
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			Heal(M, A)
	return

/datum/symptom/conversion/proc/Heal(mob/living/M, datum/disease/advance/A)
	return 1

/*
//////////////////////////////////////

Toxin -> respiration

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Heals toxins in the affected mob's bloodstream.
	Deals respiration damage.

//////////////////////////////////////
*/

/datum/symptom/conversion/toxin
	name = "Toxin Oxidation"
	desc = "The virus uses large amounts of oxygen to destroy toxins."
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 6

/datum/symptom/conversion/toxin/Heal(mob/living/M, datum/disease/advance/A)
	if(M.toxloss > 0 && prob(base_message_chance) && !hide_healing)
		new /obj/effect/temp_visual/heal(get_turf(M), "#66FF99")
	M.adjustToxLoss(-power)
	M.adjustOxyLoss(2 * power, 0)
	return 1

/*
//////////////////////////////////////

Brute -> toxin

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Heals brute damage slowly over time.
	Intoxicates mob's bloodstream.

//////////////////////////////////////
*/

/datum/symptom/conversion/brute

	name = "Mending Compensation"
	desc = "The virus heals bruises, secretating large amounts of toxins in the proccess."
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 6

/datum/symptom/conversion/brute/Heal(mob/living/carbon/M, datum/disease/advance/A)
	var/heal_amt = 2 * power

	var/list/parts = M.get_damaged_bodyparts(1, 0) //brute only

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, 0))
			M.update_damage_overlays()

	M.adjustToxLoss(2 * heal_amt)

	if(prob(base_message_chance) && !hide_healing)
		new /obj/effect/temp_visual/heal(get_turf(M), "#FF3333")

	return 1


/*
//////////////////////////////////////

Burn -> toxin

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Heals burn damage slowly over time.
	Intoxicates mob's bloodstream.

//////////////////////////////////////
*/

/datum/symptom/conversion/burn

	name = "Regenerative Compensation"
	desc = "The virus produces toxins and hormones which estimulates the body to regenerate burnt tissues."
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 6

/datum/symptom/conversion/burn/Heal(mob/living/carbon/M, datum/disease/advance/A)
	var/heal_amt = 2 * power

	var/list/parts = M.get_damaged_bodyparts(0,1) //burn only

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(0, heal_amt/parts.len))
			M.update_damage_overlays()

	M.adjustToxLoss(heal_amt)

	if(prob(base_message_chance) && !hide_healing)
		new /obj/effect/temp_visual/heal(get_turf(M), "#FF9933")
	return 1

/*
//////////////////////////////////////

Brute -> burn

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Heals brute damage slowly over time.
	Deals burn damage slowly over time.

//////////////////////////////////////
*/

/datum/symptom/conversion/bruteburn

	name = "Heat Mending"
	desc = "The virus mends flesh togheter by burning it, converting bruises into burns."
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 6

/datum/symptom/conversion/bruteburn/Heal(mob/living/carbon/M, datum/disease/advance/A)
	var/list/parts = M.get_damaged_bodyparts(1, 0) //brute only

	if(!parts.len)
		return

	var/heal_amt = 2 * power / parts.len

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt, 0))
			L.receive_damage(0, heal_amt)
			M.update_damage_overlays()

	if(prob(base_message_chance) && !hide_healing)
		new /obj/effect/temp_visual/heal(get_turf(M), "#FF3333")

	return 1