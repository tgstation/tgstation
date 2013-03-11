/*
//////////////////////////////////////

Hallucigen

	Very noticable.
	Lowers resistance considerably.
	Decreases stage speed.
	Reduced transmittable.
	Critical Level.

Bonus
	Makes the affected mob be hallucinated for short periods of time.

//////////////////////////////////////
*/

/datum/symptom/hallucigen

	name = "Hallucigen"
	stealth = -2
	resistance = -3
	stage_speed = -3
	transmittable = -1
	level = 5

/datum/symptom/hallucigen/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3, 4)
				M << "<span class='notice'>[pick("You notice someone in the corner of your eye.", "Is that footsteps?.")]</span>"
			else
				M.hallucination += 5

	return
