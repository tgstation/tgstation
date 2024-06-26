/datum/symptom/bluespace
	name = "Bluespace Manifestation"
	desc = "The virus becomes suseptible to foreign bluespace energies and will randomly manifest these energies within the host, leading to spontaneous teleportation."
	stealth = -4
	resistance = 2
	stage_speed = 2
	transmittable = 2
	level = 12
	severity = 6

/datum/symptom/bluespace/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1)
			if(prob(10))
				to_chat(M, span_notice("You feel rather unstable..."))
		if(2, 3)
			if(prob(10))
				to_chat(M, span_danger("You feel like you're in two places at once..."))
		if(4, 5)
			if(prob(5) && !M.reagents.has_reagent(/datum/reagent/bluespace))
				M.reagents.add_reagent(/datum/reagent/bluespace, 10)
