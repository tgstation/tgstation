/datum/brain_trauma/mild

/datum/brain_trauma/mild/hallucinations
	name = "Hallucinations"
	desc = "Patient suffers constant hallucinations."
	scan_desc = "schizophrenia"
	gain_text = "<span class='warning'>You feel your grip on reality slipping...</span>"
	lose_text = "<span class='notice'>You feel more grounded.</span>"

/datum/brain_trauma/mild/hallucinations/on_life()
	owner.hallucination = min(owner.hallucination + 10, 50)

/datum/brain_trauma/mild/hallucinations/on_lose()
	owner.hallucination = 0

/datum/brain_trauma/mild/stuttering
	name = "Stuttering"
	desc = "Patient can't speak properly."
	scan_desc = "reduced mouth coordination"
	gain_text = "<span class='warning'>Speaking clearly is getting harder.</span>"
	lose_text = "<span class='notice'>You feel in control of your speech.</span>"

/datum/brain_trauma/mild/stuttering/on_life()
	owner.stuttering = min(owner.stuttering + 5, 25)

/datum/brain_trauma/mild/stuttering/on_lose()
	owner.stuttering = 0

/datum/brain_trauma/mild/speech_impediment
	name = "Speech Impediment"
	desc = "Patient is unable to speak in long sentences."
	scan_desc = "communication disorder"
	gain_text = "" //mutation will handle the text
	lose_text = ""

/datum/brain_trauma/mild/speech_impediment/on_gain()
	owner.dna.add_mutation(UNINTELLIGIBLE)
	..()

//no fiddling with genetics to get out of this one
/datum/brain_trauma/severe/speech_impediment/on_life()
	if(!(GLOB.mutations_list[UNINTELLIGIBLE] in owner.dna.mutations))
		on_gain()
	..()

/datum/brain_trauma/mild/speech_impediment/on_lose()
	owner.dna.remove_mutation(UNINTELLIGIBLE)
	..()