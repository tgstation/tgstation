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
	if(prob(SYMPTOM_ACTIVATION_PROB * 10))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				Convert(M)
	return

/datum/symptom/damage_converter/proc/Convert(var/mob/living/M)

	var/get_damage = rand(1, 2)

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M

		var/list/parts = H.get_damaged_organs(1,1) //1,1 because it needs inputs.

		if(!parts.len)
			return

		for(var/obj/item/organ/limb/L in parts)
			L.heal_damage(get_damage, get_damage, 0)

	else
		if(M.getFireLoss() > 0 || M.getBruteLoss() > 0)
			M.adjustFireLoss(-get_damage)
			M.adjustBruteLoss(-get_damage)
		else
			return

	M.adjustToxLoss(get_damage)
	return 1




