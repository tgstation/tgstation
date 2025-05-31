/*DNA Saboteur
 * Lowers stealth
 * Lowers resistance greatly
 * No change to stage speed
 * Decreases transmissibility greatly
 * Fatal level
 * Bonus: Cleans the DNA of a person and then randomly gives them a trait.
*/

/datum/symptom/genetic_mutation
	name = "Dormant DNA Activator"
	desc = "The virus bonds with the DNA of the host, activating random dormant mutations within their DNA. When the virus is cured, the host's genetic alterations are undone."
	illness = "Lycanthropy"
	stealth = -2
	resistance = -3
	stage_speed = 0
	transmittable = -3
	level = 6
	severity = 4
	base_message_chance = 50
	symptom_delay_min = 30
	symptom_delay_max = 60
	var/excludemuts = NONE
	var/no_reset = FALSE
	var/mutadone_proof = NONE
	threshold_descs = list(
		"Resistance 8" = "The negative and mildly negative mutations caused by the virus are mutadone-proof (but will still be undone when the virus is cured if the resistance 14 threshold is not met).",
		"Resistance 14" = "The host's genetic alterations are not undone when the virus is cured.",
		"Stage Speed 10" = "The virus activates dormant mutations at a much faster rate.",
		"Stealth 5" = "Only activates negative mutations in hosts."
	)

/datum/symptom/genetic_mutation/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStealth() >= 5) //only give them bad mutations
		excludemuts = POSITIVE
	if(A.totalStageSpeed() >= 10) //activate dormant mutations more often at around 1.5x the pace
		symptom_delay_min = 20
		symptom_delay_max = 40
	if(A.totalResistance() >= 8) //mutadone won't save you now
		mutadone_proof = (NEGATIVE | MINOR_NEGATIVE)
	if(A.totalResistance() >= 14) //one does not simply escape Nurgle's grasp
		no_reset = TRUE

/datum/symptom/genetic_mutation/Activate(datum/disease/advance/disease)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/carbon = disease.affected_mob
	if(!carbon.has_dna())
		return
	switch(disease.stage)
		if(4, 5)
			to_chat(carbon, span_warning("[pick("Your skin feels itchy.", "You feel light headed.")]"))
			var/datum/mutation/mutation = carbon.get_random_mutation_path((NEGATIVE|MINOR_NEGATIVE|POSITIVE) & ~excludemuts)
			if(!mutation)
				return
			carbon.dna.add_mutation((mutation.quality & mutadone_proof) ? MUTATION_SOURCE_GENE_SYMPTOM : MUTATION_SOURCE_ACTIVATED)

/datum/symptom/genetic_mutation/End(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(!no_reset)
		var/mob/living/carbon/M = A.affected_mob
		if(M.has_dna())
			M.dna.remove_all_mutations(list(MUTATION_SOURCE_GENE_SYMPTOM, MUTATION_SOURCE_ACTIVATED))
