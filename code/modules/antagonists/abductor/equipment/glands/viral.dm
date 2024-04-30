/obj/item/organ/internal/heart/gland/viral
	abductor_hint = "contamination incubator. The abductee becomes a carrier of a random advanced disease - of which they are unaffected by."
	cooldown_low = 3 MINUTES
	cooldown_high = 4 MINUTES
	uses = 1
	icon_state = "viral"
	mind_control_uses = 1
	mind_control_duration = 3 MINUTES

/obj/item/organ/internal/heart/gland/viral/activate()
	to_chat(owner, span_warning("You feel sick."))

	var/list/anti = list(
		ANTIGEN_BLOOD	= 1,
		ANTIGEN_COMMON	= 1,
		ANTIGEN_RARE	= 0,
		ANTIGEN_ALIEN	= 0,
	)
	var/list/bad = list(
		EFFECT_DANGER_HELPFUL	= 1,
		EFFECT_DANGER_FLAVOR	= 4,
		EFFECT_DANGER_ANNOYING	= 4,
		EFFECT_DANGER_HINDRANCE	= 0,
		EFFECT_DANGER_HARMFUL	= 0,
		EFFECT_DANGER_DEADLY	= 0,
	)
	var/virus_choice = pick(subtypesof(/datum/disease/advanced)- typesof(/datum/disease/advanced/premade))
	var/datum/disease/advanced/D = new virus_choice

	D.makerandom(list(30,55),list(0,50),anti,bad,null)

	D.log += "<br />[ROUND_TIME()] Infected [key_name(owner)]"
	if(!length(owner))
		owner.diseases = list()
	owner.diseases += D

	D.AddToGoggleView(owner)


/obj/item/organ/internal/heart/gland/viral/proc/random_virus(max_symptoms, max_level)
	if(max_symptoms > VIRUS_SYMPTOM_LIMIT)
		max_symptoms = VIRUS_SYMPTOM_LIMIT
	var/datum/disease/advance/A = new /datum/disease/advance()
	var/list/datum/symptom/possible_symptoms = list()
	for(var/symptom in subtypesof(/datum/symptom))
		var/datum/symptom/S = symptom
		if(initial(S.level) > max_level)
			continue
		if(initial(S.level) <= 0) //unobtainable symptoms
			continue
		possible_symptoms += S
	for(var/i in 1 to max_symptoms)
		var/datum/symptom/chosen_symptom = pick_n_take(possible_symptoms)
		if(chosen_symptom)
			var/datum/symptom/S = new chosen_symptom
			A.symptoms += S
	A.Refresh() //just in case someone already made and named the same disease
	return A
