/datum/round_event_control/disease_outbreak
	name = "Disease Outbreak: Classic"
	typepath = /datum/round_event/disease_outbreak
	max_occurrences = 1
	min_players = 10
	weight = 5
	category = EVENT_CATEGORY_HEALTH
	description = "A 'classic' virus will infect some members of the crew." //These are the ones with PERSONALITY
	///Disease recipient candidates
	var/list/disease_candidates = list()
	///Admin selected disease, to be passed down to the round_event
	var/chosen_disease

/datum/round_event_control/disease_outbreak/can_spawn_event(players_amt)
	. = ..()
	generate_candidates()
	if(length(disease_candidates))
		return TRUE

/datum/round_event_control/disease_outbreak/admin_setup()
	if(!check_rights(R_FUN))
		return FALSE

	generate_candidates()

	if(!length(disease_candidates))
		message_admins("No disease candidates found!")
		return FALSE

	message_admins("[length(disease_candidates)] candidates found!")

	if(tgui_alert(usr, "Select a specific disease?", "Sickening behavior", list("Yes", "No")) == "Yes")
		var/list/disease_list = list()
		disease_list += subtypesof(/datum/disease)
		chosen_disease = tgui_input_list(usr, "Warning: Some of these are EXTREMELY dangerous.","Bacteria Hysteria", disease_list)

/datum/round_event_control/disease_outbreak/proc/generate_candidates()
	if(length(disease_candidates))
		disease_candidates = list() //Wipe the candidate list clean and start over

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
	afflicted = disease_event.disease_candidates
	if(disease_event.chosen_disease)
		virus_type = disease_event.chosen_disease

	if(!virus_type) //I wanted to handle this by searching through the presets and checking by disease severity defines but we'd still need to filter out some of them anyways.
		var/list/virus_candidates = list()

		//Practically harmless diseases. Mostly just gives medical something to do.
		virus_candidates += list(/datum/disease/flu, /datum/disease/advance/flu, /datum/disease/advance/cold, /datum/disease/cold9, /datum/disease/cold)

		//The more dangerous ones
		virus_candidates += list(/datum/disease/beesease, /datum/disease/brainrot, /datum/disease/tuberculosis, /datum/disease/fluspanish)

		//The wacky ones
		virus_candidates += list(/datum/disease/dnaspread, /datum/disease/magnitis, /datum/disease/anxiety)

		virus_type = pick(virus_candidates)

	var/datum/disease/new_disease
	new_disease = new virus_type()
	new_disease.carrier = TRUE

	infect_players(new_disease)

/datum/round_event/disease_outbreak/proc/infect_players(var/datum/disease/new_disease)
	for(var/i in 1 to 3) //This runtimes whenever the event fires with < 3 candidates pls fix
		var/mob/living/carbon/human/victim = pick_n_take(afflicted)
		victim.ForceContractDisease(new_disease, FALSE, FALSE)
		log_game("An event has given [key_name(victim)] the [new_disease]")
		message_admins("An event has triggered a [new_disease.name] virus outbreak on [ADMIN_LOOKUPFLW(victim)]!")

/datum/round_event_control/disease_outbreak/advanced
	name = "Disease Outbreak: Advanced"
	typepath = /datum/round_event/disease_outbreak/advanced
	category = EVENT_CATEGORY_HEALTH
	description = "An 'advanced' disease will infect some members of the crew."

/datum/round_event_control/disease_outbreak/advanced/admin_setup()
	if(!check_rights(R_FUN))
		return FALSE

	generate_candidates()

	if(!length(disease_candidates))
		message_admins("No disease candidates found!")
		return FALSE

	message_admins("[length(disease_candidates)] candidates found!")

/datum/round_event/disease_outbreak/advanced
	///Number of symptoms for our virus
	var/max_severity = 3

/datum/round_event/disease_outbreak/advanced/start()
	max_severity = 3 + max(FLOOR((world.time - control.earliest_start)/6000, 1),0) //3 symptoms at 20 minutes, plus 1 per 10 minutes
	var/datum/disease/advance/advanced_disease = new /datum/disease/advance/random(max_severity, max_severity)

	infect_players(advanced_disease)

/datum/round_event/disease_outbreak/advanced/infect_players(var/datum/disease/advance/advanced_disease)
	var/list/name_symptoms = list() //for feedback
	for(var/datum/symptom/new_symptom in advanced_disease.symptoms)
		name_symptoms += new_symptom.name

	for(var/i in 1 to 3)
		var/mob/living/carbon/human/victim = pick_n_take(afflicted)
		victim.ForceContractDisease(advanced_disease, FALSE, FALSE)
		message_admins("An event has triggered a random advanced virus outbreak on [ADMIN_LOOKUPFLW(victim)]! It has these symptoms: [english_list(name_symptoms)]")
		log_game("An event has triggered a random advanced virus outbreak on [key_name(victim)]! It has these symptoms: [english_list(name_symptoms)].")
