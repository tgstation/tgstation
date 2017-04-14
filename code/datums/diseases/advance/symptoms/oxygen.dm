/*
//////////////////////////////////////

Self-Respiration

	Slightly hidden.
	Lowers resistance significantly.
	Decreases stage speed significantly.
	Decreases transmittablity tremendously.
	Fatal Level.

Bonus
	The body generates salbutamol.

//////////////////////////////////////
*/

/datum/symptom/oxygen

	name = "Self-Respiration"
	stealth = 1
	resistance = -3
	stage_speed = -3
	transmittable = -4
	level = 6

/datum/symptom/oxygen/Activate(datum/disease/advance/A)
	..()
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			M.adjustOxyLoss(-3, 0)
			if(M.losebreath >= 4)
				M.losebreath -= 2
		else
			if(prob(SYMPTOM_ACTIVATION_PROB * 3))
				to_chat(M, "<span class='notice'>[pick("Your lungs feel great.", "You realize you haven't been breathing.", "You don't feel the need to breathe.")]</span>")
	return
