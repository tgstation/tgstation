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
				to_chat(M, "<span class='warning'>[pick("You feel hot.", "You hear a crackling noise.", "You smell smoke.")]</span>")
			if(4)
				Firestacks_stage_4(M, A)
				M.IgniteMob()
				to_chat(M, "<span class='userdanger'>Your skin bursts into flames!</span>")
				M.emote("scream")
			if(5)
				Firestacks_stage_5(M, A)
				M.IgniteMob()
				to_chat(M, "<span class='userdanger'>Your skin erupts into an inferno!</span>")
				M.emote("scream")
	return

/datum/symptom/fire/proc/Firestacks_stage_4(mob/living/M, datum/disease/advance/A)
	var/get_stacks = (sqrt(20+A.totalStageSpeed()*2))-(sqrt(16+A.totalStealth()))
	M.adjust_fire_stacks(get_stacks)
	M.adjustFireLoss(get_stacks/2)
	return 1

/datum/symptom/fire/proc/Firestacks_stage_5(mob/living/M, datum/disease/advance/A)
	var/get_stacks = (sqrt(max(0, 20+A.totalStageSpeed()*3)))-(sqrt(max(0, 16+A.totalStealth())))
	M.adjust_fire_stacks(get_stacks)
	M.adjustFireLoss(get_stacks)
	return 1

/*
//////////////////////////////////////

Alkali perspiration

	Hidden.
	Lowers resistance.
	Decreases stage speed.
	Decreases transmittablity.
	Fatal Level.

Bonus
	Ignites infected mob.
	Explodes mob on contact with water.

//////////////////////////////////////
*/

/datum/symptom/alkali

	name = "Alkali perspiration"
	stealth = 2
	resistance = -2
	stage_speed = -2
	transmittable = -2
	level = 7
	severity = 6

/datum/symptom/alkali/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(3)
				to_chat(M, "<span class='warning'>[pick("Your veins boil.", "You feel hot.", "You smell meat cooking.")]</span>")
			if(4)
				Alkali_fire_stage_4(M, A)
				M.IgniteMob()
				to_chat(M, "<span class='userdanger'>Your sweat bursts into flames!</span>")
				M.emote("scream")
			if(5)
				Alkali_fire_stage_5(M, A)
				M.IgniteMob()
				to_chat(M, "<span class='userdanger'>Your skin erupts into an inferno!</span>")
				M.emote("scream")
				if(M.fire_stacks < 0)
					M.visible_message("<span class='warning'>[M]'s sweat sizzles and pops on contact with water!</span>")
					explosion(M.loc,0,0,2)
					Alkali_fire_stage_5(M, A)
	return

/datum/symptom/alkali/proc/Alkali_fire_stage_4(mob/living/M, datum/disease/advance/A)
	var/get_stacks = (sqrt(20+A.totalStageSpeed()*5))
	M.adjust_fire_stacks(get_stacks)
	M.adjustFireLoss(get_stacks/2)
	M.reagents.add_reagent("clf3", 1)
	return 1

/datum/symptom/alkali/proc/Alkali_fire_stage_5(mob/living/M, datum/disease/advance/A)
	var/get_stacks = (sqrt(20+A.totalStageSpeed()*8))
	M.adjust_fire_stacks(get_stacks)
	M.adjustFireLoss(get_stacks)
	M.reagents.add_reagent_list(list("napalm" = 3, "clf3" = 3))
	return 1
