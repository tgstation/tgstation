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

/datum/symptom/damage_converter/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 10))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				Convert(M)
	return

/datum/symptom/damage_converter/proc/Convert(mob/living/carbon/C)

	var/heal_amt = rand(1, 2)

	var/list/parts = C.get_damaged_bodyparts(1,1) //1,1 because it needs inputs.

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt, heal_amt))
			C.update_damage_overlays()
	C.adjustToxLoss(heal_amt*parts.len)
	PoolOrNew(/obj/effect/overlay/temp/heal, list(C), "#FF3399")
	return 1

/*
//////////////////////////////////////

Damage Converter (uranium)

	Less Stealth easier to work with.
	Lowers resistance.
	Decreases stage speed.
	Uranium only

Bonus
	Slowly converts brute/fire damage to toxin even faster without limb compensation

//////////////////////////////////////
*/

/datum/symptom/damage_converter_uranium

	name = "Toxic metabolism"
	stealth = 0
	resistance = -2
	stage_speed = -2
	transmittable = 0
	level = 7

/datum/symptom/damage_converter_uranium/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 15))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				Convert(M)
	return

/datum/symptom/damage_converter_uranium/proc/Convert(mob/living/M)

	var/get_damage = rand(1, 2)

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M

		var/list/parts = H.get_damaged_bodyparts(1,1)

		if(!parts.len)
			return

		for(var/obj/item/bodypart/L in parts)
			L.heal_damage(get_damage, get_damage, 0)
		M.adjustToxLoss(get_damage)

	else
		if(M.getFireLoss() > 0 || M.getBruteLoss() > 0)
			M.adjustFireLoss(-get_damage)
			M.adjustBruteLoss(-get_damage)
			M.adjustToxLoss(get_damage)
		else
			return
	PoolOrNew(/obj/effect/overlay/temp/heal, list(get_turf(M), "#FFFF00"))
	return 1