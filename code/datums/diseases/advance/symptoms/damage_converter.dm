/*
//////////////////////////////////////

Damage Converter

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Reduced transmittablity
	Intense Level.

Bonus
	Slowly converts brute/fire damage to toxin.

//////////////////////////////////////
*/

/datum/symptom/damage_converter

	name = "Toxic Compensation"
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -2
	level = 4

/datum/symptom/damage_converter/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				Convert(M)
	return

/datum/symptom/damage_converter/proc/Convert(var/mob/living/M)

	if(M.getFireLoss() < M.getMaxHealth() || M.getBruteLoss() < M.getMaxHealth())
		var/get_damage = rand(1, 2)
		M.adjustFireLoss(-get_damage)
		M.adjustBruteLoss(-get_damage)
		M.adjustToxLoss(get_damage)
		return 1