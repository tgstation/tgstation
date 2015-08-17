/datum/symptom/FEV

	name = "FEV"
	stealth = -7
	resistance = -7
	stage_speed = -7
	transmittable = -7
	level = 6

/datum/symptom/FEV/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 5))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				if (M.reagents.get_reagent_amount("FEV") < 20)
					M.reagents.add_reagent("FEV", 20)
	return
