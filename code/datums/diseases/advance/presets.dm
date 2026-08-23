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

#define SYMPTOM_KILLER_LEVEL 8 // Level minimum for our killer symptoms
#define SYMPTOM_KILLER_SEVERITY 5 // Severity minimum for our killer symptoms
#define SYMPTOM_BUFFER_LEVEL 3 // Level maximum for other symptoms.
#define SYMPTOM_BUFFER_SEVERITY 1 // Severity minimum for other symptoms.
#define SYMPTOM_BUFFER_NEUTER_PROB 50 // Chance of other symptoms being neutered
#define SYMPTOM_BUFFER_STEALTH_MIN -1 // Minimum stealth stat in other symptoms for stealthy viruses

/datum/disease/advance/random/antag
	name = "Antagonist Disease"
	var/stealthy = FALSE // Whether or not we generate a stealth disease

/datum/disease/advance/random/antag/New()
	if(stealthy)
		symptoms += new /datum/symptom/stats/antag_loud
	else
		symptoms += new /datum/symptom/stats/antag_stealth

	var/symptom_list = shuffle(valid_subtypesof(/datum/symptom))
	var/killer_symptoms = (stealthy ? 1 : rand(1,2)) // How many deadly diseases we have
	for(var/datum/symptom/possible_symptom in symptom_list)
		if(symptoms.len >= VIRUS_SYMPTOM_LIMIT)
			break
		if(possible_symptom.level >= SYMPTOM_KILLER_LEVEL && possible_symptom.severity >= SYMPTOM_KILLER_SEVERITY && killer_symptoms >= 0)
			killer_symptoms--
			symptoms += new possible_symptom()
			continue
		if(possible_symptom.level <= SYMPTOM_BUFFER_LEVEL && possible_symptom.severity >= SYMPTOM_BUFFER_SEVERITY)
			if(stealthy && possible_symptom.stealth < SYMPTOM_BUFFER_STEALTH_MIN)
				continue
			var/new_symptom = new possible_symptom()
			symptoms += new_symptom
			if(prob(SYMPTOM_BUFFER_NEUTER_PROB))
				NeuterSymptom(new_symptom)
			continue

		//Checks if the chosen symptom is severe enough to meet requested severity. If not, pick a new symptom.
		//If we've met requested severity already, we don't care and will keep the chosen symptom.
		var/datum/symptom/new_symptom = new chosen_symptom

		if((current_severity < requested_severity) && (new_symptom.severity < requested_severity))
			continue

		symptoms += new_symptom

		if(new_symptom.severity > current_severity)
			current_severity = new_symptom.severity

	visibility_flags |= HIDDEN_SCANNER
	var/transmissibility = requested_transmissibility

	if(isnull(transmissibility))
		transmissibility = rand(1,100)

	if(requested_transmissibility == ADV_SPREAD_FORCED_LOW) // Admin forced
		set_spread(DISEASE_SPREAD_CONTACT_FLUIDS)

	else if(requested_transmissibility == ADV_SPREAD_FORCED_HIGH) // Admin forced
		set_spread(DISEASE_SPREAD_AIRBORNE)

	//If severe enough, alert immediately on scanners, limit transmissibility
	else if(current_severity >= ADV_DISEASE_DANGEROUS)
		visibility_flags &= ~HIDDEN_SCANNER
		set_spread(DISEASE_SPREAD_CONTACT_SKIN)

	else if(transmissibility < ADV_SPREAD_THRESHOLD)
		set_spread(DISEASE_SPREAD_CONTACT_SKIN)

	else
		visibility_flags &= ~HIDDEN_SCANNER
		set_spread(DISEASE_SPREAD_AIRBORNE)


	//Illness name from one of the symptoms
	var/datum/symptom/picked_name = pick(symptoms)
	name = picked_name.illness

	//Modifiers to keep the disease base stats above 0 (unless RNG gets a really bad roll.)
	//Eternal Youth for +4 to resistance and stage speed.
	//Viral modifiers to slow down/resist or go fast and loud.
	if(prob(66))
		var/list/datum/symptom/possible_modifiers = list(
			/datum/symptom/viraladaptation,
			/datum/symptom/viralevolution,
		)
		var/datum/symptom/chosen_modifier = pick(possible_modifiers)
		symptoms += new chosen_modifier
		symptoms += new /datum/symptom/youth

	Refresh()

/**
 * Assign virus properties
 *
 * Now that we've picked our symptoms and severity, we determine the other stats
 * (Stage Speed, Resistance, Transmissibility)
 * The LOW/MID percentiles can be adjusted in the defines.
 * If the virus is severity DANGEROUS we do not hide it from health scanners at event start.
 * If the virus is airborne, also don't hide it.
 */
/datum/disease/advance/random/event/assign_properties()

	if(!length(properties))
		stack_trace("Advanced virus properties were empty or null!")
		return

	incubation_time = round(world.time + (((ADV_ANNOUNCE_DELAY * 2) - 10) SECONDS))
	properties["transmittable"] = rand(4,7)
	spreading_modifier = max(CEILING(0.4 * properties["transmittable"], 1), 1)
	cure_chance = clamp(10 * (0.94 ** properties["resistance"]), 3.5, 12)
	stage_prob = max(0.4 * properties["stage_rate"], 1) // Faster than regular advanced diseases
	set_severity(properties["severity"])

	//If we have an advanced (high stage) disease, add it to the name.
	if(properties["stage_rate"] >= 7)
		name = "Advanced [name]"

/**
 * Set the transmission methods on the generated virus
 *
 * Apply the transmission methods we rolled in the assign_properties proc
 */
/datum/disease/advance/random/event/set_spread(spread_id)
	switch(spread_id)
		if(DISEASE_SPREAD_CONTACT_FLUIDS)
			update_spread_flags(DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_FLUIDS)
			spread_text = "Fluids"
		if(DISEASE_SPREAD_CONTACT_SKIN)
			update_spread_flags(DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_FLUIDS | DISEASE_SPREAD_CONTACT_SKIN)
			spread_text = "Skin contact"
		if(DISEASE_SPREAD_AIRBORNE)
			update_spread_flags(DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_FLUIDS | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_AIRBORNE)
			spread_text = "Respiration"
