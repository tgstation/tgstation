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
	desc = "The virus bonds with the DNA of the host, causing damaging mutations until removed."
	stealth = -2
	resistance = -3
	stage_speed = 0
	transmittable = -3
	level = 6
	severity = 4
	var/list/possible_mutations
	var/archived_dna = null
	base_message_chance = 50
	symptom_delay_min = 60
	symptom_delay_max = 120
	var/no_reset = FALSE
	threshold_desc = "<b>Resistance 8:</b> Causes two harmful mutations at once.<br>\
					  <b>Stage Speed 10:</b> Increases mutation frequency.<br>\
					  <b>Stealth 5:</b> The mutations persist even if the virus is cured."

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
	if(!..())
		return
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
	if(!..())
		return
	if(!no_reset)
		var/mob/living/carbon/M = A.affected_mob
		if(M && archived_dna)
			if(!M.has_dna())
				return
			M.dna.struc_enzymes = archived_dna
			M.domutcheck()

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

/datum/symptom/dna

	name = "Deoxyribonucleic Acid Restoration"
	desc = "The virus repairs the host's genome, purging negative mutations."
	stealth = -1
	resistance = -1
	stage_speed = 0
	transmittable = -3
	level = 5
	base_message_chance = 20
	symptom_delay_min = 3
	symptom_delay_max = 8
	threshold_desc = "<b>Stage Speed 6:</b> Additionally heals brain damage.<br>\
					  <b>Stage Speed 11:</b> Increases brain damage healing."

/datum/symptom/dna/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 6) //stronger healing
		power = 2
	if(A.properties["stage_rate"] >= 11) //even stronger healing
		power = 3

/datum/symptom/dna/Activate(datum/disease/advance/A)
	if(!..())
		return
	 //100% chance to activate for slow but consistent healing
	var/mob/living/L = A.affected_mob
	if(!iscarbon(L))
		return
	switch(A.stage)
		if(4, 5)
			var/mob/living/carbon/M = L
			var/amt_healed = 2 * (power - 1)
			M.adjustBrainLoss(-amt_healed)
			//Non-power mutations, excluding race, so the virus does not force monkey -> human transformations.
			var/list/unclean_mutations = (GLOB.not_good_mutations|GLOB.bad_mutations) - GLOB.mutations_list[RACEMUT]
			M.dna.remove_mutation_group(unclean_mutations)
			M.radiation = max(M.radiation - (2 * amt_healed), 0)
			return 1
