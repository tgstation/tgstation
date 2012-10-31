// Symptoms are the effects that engineered advanced diseases do.

var/list/list_symptoms = typesof(/datum/symptom) - /datum/symptom

var/global/const/SYMPTOM_ACTIVATION_PROB = 1

/datum/symptom
	// Buffs/Debuffs the symptom has to the overall engineered disease.
	var/stealth = 0
	var/resistance = 0
	var/stage_speed = 0
	var/transmittable = 0
	// The type level of the symptom. Higher is more lethal and harder to generate.
	var/level = 0
	// The hash tag for our diseases, we will add it up with our other symptoms to get a unique id! ID MUST BE UNIQUE!!!
	var/id = ""

/datum/symptom/New()
	var/list/S = list_symptoms
	for(var/i = 1; i <= S.len; i++)
		if(src.type == S[i])
			id = "[i]"
			return
	CRASH("We couldn't assign an ID!")


/datum/symptom/proc/Activate(var/mob/living/M, var/stage)
	return

