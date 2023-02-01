/datum/round_event_control/disease_outbreak
	name = "Disease Outbreak: Classic"
	typepath = /datum/round_event/disease_outbreak
	max_occurrences = 1
	min_players = 10
	weight = 5
	category = EVENT_CATEGORY_HEALTH
	description = "A 'classic' virus will infect some members of the crew." //These are the ones with PERSONALITY
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

/datum/round_event/disease_outbreak
	announce_when = 120
	///The disease type we will be spawning
	var/datum/disease/virus_type
	///Disease recipient candidates, passed from the round_event_control object
	var/list/afflicted = list()

/datum/round_event/disease_outbreak/announce(fake)
	priority_announce("Confirmed outbreak of level 7 viral biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", ANNOUNCER_OUTBREAK7)

/datum/round_event/disease_outbreak/setup()
	announce_when = rand(60, 180)

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
	description = "An 'advanced' disease will infect some members of the crew." //These are the ones that get viro lynched!
	admin_setup = /datum/event_admin_setup/disease_outbreak/advanced

/datum/round_event/disease_outbreak/advanced
	///Number of symptoms for our virus
	var/max_severity
	//Maximum symptoms for our virus
	var/max_symptoms

/datum/round_event/disease_outbreak/advanced/start()
	var/datum/round_event_control/disease_outbreak/advanced/disease_event = control
	afflicted += disease_event.disease_candidates
	disease_event.disease_candidates.Cut() //Clean the list after use

	if(!max_symptoms)
		max_symptoms = 3 + max(FLOOR((world.time - control.earliest_start)/6000, 1),0) //3 symptoms at 20 minutes, plus 1 per 10 minutes.
		max_symptoms = clamp(max_symptoms, 3, 8) //Capping the virus symptoms prevents the event from becoming "smite one poor player with an -12 transmission hell virus" after a certain round length.

	if(!max_severity)
		max_severity = 3 + max(FLOOR((world.time - control.earliest_start)/6000, 1),0) //Max severity doesn't need clamping

	var/datum/disease/advance/advanced_disease = new /datum/disease/advance/random(max_symptoms, max_severity)

	var/list/name_symptoms = list() //for feedback
	for(var/datum/symptom/new_symptom in advanced_disease.symptoms)
		name_symptoms += new_symptom.name

	var/mob/living/carbon/human/victim = pick_n_take(afflicted)
	if(victim.ForceContractDisease(advanced_disease, FALSE))
		message_admins("An event has triggered a random advanced virus outbreak on [ADMIN_LOOKUPFLW(victim)]! It has these symptoms: [english_list(name_symptoms)]")
		log_game("An event has triggered a random advanced virus outbreak on [key_name(victim)]! It has these symptoms: [english_list(name_symptoms)].")
		announce_to_ghosts(victim)
	else
		log_game("An event attempted to trigger a random advanced virus outbreak on [key_name(victim)], but failed.")

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
	if(!candidate_check())
		tgui_alert(usr, "There are no candidates eligible to recieve a disease!", "Error")
		return ADMIN_CANCEL_EVENT
	tgui_alert(usr, "[candidate_count] candidates found!", "Disease Outbreak")

	if(tgui_alert(usr, "Select a specific disease?", "Sickening behavior", list("Yes", "No")) == "Yes")
		virus_type = tgui_input_list(usr, "Warning: Some of these are EXTREMELY dangerous.","Bacteria Hysteria", subtypesof(/datum/disease))

/datum/event_admin_setup/disease_outbreak/apply_to_event(datum/round_event/disease_outbreak/event)
	event.virus_type = virus_type

/datum/event_admin_setup/disease_outbreak/advanced
	///Admin selected custom severity rating for the event
	var/max_severity
	///Admin selected custom value for the maximum symptoms this virus should have
	var/max_symptoms

/datum/event_admin_setup/disease_outbreak/advanced/prompt_admins()
	var/candidate_count = candidate_check()
	if(!candidate_check())
		tgui_alert(usr, "There are no candidates eligible to recieve a disease!", "Error")
		return ADMIN_CANCEL_EVENT
	tgui_alert(usr, "[candidate_count] candidates found!", "Disease Outbreak")

	if(tgui_alert(usr,"Customize your virus?", "Glorified Debug Tool", list("Yes", "No")) == "Yes")
		max_severity = tgui_input_number(usr, "Select a custom severity for your virus!", "Plague Incorporation!", 3, 8)
		max_symptoms = tgui_input_number(usr, "How many symptoms do you want your virus to have?", "A pox upon ye!", 3, 15)

/datum/event_admin_setup/disease_outbreak/advanced/apply_to_event(datum/round_event/disease_outbreak/advanced/event)
	event.max_severity = max_severity
	event.max_symptoms = max_symptoms
