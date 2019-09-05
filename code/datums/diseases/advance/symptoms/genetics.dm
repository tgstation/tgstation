/*
//////////////////////////////////////

DNA Saboteur

	Very noticable.
	Lowers resistance tremendously.
	No changes to stage speed.
	Decreases transmittablity tremendously.
	Fatal Level.

Bonus
	Cleans the DNA of a person and then randomly gives them a trait.

//////////////////////////////////////
*/

/datum/symptom/genetic_mutation
	name = "Deoxyribonucleic Acid Saboteur"
	desc = "The virus bonds with the DNA of the host, activating random dormant mutations within their DNA. When the virus is cured, all of the mutations in the host's DNA are made dormant (again)."
	stealth = -2
	resistance = -3
	stage_speed = 0
	transmittable = -3
	level = 6
	severity = 4
	base_message_chance = 50
	symptom_delay_min = 60
	symptom_delay_max = 90
	var/badtothebone = FALSE
	var/no_reset = FALSE
	var/mutadone_proof = FALSE
	threshold_desc = "<b>Resistance 8:</b> The host's mutations aren't cleansed when the virus leaves the host.<br>\
					  <b>Resistance 14:</b> The negative mutations caused by this virus are mutadone-proof.<br>\
					  <b>Stage Speed 10:</b> The virus activates dormant mutations more often.<br>\
					  <b>Stealth 5:</b> Only activates negative mutations in hosts."

/datum/symptom/genetic_mutation/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stealth"] >= 5) //only give them bad mutations
		badtothebone = TRUE
	if(A.properties["stage_rate"] >= 10) //activate dormant mutations more often
		symptom_delay_min = 20
		symptom_delay_max = 60
	if(A.properties["resistance"] >= 8) //the mutations won't go away when the virus is cured
		no_reset = TRUE
	if(A.properties["resistance"] >= 14) //if the virus's resistance stat meets this threshold, may God help you
		mutadone_proof = TRUE

/datum/symptom/genetic_mutation/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/C = A.affected_mob
	if(!C.has_dna())
		return
	switch(A.stage)
		if(4, 5)
			to_chat(C, "<span class='warning'>[pick("Your skin feels itchy.", "You feel light headed.")]</span>")
			if(badtothebone)
				C.easyrandmut(NEGATIVE + MINOR_NEGATIVE, TRUE, TRUE, TRUE, mutadone_proof)
			else
				C.easyrandmut(NEGATIVE + MINOR_NEGATIVE + POSITIVE, TRUE, TRUE, TRUE, mutadone_proof)

/datum/symptom/genetic_mutation/End(datum/disease/advance/A)
	if(!..())
		return
	if(!no_reset)
		var/mob/living/carbon/M = A.affected_mob
		if(M.has_dna())
			M.dna.remove_all_mutations(list(MUT_NORMAL, MUT_EXTRA), FALSE)
