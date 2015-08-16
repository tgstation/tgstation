/*
//////////////////////////////////////

Spontaneous Combustion

	Slightly hidden.
	Lowers resistance tremendously.
	Decreases stage tremendously.
	Decreases transmittablity tremendously.
	Fatal Level.

Bonus
	Ignites infected mob.

//////////////////////////////////////
*/

/datum/symptom/fire

	name = "Spontaneous Combustion"
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 6
	severity = 5

/datum/symptom/fire/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4)
				M.adjust_fire_stacks(5)
				M.IgniteMob()

			if(5)
				M.adjust_fire_stacks(10)
				M.IgniteMob()
	return