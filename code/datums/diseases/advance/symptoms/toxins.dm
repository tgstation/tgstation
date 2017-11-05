/*
//////////////////////////////////////

Toxin Filter

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Heals toxins in the affected mob's blood stream.

//////////////////////////////////////
*/

/datum/symptom/heal/toxin
	name = "Toxic Filter"
	desc = "The virus synthesizes regenerative chemicals in the bloodstream, repairing damage caused by toxins."
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 6

/datum/symptom/heal/toxin/Heal(mob/living/M, datum/disease/advance/A)
	var/heal_amt = power
	if(M.toxloss > 0 && prob(base_message_chance) && !hide_healing)
		new /obj/effect/temp_visual/heal(get_turf(M), "#66FF99")
	M.adjustToxLoss(-heal_amt)
	return 1

/*
//////////////////////////////////////

Toxic Compensation

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Reduced transmittablity
	Intense Level.

Bonus
	Slowly converts brute/fire damage to toxin.

//////////////////////////////////////
*/

/datum/symptom/heal/damage_converter
	name = "Toxic Compensation"
	desc = "The virus regenerates flesh and tissue at expense of toxin production."
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -2
	level = 4
	threshold_desc = "<b>Stage Speed 6:</b> Doubles conversion speed.<br>\
					  <b>Stage Speed 11:</b> Triples conversion speed.<br>\
					  <b>Stealth 4:</b> Healing will no longer be visible to onlookers."

/datum/symptom/heal/damage_converter/Heal(mob/living/M, datum/disease/advance/A)
	var/cvt_amt = 2 * power

	if(iscarbon(M))
		var/mob/living/carbon/C = M

		var/list/parts = C.get_damaged_bodyparts(1, 1)

		if(!parts.len)
			return

		for(var/obj/item/bodypart/L in parts)
			if(L.heal_damage(cvt_amt/parts.len, cvt_amt/parts.len))
				C.update_damage_overlays()

	else
		if(M.getFireLoss() > 0 || M.getBruteLoss() > 0)
			M.adjustFireLoss(-cvt_amt)
			M.adjustBruteLoss(-cvt_amt)
		else
			return

	if(prob(base_message_chance) && !hide_healing)
		new /obj/effect/temp_visual/heal(get_turf(M), "#FF6600")

	M.adjustToxLoss(cvt_amt)
	return 1



