/datum/symptom/explosive // ~I'm the bomb and i'm about to blow up!~
	name = "Explosive Glands"
	desc = "The virus produces explosive reagents and stores them within various areas of the body."
	stealth = -2
	resistance = -1
	stage_speed = 0
	transmittable = -3
	level = 12
	severity = 8
	threshold_descs = list(
		"Stealth 8" = "Symptom remains completely hidden until it's fully active.",
		"Resistance 12" = "Doubles the amount of explosive reagents capable of being stored within the body.",
		"Transmission 6" = "The virus steadily increases the host's bodily temperature, making it easier to set off the explosives.",
	)
	var/chemmult = 1
	var/tempmodifier = FALSE
	var/messagechance = 10

/datum/symptom/explosive/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStealth() >= 8)
		messagechance = 0
	if(A.totalResistance() >= 12)
		chemmult = 2
	if(A.totalTransmittable() >= 6)
		tempmodifier = TRUE

/datum/symptom/explosive/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1)
			if(prob(messagechance))
				to_chat(M, span_notice("You feel blubbery..."))
		if(2, 3)
			if(prob(messagechance))
				to_chat(M, span_danger("You feel like your innards are going to implode..."))
		if(4, 5)
			if(!M.reagents.has_reagent(/datum/reagent/gunpowder,(15*chemmult)))
				M.reagents.add_reagent(/datum/reagent/gunpowder, 1.1)
			if(tempmodifier)
				M.adjust_bodytemperature(40 * TEMPERATURE_DAMAGE_COEFFICIENT) // Haha, no limit bitches. Hope you like blowing the fuck up.
