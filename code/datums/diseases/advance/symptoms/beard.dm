/*
//////////////////////////////////////
Facial Hypertrichosis

	Very very Noticable.
	Decreases resistance slightly.
	Decreases stage speed.
	Reduced transmittability
	Intense Level.

BONUS
	Makes the mob grow a massive beard, regardless of gender.

//////////////////////////////////////
*/

/datum/symptom/beard

	name = "Facial Hypertrichosis"
	stealth = -3
	resistance = -1
	stage_speed = -3
	transmittable = -1
	level = 4
	severity = 1

/datum/symptom/beard/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			switch(A.stage)
				if(1, 2)
					if(H.facial_hair_style == "Shaved")
						H.facial_hair_style = "Jensen Beard"
						H.update_hair()
				if(3, 4)
					if(!(H.facial_hair_style == "Dwarf Beard") && !(H.facial_hair_style == "Very Long Beard") && !(H.facial_hair_style == "Full Beard"))
						H.facial_hair_style = "Full Beard"
						H.update_hair()
				else
					if(!(H.facial_hair_style == "Dwarf Beard") && !(H.facial_hair_style == "Very Long Beard"))
						H.facial_hair_style = pick("Dwarf Beard", "Very Long Beard")
						H.update_hair()
	return