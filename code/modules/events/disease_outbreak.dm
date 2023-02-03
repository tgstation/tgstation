/// Advanced virus lower limit for symptoms
#define ADV_MIN_SYMPTOMS 3
/// Advanced virus upper limit for symptoms
#define ADV_MAX_SYMPTOMS 4
/// How long the virus stays hidden before announcement
#define ADV_ANNOUNCE_DELAY 75
/// Numerical define for medium severity advanced virus
#define ADV_DISEASE_MEDIUM 4
/// Numerical define for harmful severity advanced virus
#define ADV_DISEASE_HARMFUL 5
/// Numerical define for dangerous severity advanced virus
#define ADV_DISEASE_DANGEROUS 7
/// Percentile for low severity advanced virus
#define ADV_RNG_LOW 30
/// Percentile for mid severity advanced virus
#define ADV_RNG_MID 85
/// Percentile for low transmissibility advanced virus
#define ADV_SPREAD_LOW 30
/// Percentile for mid transmissibility advanced virus
#define ADV_SPREAD_MID 90

/datum/round_event_control/disease_outbreak
	name = "Disease Outbreak: Classic"
	typepath = /datum/round_event/disease_outbreak
	max_occurrences = 1
	min_players = 10
	weight = 5
	category = EVENT_CATEGORY_HEALTH
	description = "A 'classic' virus will infect some members of the crew."
	admin_setup = /datum/event_admin_setup/disease_outbreak
	///Disease recipient candidates
	var/list/disease_candidates = list()

/datum/round_event_control/disease_outbreak/can_spawn_event(players_amt)
	. = ..()
	if(!.)
		return .
	generate_candidates()
	if(length(disease_candidates))
		return TRUE

/**
 * Creates a list of people who are elligible to become disease carriers for the event
 *
 * Searches through the player list, adding anyone who is elligible to be a disease carrier for the event. This checks for
 * whether or not the candidate is alive, a crewmember, is able to recieve a disease, and whether or not a disease is already present in them.
 * This proc needs to be run at some point to ensure the event has candidates to infect.
 */
/datum/round_event_control/disease_outbreak/proc/generate_candidates()
	for(var/mob/living/carbon/human/candidate in shuffle(GLOB.player_list)) //Player list is much more up to date and requires less checks(?)
		if(!(candidate.mind.assigned_role.job_flags & JOB_CREW_MEMBER) || candidate.stat == DEAD)
			continue
		if(HAS_TRAIT(candidate, TRAIT_VIRUSIMMUNE)) //Don't pick someone who's virus immune, only for it to not do anything.
			continue
		if(length(candidate.diseases)) //Is our candidate already sick?
			continue
		disease_candidates += candidate

/datum/event_admin_setup/disease_outbreak
	///Admin selected disease, to be passed down to the round_event
	var/virus_type

/// Checks for candidates. Returns false if there isn't enough
/datum/event_admin_setup/disease_outbreak/proc/candidate_check()
	var/datum/round_event_control/disease_outbreak/disease_control = event_control
	disease_control.generate_candidates() //can_spawn_event() is bypassed by admin_setup, so this makes sure that the candidates are still generated
	return length(disease_control.disease_candidates)

/datum/event_admin_setup/disease_outbreak/prompt_admins()
	var/candidate_count = candidate_check()
	if(!candidate_count)
		tgui_alert(usr, "There are no candidates eligible to recieve a disease!", "Error")
		return ADMIN_CANCEL_EVENT
	tgui_alert(usr, "[candidate_count] candidates found!", "Disease Outbreak")

	if(tgui_alert(usr, "Select a specific disease?", "Sickening behavior", list("Yes", "No")) == "Yes")
		virus_type = tgui_input_list(usr, "Warning: Some of these are EXTREMELY dangerous.","Bacteria Hysteria", subtypesof(/datum/disease))

/datum/event_admin_setup/disease_outbreak/apply_to_event(datum/round_event/disease_outbreak/event)
	event.virus_type = virus_type

/datum/round_event/disease_outbreak
	announce_when = ADV_ANNOUNCE_DELAY
	///The disease type we will be spawning
	var/datum/disease/virus_type
	///Disease recipient candidates, passed from the round_event_control object
	var/list/afflicted = list()

/datum/round_event/disease_outbreak/announce(fake)
	priority_announce("Confirmed outbreak of level 7 viral biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", ANNOUNCER_OUTBREAK7)

/datum/round_event/disease_outbreak/setup()
	announce_when = ADV_ANNOUNCE_DELAY

/datum/round_event/disease_outbreak/start()
	var/datum/round_event_control/disease_outbreak/disease_event = control
	afflicted += disease_event.disease_candidates
	disease_event.disease_candidates.Cut() //Clean the list after use
	if(!virus_type)
		var/list/virus_candidates = list()

		//Practically harmless diseases. Mostly just gives medical something to do.
		virus_candidates += list(/datum/disease/flu, /datum/disease/advance/flu, /datum/disease/advance/cold, /datum/disease/cold9, /datum/disease/cold)

		//The more dangerous ones
		virus_candidates += list(/datum/disease/beesease, /datum/disease/brainrot, /datum/disease/fluspanish)

		//The wacky ones
		virus_candidates += list(/datum/disease/dnaspread, /datum/disease/magnitis, /datum/disease/anxiety, /datum/disease/pierrot_throat)

		//The rest of the diseases either aren't conventional "diseases" or are too unique/extreme to be considered for a normal event
		virus_type = pick(virus_candidates)

	var/datum/disease/new_disease
	new_disease = new virus_type()
	new_disease.carrier = TRUE

	var/mob/living/carbon/human/victim = pick_n_take(afflicted)
	if(victim.ForceContractDisease(new_disease, FALSE))
		log_game("An event has given [key_name(victim)] the [new_disease]")
		message_admins("An event has triggered a [new_disease.name] virus outbreak on [ADMIN_LOOKUPFLW(victim)]!")
		announce_to_ghosts(victim)
	else
		log_game("An event attempted to trigger a [new_disease.name] virus outbreak on [key_name(victim)], but failed.")

/datum/round_event_control/disease_outbreak/advanced
	name = "Disease Outbreak: Advanced"
	typepath = /datum/round_event/disease_outbreak/advanced
	category = EVENT_CATEGORY_HEALTH
	weight = 10
	description = "An 'advanced' disease will infect some members of the crew."
	admin_setup = /datum/event_admin_setup/disease_outbreak/advanced

/datum/event_admin_setup/disease_outbreak/advanced
	///Admin selected custom severity rating for the event
	var/chosen_severity
	///Admin selected custom value for the maximum symptoms this virus should have
	var/chosen_max_symptoms

/**
 * Admin virus customization
 *
 * If the admin wishes, give them the opportunity to select the severity and number of symptoms.
 */
/datum/event_admin_setup/disease_outbreak/advanced/prompt_admins()
	var/candidate_count = candidate_check()
	if(!candidate_count)
		tgui_alert(usr, "There are no candidates eligible to recieve a disease!", "Error")
		return ADMIN_CANCEL_EVENT
	tgui_alert(usr, "[candidate_count] candidates found!", "Disease Outbreak")

	if(tgui_alert(usr,"Customize your virus?", "Glorified Debug Tool", list("Yes", "No")) == "Yes")
		chosen_severity = tgui_alert(usr, "Pick a severity!", "In the event of an airborne virus, try not to breathe.", list("Medium", "Harmful", "Dangerous"))
		switch(chosen_severity)
			if("Medium")
				chosen_severity = ADV_DISEASE_MEDIUM
			if("Harmful")
				chosen_severity = ADV_DISEASE_HARMFUL
			if("Dangerous")
				chosen_severity = ADV_DISEASE_DANGEROUS
			else
				return ADMIN_CANCEL_EVENT

		chosen_max_symptoms = tgui_input_number(usr, "How many symptoms do you want your virus to have?", "A pox upon ye!", 4, 15)

	else
		chosen_severity = null
		chosen_max_symptoms = null

	if(tgui_alert(usr,"Are you happy with your selections?", "Epidemic warning, Standby!", list("Yes", "Cancel")) != "Yes")
		return ADMIN_CANCEL_EVENT

/datum/event_admin_setup/disease_outbreak/advanced/apply_to_event(datum/round_event/disease_outbreak/advanced/event)
	event.max_severity = chosen_severity
	event.max_symptoms = chosen_max_symptoms

/datum/round_event/disease_outbreak/advanced
	///Number of symptoms for our virus
	var/max_severity
	//Maximum symptoms for our virus
	var/max_symptoms

/**
 * Generate virus base values
 *
 * Generates a virus with either the admin selected parameters for severity and symptoms
 * or if it was not selected, randomly pick between the MIX and MAX configured in the defines.
 */
/datum/round_event/disease_outbreak/advanced/start()
	var/datum/round_event_control/disease_outbreak/advanced/disease_event = control
	afflicted += disease_event.disease_candidates
	disease_event.disease_candidates.Cut()

	if(!max_symptoms)
		max_symptoms = rand(ADV_MIN_SYMPTOMS, ADV_MAX_SYMPTOMS)

	if(!max_severity)
		var/rng_severity = rand(1, 100)
		if(rng_severity < ADV_RNG_LOW)
			max_severity = ADV_DISEASE_MEDIUM

		else if(rng_severity < ADV_RNG_MID)
			max_severity = ADV_DISEASE_HARMFUL

		else
			max_severity = ADV_DISEASE_DANGEROUS

	var/datum/disease/advance/advanced_disease = new /datum/disease/advance/random/event(max_symptoms, max_severity)

	var/list/name_symptoms = list()
	for(var/datum/symptom/new_symptom as anything in advanced_disease.symptoms)
		name_symptoms += new_symptom.name

	var/mob/living/carbon/human/victim = pick_n_take(afflicted)
	if(victim.ForceContractDisease(advanced_disease, FALSE))
		message_admins("An event has triggered a random advanced virus outbreak on [ADMIN_LOOKUPFLW(victim)]! It has these symptoms: [english_list(name_symptoms)]. It is transmissable via [advanced_disease.spread_text].")
		log_game("An event has triggered a random advanced virus outbreak on [key_name(victim)]! It has these symptoms: [english_list(name_symptoms)]. It is transmissable via [advanced_disease.spread_text].")
		announce_to_ghosts(victim)
	else
		log_game("An event attempted to trigger a random advanced virus outbreak on [key_name(victim)], but failed.")

/datum/disease/advance/random/event
	name = "Experimental Disease"
	copy_type = /datum/disease/advance

/datum/round_event/disease_outbreak/advance/setup()
	announce_when = ADV_ANNOUNCE_DELAY

/**
 * Generate advanced virus
 *
 * Uses the parameters to create a list of symptoms, picking from various severities
 * Viral Evolution and Eternal Youth are special modifiers, so we roll separately.
 */

/datum/disease/advance/random/event/New(max_symptoms, max_severity)
	var/list/datum/symptom/possible_symptoms = list(
		/datum/symptom/beard,
		/datum/symptom/chills,
		/datum/symptom/choking,
		/datum/symptom/confusion,
		/datum/symptom/cough,
		/datum/symptom/deafness,
		/datum/symptom/dizzy,
		/datum/symptom/fever,
		/datum/symptom/headache,
		/datum/symptom/itching,
		/datum/symptom/shedding,
		/datum/symptom/sneeze,
		/datum/symptom/vomit,
		/datum/symptom/weight_loss,
	)

	switch(max_severity)
		if(ADV_DISEASE_HARMFUL)
			possible_symptoms += list(
				/datum/symptom/disfiguration,
				/datum/symptom/hallucigen,
				/datum/symptom/polyvitiligo,
				/datum/symptom/visionloss,
			)

		if(ADV_DISEASE_DANGEROUS)
			possible_symptoms += list(
				/datum/symptom/alkali,
				/datum/symptom/asphyxiation,
				/datum/symptom/fire,
				/datum/symptom/flesh_death,
				/datum/symptom/flesh_eating,
				/datum/symptom/narcolepsy,
				/datum/symptom/voice_change,
			)

	for(var/i in 1 to max_symptoms)
		var/datum/symptom/chosen_symptom = pick_n_take(possible_symptoms)
		if(chosen_symptom)
			var/datum/symptom/new_symptom = new chosen_symptom
			symptoms += new_symptom

	if(prob(50))
		symptoms += new /datum/symptom/viralevolution

	if(prob(50))
		symptoms += new /datum/symptom/youth

	Refresh()

	name = "Sample #[rand(1, 9999)]"

/**
 * Assign virus properties
 *
 * Now that we've picked our symptoms and severity, we determine the other stats
 * (Stage Speed, Resistance, Transmissibility)
 * The LOW/MID percentiles can be adjusted in the defines.
 * If the virus is severity DANGEROUS we do not hide it from health scanners at event start.
 * If the virus is airborne, also don't hide it.
 */
/datum/disease/advance/random/event/AssignProperties()
	var/transmissibility = rand(1, 100)

	addtimer(CALLBACK(src, PROC_REF(MakeVisible)), ((ADV_ANNOUNCE_DELAY * 2) - 10) SECONDS)

	if(length(properties))
		spreading_modifier = max(CEILING(0.4 * properties["transmittable"], 1), 1)
		cure_chance = clamp(7.5 - (0.5 * properties["resistance"]), 5, 10) // Can be between 5 and 10
		stage_prob = max(0.5 * properties["stage_rate"], 1)
		SetSeverity(properties["severity"])
		visibility_flags |= HIDDEN_SCANNER
		switch(severity)
			if("Dangerous", "BIOHAZARD")
				visibility_flags &= ~HIDDEN_SCANNER

		GenerateCure(properties)

		if(transmissibility < ADV_SPREAD_LOW)
			SetSpread(DISEASE_SPREAD_CONTACT_FLUIDS)

		else if(transmissibility < ADV_SPREAD_MID)
			SetSpread(DISEASE_SPREAD_CONTACT_SKIN)

		else
			SetSpread(DISEASE_SPREAD_AIRBORNE)
			visibility_flags &= ~HIDDEN_SCANNER

	else
		CRASH("Advanced virus properties were empty or null!")

/**
 * Set the transmission methods on the generated virus
 *
 * Apply the transmission methods we rolled in the AssignProperties proc
 */
/datum/disease/advance/random/event/SetSpread(spread_id)
	switch(spread_id)
		if(DISEASE_SPREAD_CONTACT_FLUIDS)
			spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_FLUIDS
			spread_text = "fluids"
		if(DISEASE_SPREAD_CONTACT_SKIN)
			spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_FLUIDS | DISEASE_SPREAD_CONTACT_SKIN
			spread_text = "skin contact"
		if(DISEASE_SPREAD_AIRBORNE)
			spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_FLUIDS | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_AIRBORNE
			spread_text = "respiration"

/**
 * Determine the cure
 *
 * Rolls one of six possible cure groups, then selects a cure from it and applies it to the virus.
 */
/datum/disease/advance/random/event/GenerateCure()
	if(!length(properties))
		stack_trace("Advanced virus properties were empty or null!")
		return
	var/res = rand(1, 6)
	if(res == oldres)
		return
	cures = list(pick(advance_cures[res]))
	oldres = res
	// Get the cure name from the cure_id
	var/datum/reagent/cure = GLOB.chemical_reagents_list[cures[1]]
	cure_text = cure.name

#undef ADV_MIN_SYMPTOMS
#undef ADV_MAX_SYMPTOMS
#undef ADV_ANNOUNCE_DELAY
#undef ADV_DISEASE_MEDIUM
#undef ADV_DISEASE_HARMFUL
#undef ADV_DISEASE_DANGEROUS
#undef ADV_RNG_LOW
#undef ADV_RNG_MID
#undef ADV_SPREAD_LOW
#undef ADV_SPREAD_MID
