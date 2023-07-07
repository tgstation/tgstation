/*
Necrotizing Fasciitis (AKA Flesh-Eating Disease)
	Very very noticable.
	Lowers resistance tremendously.
	No changes to stage speed.
	Decreases transmissibility tremendously.
	Fatal Level.
Bonus
	Deals brute damage over time.
*/
/datum/symptom/flesh_eating
	name = "Necrotizing Fasciitis"
	desc = "The virus aggressively attacks bone cells, causing excessive wobbliness and falling down a lot."
	illness = "Jellyitis"
	stealth = -3
	resistance = -4
	stage_speed = 0
	transmittable = -3
	level = 6
	severity = 5
	base_message_chance = 50
	symptom_delay_min = 15
	symptom_delay_max = 60
	var/bleed = FALSE
	var/pain = FALSE
	threshold_descs = list(
		"Resistance 7" = "Host will bleed profusely during necrosis.",
		"Transmission 8" = "Causes extreme pain to the host, weakening it.",
	)

/datum/symptom/flesh_eating/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalResistance() >= 7) //extra bleeding
		bleed = TRUE
	if(A.totalTransmittable() >= 8) //extra stamina damage
		pain = TRUE

/datum/symptom/flesh_eating/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2,3)
			if(prob(base_message_chance))
				to_chat(M, span_warning("[pick("You feel a sudden pain across your body.", "Drops of blood appear suddenly on your skin.")]"))
		if(4,5)
			to_chat(M, span_userdanger("[pick("You cringe as a violent pain takes over your body.", "It feels like your body is eating itself inside out.", "IT HURTS.")]"))
			Flesheat(M, A)

/datum/symptom/flesh_eating/proc/Flesheat(mob/living/M, datum/disease/advance/A)
	var/get_damage = rand(15,25) * power
	M.take_overall_damage(brute = get_damage, required_bodytype = BODYTYPE_ORGANIC)
	if(pain)
		M.adjustStaminaLoss(get_damage * 2)
	if(bleed)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/bodypart/random_part = pick(H.bodyparts)
			random_part.adjustBleedStacks(5 * power)
	return 1

/*
//////////////////////////////////////

Autophagocytosis (AKA Programmed mass cell death)

	Very noticable.
	Lowers resistance.
	Fast stage speed.
	Decreases transmittablity.
	Fatal Level.

Bonus
	Deals brute damage over time.

//////////////////////////////////////
*/

/datum/symptom/flesh_death

	name = "Autophagocytosis Necrosis"
	desc = "The virus rapidly consumes infected cells, leading to heavy and widespread damage."
	illness = "Premature Mummification"
	stealth = -2
	resistance = -2
	stage_speed = 1
	transmittable = -2
	level = 7
	severity = 6
	base_message_chance = 50
	symptom_delay_min = 3
	symptom_delay_max = 6
	var/chems = FALSE
	var/zombie = FALSE
	threshold_descs = list(
		"Stage Speed 7" = "Synthesizes Heparin and Lipolicide inside the host, causing increased bleeding and hunger.",
		"Stealth 5" = "The symptom remains hidden until active.",
	)

/datum/symptom/flesh_death/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStealth() >= 5)
		suppress_warning = TRUE
	if(A.totalStageSpeed() >= 7) //bleeding and hunger
		chems = TRUE

/datum/symptom/flesh_death/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2,3)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, span_warning("[pick("You feel your body break apart.", "Your skin rubs off like dust.")]"))
		if(4,5)
			if(prob(base_message_chance / 2)) //reduce spam
				to_chat(M, span_userdanger("[pick("You feel your muscles weakening.", "Some of your skin detaches itself.", "You feel sandy.")]"))
			Flesh_death(M, A)

/datum/symptom/flesh_death/proc/Flesh_death(mob/living/M, datum/disease/advance/A)
	var/get_damage = rand(6,10)
	M.take_overall_damage(brute = get_damage, required_bodytype = BODYTYPE_ORGANIC)
	if(chems)
		M.reagents.add_reagent_list(list(/datum/reagent/toxin/heparin = 2, /datum/reagent/toxin/lipolicide = 2))
	if(zombie)
		M.reagents.add_reagent(/datum/reagent/romerol, 1)
	return 1
