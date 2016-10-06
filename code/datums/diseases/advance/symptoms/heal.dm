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

/datum/symptom/heal/metabolism/proc/Heal(mob/living/M, datum/disease/advance/A)
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

/datum/symptom/heal/dna/proc/Heal(mob/living/carbon/M, datum/disease/advance/A)
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
