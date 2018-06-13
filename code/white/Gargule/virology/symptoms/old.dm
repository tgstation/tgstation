/*
//////////////////////////////////////

Weight Even

	Very Noticable.
	Decreases resistance.
	Decreases stage speed.
	Reduced transmittable.
	High level.

Bonus
	Causes the weight of the mob to
	be even, meaning eating isn't
	required anymore.

//////////////////////////////////////
*/

/datum/symptom/weight_even

	name = "Weight Even"
	desc = "The virus mutates the host's metabolism, making it almost unable to lose nutrition"
	stealth = -1
	resistance = 2
	stage_speed = 1
	transmittable = -2
	level = 4
	severity = -1
	symptom_delay_min = 5
	symptom_delay_max = 5

/datum/symptom/weight_even/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			M.overeatduration = 0
			M.nutrition = NUTRITION_LEVEL_WELL_FED + 50

/*
//////////////////////////////////////

Viral aggressive metabolism

	Reduced stealth.
	Small resistance boost.
	Increased stage speed.
	Small transmittablity boost.
	Medium Level.

Bonus
	The virus starts at stage 5, but after a certain time will start curing itself.
	Stages still increase naturally with stage speed.

//////////////////////////////////////
*/

/datum/symptom/viralreverse

	name = "Viral reverse metabolism"
	desc = "The virus very fast reproduce on start of infection, but after few time, looses ability to reproduce."
	stealth = -2
	resistance = 1
	stage_speed = 5
	transmittable = 1
	level = 3
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/time_to_cure

/datum/symptom/viralreverse/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(time_to_cure > 0)
		time_to_cure--
	else
		var/mob/living/M = A.affected_mob
		Heal(M, A)

/datum/symptom/viralreverse/proc/Heal(mob/living/M, datum/disease/advance/A)
	A.stage -= 1
	if(A.stage < 2)
		to_chat(M, "<span class='notice'>You suddenly feel healthy.</span>")
		A.cure()

/datum/symptom/viralreverse/Start(datum/disease/advance/A)
	..()
	A.stage = 5
	if(A.properties["stealth"] >= 4) //more time before it's cured
		power = 2
	time_to_cure = 10+(max(A.properties["resistance"], A.properties["stage_rate"]) * 10 * power)


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
	desc = "The virus bonds with the DNA of the host, protects from negative genetic mutations"
	stealth = 1
	resistance = 1
	stage_speed = 0
	transmittable = -3
	level = 5
	severity = -1
	symptom_delay_min = 3
	symptom_delay_max = 8
	var/archived_dna = null
	var/archived_id = null
	threshold_desc = "---"

/datum/symptom/heal/dna/Start(datum/disease/advance/A)
//	if(!..())
//		return
	var/mob/living/carbon/M = A.affected_mob
	if(M)
		if(!M.has_dna())
			return
		archived_dna = M.dna.unique_enzymes
		archived_id = M.dna.uni_identity

/datum/symptom/heal/dna/Heal(mob/living/carbon/M, datum/disease/advance/A)
	var/amt_healed = 2 * power
	M.adjustBrainLoss(-amt_healed)
	//Non-power mutations, excluding race, so the virus does not force monkey -> human transformations.
	var/list/unclean_mutations = (GLOB.not_good_mutations|GLOB.bad_mutations) - GLOB.mutations_list[RACEMUT]
	M.dna.remove_mutation_group(unclean_mutations)
	M.radiation = max(M.radiation - (2 * amt_healed), 0)

	if(M && archived_dna)
		if(!M.has_dna())
			return
		if(M.dna.unique_enzymes != archived_dna|M.dna.uni_identity != archived_id)
			M.dna.unique_enzymes = archived_dna
			M.dna.uni_identity = archived_id
			M.updateappearance()
			M.domutcheck()

	return 1

