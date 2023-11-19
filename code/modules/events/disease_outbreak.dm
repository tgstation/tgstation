/datum/round_event_control/disease_outbreak
	name = "Disease Outbreak: Classic"
	typepath = /datum/round_event/disease_outbreak
	max_occurrences = 1
	min_players = 10
	weight = 5
	category = EVENT_CATEGORY_HEALTH
	description = "A 'classic' virus will infect some members of the crew."
	min_wizard_trigger_potency = 2
	max_wizard_trigger_potency = 6
	admin_setup = list(/datum/event_admin_setup/minimum_candidate_requirement/disease_outbreak, /datum/event_admin_setup/listed_options/disease_outbreak)
	///Disease recipient candidates
	var/list/disease_candidates = list()

/datum/round_event_control/disease_outbreak/can_spawn_event(players_amt, allow_magic = FALSE)
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
	disease_candidates.Cut() //We clear the list and rebuild it again.
	for(var/mob/living/carbon/human/candidate in shuffle(GLOB.player_list)) //Player list is much more up to date and requires less checks(?)
		if(!(candidate.mind.assigned_role.job_flags & JOB_CREW_MEMBER) || candidate.stat == DEAD)
			continue
		if(HAS_TRAIT(candidate, TRAIT_VIRUSIMMUNE)) //Don't pick someone who's virus immune, only for it to not do anything.
			continue
		if(length(candidate.diseases)) //Is our candidate already sick?
			continue
		disease_candidates += candidate

///Handles checking and alerting admins about the number of valid candidates
/datum/event_admin_setup/minimum_candidate_requirement/disease_outbreak
	output_text = "There are no candidates eligible to recieve a disease!"

/datum/event_admin_setup/minimum_candidate_requirement/disease_outbreak/count_candidates()
	var/datum/round_event_control/disease_outbreak/disease_control = event_control
	disease_control.generate_candidates() //can_spawn_event() is bypassed by admin_setup, so this makes sure that the candidates are still generated
	return length(disease_control.disease_candidates)


///Handles actually selecting whicch disease will spawn.
/datum/event_admin_setup/listed_options/disease_outbreak
	input_text = "Select a specific disease? Warning: Some are EXTREMELY dangerous."
	normal_run_option = "Random Classic Disease (Safe)"
	special_run_option = "Entirely Random Disease (Dangerous)"

/datum/event_admin_setup/listed_options/disease_outbreak/get_list()
	return subtypesof(/datum/disease)

/datum/event_admin_setup/listed_options/disease_outbreak/apply_to_event(datum/round_event/disease_outbreak/event)
	var/datum/disease/virus
	if(chosen == special_run_option)
		virus = pick(get_list())
	else
		virus = chosen
	event.virus_type = virus

/datum/round_event/disease_outbreak
	announce_when = 75
	///The disease type we will be spawning
	var/datum/disease/virus_type
	///The preset (classic) or generated (advanced) illness name
	var/illness_type = ""
	///Disease recipient candidates, passed from the round_event_control object
	var/list/afflicted = list()

/datum/round_event/disease_outbreak/announce(fake)
	priority_announce("Confirmed outbreak of level 7 viral biohazard aboard [station_name()]. All personnel must contain the outbreak.", "[illness_type] Alert", ANNOUNCER_OUTBREAK7)

/datum/round_event/disease_outbreak/start()
	var/datum/round_event_control/disease_outbreak/disease_event = control
	afflicted += disease_event.disease_candidates
	disease_event.disease_candidates.Cut() //Clean the list after use
	if(!virus_type)
		var/list/virus_candidates = list()

		//Practically harmless diseases. Mostly just gives medical something to do.
		virus_candidates += list(/datum/disease/flu, /datum/disease/cold9)

		//The more dangerous ones
		virus_candidates += list(/datum/disease/beesease, /datum/disease/brainrot, /datum/disease/fluspanish)

		//The wacky ones
		virus_candidates += list(/datum/disease/magnitis, /datum/disease/anxiety)

		//The rest of the diseases either aren't conventional "diseases" or are too unique/extreme to be considered for a normal event
		virus_type = pick(virus_candidates)

	var/datum/disease/new_disease
	new_disease = new virus_type()
	new_disease.carrier = TRUE
	illness_type = new_disease.name

	var/mob/living/carbon/human/victim
	while(length(afflicted))
		victim = pick_n_take(afflicted)
		if(victim.ForceContractDisease(new_disease, FALSE))
			message_admins("Event triggered: Disease Outbreak - [new_disease.name] starting with patient zero [ADMIN_LOOKUPFLW(victim)]!")
			log_game("Event triggered: Disease Outbreak - [new_disease.name] starting with patient zero [key_name(victim)].")
			announce_to_ghosts(victim)
			return
		CHECK_TICK //don't lag the server to death
	if(isnull(victim))
		log_game("Event Disease Outbreak: Classic attempted to start, but failed.")

