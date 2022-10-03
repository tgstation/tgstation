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

/datum/round_event_control/disease_outbreak/can_spawn_event(players_amt)
	. = ..()
	if(!.)
		return .
	generate_candidates()
	if(length(disease_candidates))
		return TRUE

/datum/round_event_control/disease_outbreak/proc/generate_candidates()
	for(var/mob/living/carbon/human/candidate in shuffle(GLOB.player_list)) //Player list is much more up to date and requires less checks(?)
		if(!(candidate.mind.assigned_role.job_flags & JOB_CREW_MEMBER) || candidate.stat == DEAD)
			continue
		if(HAS_TRAIT(candidate, TRAIT_VIRUSIMMUNE)) //Don't pick someone who's virus immune, only for it to not do anything.
			continue
		var/foundAlready = FALSE // don't infect someone that already has a disease
		for(var/thing in candidate.diseases)
			foundAlready = TRUE
			break
		if(foundAlready)
			continue
/datum/round_event/disease_outbreak
	announce_when = 15
	///The disease type we will be spawning
	var/datum/disease/virus_type
	///Disease recipient candidates, passed from the round_event_control object
	var/list/afflicted = list()

/datum/round_event/disease_outbreak/announce(fake)
	priority_announce("Confirmed outbreak of level 7 viral biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", ANNOUNCER_OUTBREAK7)

/datum/round_event/disease_outbreak/setup()
	announce_when = rand(15, 30)

/datum/round_event/disease_outbreak/start()
	var/datum/round_event_control/disease_outbreak/disease_event = control

	afflicted = disease_event.disease_candidates //Pick our NUMBER here (do this later)

	if(!virus_type)
		virus_type = pick(/datum/disease/dnaspread, /datum/disease/advance/flu, /datum/disease/advance/cold, /datum/disease/brainrot, /datum/disease/magnitis)


	var/datum/disease/new_disease
	new_disease = new virus_type()
	//if(virus_type == /datum/disease/dnaspread) //Dnaspread needs strain_data set to work.
	//	if(!H.dna || (HAS_TRAIT(H, TRAIT_BLIND))) //A blindness disease would be the worst.
	//		continue
	//	new_disease = new virus_type()
	//	var/datum/disease/dnaspread/DS = new_disease
	//	DS.strain_data["name"] = H.real_name
	//	DS.strain_data["UI"] = H.dna.unique_identity
	//	DS.strain_data["SE"] = H.dna.mutation_index
	new_disease.carrier = TRUE //fuck you virus code I'm not dealing with your dna spread snowflake bullshit right now
	for(var/mob/living/carbon/human/victim in afflicted)
		victim.ForceContractDisease(new_disease, FALSE, TRUE)
		log_game("An event has given [key_name(victim)] the [new_disease]")

/datum/round_event_control/disease_outbreak/advanced
	name = "Disease Outbreak: Advanced"
	typepath = /datum/round_event/disease_outbreak/advanced
	category = EVENT_CATEGORY_HEALTH
	description = "An advanced disease will infect some crewmembers."

/datum/round_event/disease_outbreak/advanced
	///Number of symptoms for our virus
	var/max_severity = 3

/datum/round_event_control/disease_outbreak/advanced/generate_candidates()
	return TRUE

/datum/round_event/disease_outbreak/advanced/start()
	max_severity = 3 + max(FLOOR((world.time - control.earliest_start)/6000, 1),0) //3 symptoms at 20 minutes, plus 1 per 10 minutes
	var/datum/disease/advance/advanced_disease = new /datum/disease/advance/random(max_severity, max_severity)
	var/list/name_symptoms = list() //for feedback
	for(var/datum/symptom/new_symptom in advanced_disease.symptoms)
		name_symptoms += new_symptom.name

	for(var/mob/living/carbon/human/victim in afflicted)
		victim.ForceContractDisease(advanced_disease, FALSE, TRUE)
		message_admins("An event has triggered a random advanced virus outbreak on [ADMIN_LOOKUPFLW(victim)]! It has these symptoms: [english_list(name_symptoms)]")
		log_game("An event has triggered a random advanced virus outbreak on [key_name(victim)]! It has these symptoms: [english_list(name_symptoms)].")
