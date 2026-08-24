// Cold
/datum/disease/advance/cold
	name = "Cold"
	symptoms = list(new/datum/symptom/sneeze)

// Flu
/datum/disease/advance/flu
	name = "Flu"
	symptoms = list(new/datum/symptom/cough)

//Randomly generated Disease, for virus crates and events
/datum/disease/advance/random
	name = "Experimental Disease"

/datum/disease/advance/random/New(max_symptoms, max_level = 8)
	if(!max_symptoms)
		max_symptoms = rand(1, VIRUS_SYMPTOM_LIMIT)
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
			symptoms += S
	Refresh()

	name = "Sample #[rand(1,10000)]"

/datum/disease/advance/antag
	name = "Antagonist Disease"
	var/killer_symptoms = 1
	var/killer_symptom_level = 8
	var/killer_symptom_severity = 5
	var/buffer_neuter_chance = 40
	var/buffer_symptom_level = 3
	var/buffer_stealth_min = -100
	var/free_symptom = /datum/symptom/stats/antag_loud

/datum/disease/advance/antag/New()
	free_symptom = new free_symptom
	symptoms += free_symptom
	NeuterSymptom(free_symptom)
	var/list/symptom_list = shuffle(valid_subtypesof(/datum/symptom))
	for(var/datum/symptom/possible_symptom as anything in symptom_list)
		if(symptoms.len >= VIRUS_SYMPTOM_LIMIT)
			break
		if(!possible_symptom.can_generate_randomly())
			continue
		if((possible_symptom.level >= killer_symptom_level) && (possible_symptom.severity >= killer_symptom_severity) && killer_symptoms > 0)
			killer_symptoms--
			symptoms += new possible_symptom
			continue
		if(possible_symptom.level <= buffer_symptom_level && possible_symptom.level > 0 && possible_symptom.severity > 0 && (symptoms.len + killer_symptoms < VIRUS_SYMPTOM_LIMIT))
			if(possible_symptom.stealth < buffer_stealth_min)
				continue
			var/new_symptom = new possible_symptom
			symptoms += new_symptom
			if(prob(buffer_neuter_chance))
				NeuterSymptom(new_symptom)
	name = generate_virus_name()
	Refresh()

/datum/disease/advance/antag/stealthy
	free_symptom = /datum/symptom/stats/antag_stealth
	buffer_neuter_chance = 65
	buffer_stealth_min = 0
