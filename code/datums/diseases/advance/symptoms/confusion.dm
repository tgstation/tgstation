/*
//////////////////////////////////////

Confusion

	Little bit hidden.
	Lowers resistance.
	Decreases stage speed.
	Intense Level.

Bonus
	Makes the affected mob be confused for short periods of time.

//////////////////////////////////////
*/

/datum/symptom/confusion

	stealth = 1
	resistance = -1
	stage_speed = -3
	level = 4

/datum/symptom/confusion/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3, 4)
				M << "<span class='notice'>[pick("You feel confused.", "You forgot what you were thinking about.")]</span>"
			else
				M << "<span class='notice'>You are unable to think straight!</span>"
				M.confused = min(100, M.confused + 2)

	return
