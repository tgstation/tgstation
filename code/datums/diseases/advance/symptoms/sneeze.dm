/*
//////////////////////////////////////

Sneezing

	Very Noticable.
	Decreases resistance.
	Doesn't increase stage speed.
	Low Level.

Bonus
	Forces a spread type of AIRBORNE
	with extra range!

//////////////////////////////////////
*/

/datum/symptom/sneeze

	stealth = -2
	resistance = -1
	stage_speed = 0
	level = 1

/datum/symptom/sneeze/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB + (A.stage * 2)))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3, 4)
				M.emote("sniffs")
			else
				M.emote("sneeze")
				A.spread(A.holder, 4, AIRBORNE)
	return