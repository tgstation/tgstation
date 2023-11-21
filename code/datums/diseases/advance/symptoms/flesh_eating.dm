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
