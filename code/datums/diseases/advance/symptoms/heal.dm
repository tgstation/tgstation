/*
//////////////////////////////////////

Healing

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Heals toxins in the affected mob's blood stream.

//////////////////////////////////////
*/

/datum/symptom/heal

	name = "Toxic Filter"
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 6

/datum/symptom/heal/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 10))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				Heal(M, A)
	return

/datum/symptom/heal/proc/Heal(mob/living/M, datum/disease/advance/A)
	var/get_damage = (sqrt(20+A.totalStageSpeed())*(1+rand()))
	if(M.toxloss > 0)
		PoolOrNew(/obj/effect/overlay/temp/heal, list(get_turf(M), "#66FF99"))
	M.adjustToxLoss(-get_damage)
	return 1

/*
//////////////////////////////////////

Apoptosis

	Lowers resistance.
	Decreases stage speed.
	Decreases transmittablity.

Bonus
	Heals toxins in the affected mob's blood stream faster.

//////////////////////////////////////
*/

/datum/symptom/heal/plus

	name = "Apoptoxin filter"
	stealth = 0
	resistance = -2
	stage_speed = -2
	transmittable = -2
	level = 8

/datum/symptom/heal/plus/Heal(mob/living/M, datum/disease/advance/A)
	if(M.toxloss > 0)
		PoolOrNew(/obj/effect/overlay/temp/heal, list(get_turf(M), "#00FF00"))
	var/get_damage = (sqrt(20+A.totalStageSpeed())*(2+rand()))
	M.adjustToxLoss(-get_damage)
	return 1

/*
//////////////////////////////////////

Regeneration

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Heals brute damage slowly over time.

//////////////////////////////////////
*/

/datum/symptom/heal/brute

	name = "Regeneration"
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 6

/datum/symptom/heal/brute/Heal(mob/living/carbon/M, datum/disease/advance/A)
	var/heal_amt = rand(1, 2)

	var/list/parts = M.get_damaged_bodyparts(1,1) //1,1 because it needs inputs.

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt, 0))
			M.update_damage_overlays()
	PoolOrNew(/obj/effect/overlay/temp/heal, list(M), "#FF3333")
	return 1


/*
//////////////////////////////////////

Flesh Mending

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Heals brute damage over time. Turns cloneloss into burn damage.

//////////////////////////////////////
*/

/datum/symptom/heal/brute/plus

	name = "Flesh Mending"
	stealth = 0
	resistance = 0
	stage_speed = -2
	transmittable = -2
	level = 8

/datum/symptom/heal/brute/plus/Heal(mob/living/carbon/M, datum/disease/advance/A)
	var/heal_amt = rand(2, 4)

	var/list/parts = M.get_damaged_bodyparts(1,1) //1,1 because it needs inputs.

	if(M.getCloneLoss() > 0)
		M.adjustCloneLoss(-1)
		M.take_bodypart_damage(0, 2)
		PoolOrNew(/obj/effect/overlay/temp/heal, list(M), "#33FFCC")

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt, 0))
			M.update_damage_overlays()
	PoolOrNew(/obj/effect/overlay/temp/heal, list(M), "#CC1100")
	return 1

/*
//////////////////////////////////////

Tissue Regrowth

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Heals burn damage slowly over time.

//////////////////////////////////////
*/

/datum/symptom/heal/burn

	name = "Tissue Regrowth"
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 6

/datum/symptom/heal/burn/Heal(mob/living/carbon/M, datum/disease/advance/A)
	var/heal_amt = rand(1, 2)

	var/list/parts = M.get_damaged_bodyparts(1,1) //1,1 because it needs inputs.

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(0, heal_amt))
			M.update_damage_overlays()
	PoolOrNew(/obj/effect/overlay/temp/heal, list(M), "#FF9933")
	return 1


/*
//////////////////////////////////////

Heat Resistance

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Heals burn damage over time, and helps stabilize body temperature.

//////////////////////////////////////
*/

/datum/symptom/heal/burn/plus

	name = "Heat Resistance"
	stealth = 0
	resistance = 0
	stage_speed = -2
	transmittable = -2
	level = 8

/datum/symptom/heal/burn/plus/Heal(mob/living/carbon/M, datum/disease/advance/A)
	var/heal_amt = rand(2, 4)

	var/list/parts = M.get_damaged_bodyparts(1,1) //1,1 because it needs inputs.

	if(M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (heal_amt * TEMPERATURE_DAMAGE_COEFFICIENT))
		PoolOrNew(/obj/effect/overlay/temp/heal, list(M), "#FF3300")
	else if(M.bodytemperature < 311)
		M.bodytemperature = min(310, M.bodytemperature + (heal_amt * TEMPERATURE_DAMAGE_COEFFICIENT))
		PoolOrNew(/obj/effect/overlay/temp/heal, list(M), "#0000FF")

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(0, heal_amt))
			M.update_damage_overlays()
	PoolOrNew(/obj/effect/overlay/temp/heal, list(M), "#CC6600")
	return 1


/*
//////////////////////////////////////

Metabolism

	Little bit hidden.
	Lowers resistance.
	Decreases stage speed.
	Decreases transmittablity temrendously.
	High Level.

Bonus
	Cures all diseases (except itself) and creates anti-bodies for them until the symptom dies.

//////////////////////////////////////
*/

/datum/symptom/heal/metabolism

	name = "Anti-Bodies Metabolism"
	stealth = -1
	resistance = -1
	stage_speed = -1
	transmittable = -4
	level = 3
	var/list/cured_diseases = list()

/datum/symptom/heal/metabolism/Heal(mob/living/M, datum/disease/advance/A)
	var/cured = 0
	for(var/datum/disease/D in M.viruses)
		if(D != A)
			cured = 1
			cured_diseases += D.GetDiseaseID()
			D.cure()
	if(cured)
		M << "<span class='notice'>You feel much better.</span>"

/datum/symptom/heal/metabolism/End(datum/disease/advance/A)
	// Remove all the diseases we cured.
	var/mob/living/M = A.affected_mob
	if(istype(M))
		if(cured_diseases.len)
			for(var/res in M.resistances)
				if(res in cured_diseases)
					M.resistances -= res
		M << "<span class='warning'>You feel weaker.</span>"


/*
//////////////////////////////////////

	DNA Restoration

	Not well hidden.
	Lowers resistance minorly.
	Does not affect stage speed.
	Decreases transmittablity greatly.
	Very high level.

Bonus
	Heals brain damage, treats radiation, cleans SE of non-power mutations.

//////////////////////////////////////
*/

/datum/symptom/heal/dna

	name = "Deoxyribonucleic Acid Restoration"
	stealth = -1
	resistance = -1
	stage_speed = 0
	transmittable = -3
	level = 5

/datum/symptom/heal/dna/Heal(mob/living/carbon/M, datum/disease/advance/A)
	var/stage_speed = max( 20 + A.totalStageSpeed(), 0)
	var/stealth_amount = max( 16 + A.totalStealth(), 0)
	var/amt_healed = (sqrt(stage_speed*(3+rand())))-(sqrt(stealth_amount*rand()))
	if(M.brainloss > 0)
		PoolOrNew(/obj/effect/overlay/temp/heal, list(M), "#DDDDDD")
	M.adjustBrainLoss(-amt_healed)
	//Non-power mutations, excluding race, so the virus does not force monkey -> human transformations.
	var/list/unclean_mutations = (not_good_mutations|bad_mutations) - mutations_list[RACEMUT]
	if(unclean_mutations.len)
		PoolOrNew(/obj/effect/overlay/temp/heal, list(M), "#00FFFF")
	M.dna.remove_mutation_group(unclean_mutations)
	if(M.radiation > 0)
		PoolOrNew(/obj/effect/overlay/temp/heal, list(M), "#88FFFF")
	M.radiation = max(M.radiation - 3, 0)
	return 1
