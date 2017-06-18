/*
//////////////////////////////////////

DNA Saboteur

	Very noticable.
	Lowers resistance tremendously.
	No changes to stage speed.
	Decreases transmittablity tremendously.
	Fatal Level.

Bonus
	Cleans the DNA of a person and then randomly gives them a disability.

//////////////////////////////////////
*/

/datum/symptom/genetic_mutation

	name = "Deoxyribonucleic Acid Saboteur"
	stealth = -2
	resistance = -3
	stage_speed = 0
	transmittable = -3
	level = 6
	severity = 3
	var/list/possible_mutations
	var/archived_dna = null
	base_message_chance = 50
	symptom_delay_min = 60
	symptom_delay_max = 120
	var/no_reset = FALSE

/datum/symptom/genetic_mutation/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/C = A.affected_mob
	if(!C.has_dna())
		return
	switch(A.stage)
		if(4, 5)
			to_chat(C, "<span class='warning'>[pick("Your skin feels itchy.", "You feel light headed.")]</span>")
			C.dna.remove_mutation_group(possible_mutations)
			for(var/i in 1 to power)
				C.randmut(possible_mutations)

// Archive their DNA before they were infected.
/datum/symptom/genetic_mutation/Start(datum/disease/advance/A)
	..()
	if(A.properties["stealth"] >= 5) //don't restore dna after curing
		no_reset = TRUE
	if(A.properties["stage_rate"] >= 10) //mutate more often
		symptom_delay_min = 20
		symptom_delay_max = 60
	if(A.properties["resistance"] >= 8) //mutate twice
		power = 2
	possible_mutations = (GLOB.bad_mutations | GLOB.not_good_mutations) - GLOB.mutations_list[RACEMUT]
	var/mob/living/carbon/M = A.affected_mob
	if(M)
		if(!M.has_dna())
			return
		archived_dna = M.dna.struc_enzymes

// Give them back their old DNA when cured.
/datum/symptom/genetic_mutation/End(datum/disease/advance/A)
	if(!no_reset)
		var/mob/living/carbon/M = A.affected_mob
		if(M && archived_dna)
			if(!M.has_dna())
				return
			M.dna.struc_enzymes = archived_dna
			M.domutcheck()
