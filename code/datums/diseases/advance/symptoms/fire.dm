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
				Firestacks_stage_4(M, A)
				M.IgniteMob()
				M << "<span class='userdanger'>Your skin bursts into flames!</span>"
				M.emote("scream")
			if(5)
				Firestacks_stage_5(M, A)
				M.IgniteMob()
				M << "<span class='userdanger'>Your skin erupts into an inferno!</span>"
				M.emote("scream")
	return

/datum/symptom/fire/proc/Firestacks_stage_4(mob/living/M, datum/disease/advance/A)
	var/get_stacks = (sqrt(20+A.totalStageSpeed()*2))-(sqrt(16+A.totalStealth()))
	M.adjust_fire_stacks(get_stacks)
	M.adjustFireLoss(get_stacks/2)
	return 1

/datum/symptom/fire/proc/Firestacks_stage_5(mob/living/M, datum/disease/advance/A)
	var/get_stacks = (sqrt(20+A.totalStageSpeed()*3))-(sqrt(16+A.totalStealth()))
	M.adjust_fire_stacks(get_stacks)
	M.adjustFireLoss(get_stacks)
	return 1