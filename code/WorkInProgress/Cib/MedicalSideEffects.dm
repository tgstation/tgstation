// MEDICAL SIDE EFFECT BASE
// ========================
/datum/medical_effect/var/name = "None"
/datum/medical_effect/var/strength = 0
/datum/medical_effect/proc/on_life(mob/living/carbon/human/H, strength)
/datum/medical_effect/proc/cure(mob/living/carbon/human/H)


// MOB HELPERS
// ===========
/mob/living/carbon/human/var/list/datum/medical_effect/side_effects = list()
/mob/proc/add_side_effect(name, strength = 0)
/mob/living/carbon/human/add_side_effect(name, strength = 0)
	for(var/datum/medical_effect/M in src.side_effects) if(M.name == name)
		M.strength = max(M.strength, strength = 10)
		return

	var/list/L = typesof(/datum/medical_effect)-/datum/medical_effect

	for(var/T in L)
		var/datum/medical_effect/M = new T
		if(M.name == name)
			M.strength = strength
			side_effects += M

/mob/living/carbon/human/proc/handle_medical_side_effects()
	// One full cycle(in terms of strength) every 10 minutes
	var/strength_percent = sin(life_tick / 300)

	// Only do anything if the effect is currently strong enough
	if(strength_percent >= 0.4)
		for (var/datum/medical_effect/M in side_effects)
			if (M.cure())
				side_effects -= M
				del(M)
			else
				if(life_tick % 30 == 0)
					M.on_life(src, strength_percent*M.strength)
				// Effect slowly growing stronger
				M.strength+=0.2

// HEADACHE
// ========
/datum/medical_effect/headache/name = "Headache"
/datum/medical_effect/headache/on_life(mob/living/carbon/human/H, strength)
	switch(strength)
		if(1 to 10)
			H.custom_pain("You feel a light pain in your head.",0)
		if(11 to 30)
			H.custom_pain("You feel a throbbing pain in your head!",1)
		if(31 to 99)
			H.custom_pain("You feel an excrutiating pain in your head!",1)
			H.adjustBrainLoss(1)
		if(99 to INFINITY)
			H.custom_pain("It feels like your head is about to split open!",1)
			H.adjustBrainLoss(3)
			var/datum/organ/external/O = H.organs_by_name["head"]
			O.take_damage(0, 1, 0, "Headache")

/datum/medical_effect/headache/cure(mob/living/carbon/human/H)
	if(H.reagents.has_reagent("alkysine"))
		return 1
	return 0