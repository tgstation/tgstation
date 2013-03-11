/*
//////////////////////////////////////

Hyphema (Eye bleeding)

	Slightly noticable.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity.
	Critical Level.

Bonus
	Causes blindness.

//////////////////////////////////////
*/

/datum/symptom/visionloss

	name = "Hyphema"
	stealth = -1
	resistance = -4
	stage_speed = -4
	transmittable = -3
	level = 5

/datum/symptom/visionloss/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2)
				M << "<span class='notice'>Your eyes itch.</span>"
			if(3, 4)
				M << "<span class='notice'>Your eyes ache.</span>"
				M.eye_blurry = 10
				M.eye_stat += 1
			else
				M << "<span class='danger'>Your eyes burn horrificly!</span>"
				M.eye_blurry = 20
				M.eye_stat += 5
				if (M.eye_stat >= 10)
					M.disabilities |= NEARSIGHTED
					if (prob(M.eye_stat - 10 + 1) && !(M.sdisabilities & BLIND))
						M << "<span class='danger'>You go blind!</span>"
						M.sdisabilities |= BLIND
	return