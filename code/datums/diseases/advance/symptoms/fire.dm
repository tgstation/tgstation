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
			if(3)
				M << "<span class='warning'>[pick("You feel hot.", "You hear a crackling noise.", "You smell smoke.")]</span>"
			if(4)
				M.adjust_fire_stacks(5)
				M.IgniteMob()
				M << "<span class='userdanger'>Your skin bursts into flames!</span>"
				M.adjustFireLoss(5)
				M.emote("scream")
			if(5)
				M.adjust_fire_stacks(10)
				M.IgniteMob()
				M << "<span class='userdanger'>Your skin erupts into an inferno!</span>"
				M.adjustFireLoss(10)
				M.emote("scream")
	return