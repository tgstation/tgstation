/datum/symptom/viral_readaption

	name = "Viral Readaption Secretion"
	stealth = -7
	resistance = -7
	stage_speed = -7
	transmittable = -7
	level = 6

/datum/symptom/viral_readaption/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				if (M.reagents.get_reagent_amount("viral_readaption") < 20)
					M.reagents.add_reagent("viral_readaption", 20)
	return
