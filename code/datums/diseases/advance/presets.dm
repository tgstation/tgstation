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

#define SYMPTOM_KILLER_LEVEL 8 /// Level minimum for our killer symptoms
#define SYMPTOM_KILLER_SEVERITY 5 /// Severity minimum for our killer symptoms
#define SYMPTOM_KILLER_LEVEL_PENALTY 2 /// Level minimum and maximum penalty for picking two symptoms so we don't trash our stats
#define SYMPTOM_KILLER_SEVERITY_PENALTY 2 /// Severity minimum penalty for picking two symptoms
#define SYMPTOM_BUFFER_LEVEL 3 /// Level maximum for other symptoms
#define SYMPTOM_BUFFER_SEVERITY 1 /// Severity minimum for other symptoms
#define SYMPTOM_BUFFER_NEUTER_PROB_LOUD 40 /// Chance of other symptoms being neutered in a non stealth virus
#define SYMPTOM_BUFFER_NEUTER_PROB_STEALTHY 65 /// Chance of other symptoms being neutered in a stealth virus
#define SYMPTOM_BUFFER_STEALTH_MIN -1 /// Minimum stealth stat in other symptoms for stealthy viruses

/datum/disease/advance/antag
	name = "Antagonist Disease"
	var/stealthy = FALSE // Whether or not we generate a stealth disease

/datum/disease/advance/antag/New()
	var/free_symptom
	if(stealthy)
		free_symptom = new /datum/symptom/stats/antag_stealth
	else
		free_symptom = new /datum/symptom/stats/antag_loud
	symptoms += free_symptom
	NeuterSymptom(free_symptom)
	var/list/symptom_list = shuffle(valid_subtypesof(/datum/symptom))
	var/killer_symptoms = (stealthy ? 1 : rand(1,2)) // How many deadly symptoms we have
	for(var/datum/symptom/possible_symptom as anything in symptom_list)
		if(symptoms.len >= VIRUS_SYMPTOM_LIMIT)
			break
		if((possible_symptom.level >= SYMPTOM_KILLER_LEVEL) && (possible_symptom.severity >= SYMPTOM_KILLER_SEVERITY) && killer_symptoms > 0)
			killer_symptoms--
			symptoms += new possible_symptom
			continue
		if(possible_symptom.level <= SYMPTOM_BUFFER_LEVEL && possible_symptom.level > 0 && possible_symptom.severity >= SYMPTOM_BUFFER_SEVERITY && (symptoms.len + killer_symptoms < VIRUS_SYMPTOM_LIMIT))
			if(stealthy && possible_symptom.stealth < SYMPTOM_BUFFER_STEALTH_MIN)
				continue
			var/new_symptom = new possible_symptom
			symptoms += new_symptom
			var/neuter_chance = (stealthy ? SYMPTOM_BUFFER_NEUTER_PROB_STEALTHY : SYMPTOM_BUFFER_NEUTER_PROB_LOUD)
			if(prob(neuter_chance))
				NeuterSymptom(new_symptom)
	name = generate_virus_name()
	Refresh()

/datum/disease/advance/antag/stealthy
	stealthy = TRUE

#undef SYMPTOM_KILLER_LEVEL
#undef SYMPTOM_KILLER_SEVERITY
#undef SYMPTOM_KILLER_LEVEL_PENALTY
#undef SYMPTOM_KILLER_SEVERITY_PENALTY
#undef SYMPTOM_BUFFER_LEVEL
#undef SYMPTOM_BUFFER_SEVERITY
#undef SYMPTOM_BUFFER_NEUTER_PROB_LOUD
#undef SYMPTOM_BUFFER_NEUTER_PROB_STEALTHY
#undef SYMPTOM_BUFFER_STEALTH_MIN
