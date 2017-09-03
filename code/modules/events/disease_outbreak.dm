/datum/round_event_control/disease_outbreak
	name = "Disease Outbreak"
	typepath = /datum/round_event/disease_outbreak
	max_occurrences = 1
	min_players = 10
	weight = 5

/datum/round_event/disease_outbreak
	announceWhen	= 15

	var/virus_type

	var/max_severity = 3


/datum/round_event/disease_outbreak/announce()
	priority_announce("Confirmed outbreak of level 7 viral biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", 'sound/ai/outbreak7.ogg')

/datum/round_event/disease_outbreak/setup()
	announceWhen = rand(15, 30)


/datum/round_event/disease_outbreak/start()
	var/advanced_virus = FALSE
	max_severity = 3 + max(Floor((world.time - control.earliest_start)/6000),0) //3 symptoms at 20 minutes, plus 1 per 10 minutes
	if(prob(20 + (10 * max_severity)))
		advanced_virus = TRUE

	if(!virus_type && !advanced_virus)
		virus_type = pick(/datum/disease/dnaspread, /datum/disease/advance/flu, /datum/disease/advance/cold, /datum/disease/brainrot, /datum/disease/magnitis)

	for(var/mob/living/carbon/human/H in shuffle(GLOB.living_mob_list))
		var/turf/T = get_turf(H)
		if(!T)
			continue
		if(T.z != ZLEVEL_STATION)
			continue
		if(!H.client)
			continue
		if(H.stat == DEAD)
			continue
		if(VIRUSIMMUNE in H.dna.species.species_traits) //Don't pick someone who's virus immune, only for it to not do anything.
			continue
		var/foundAlready = FALSE	// don't infect someone that already has a disease
		for(var/thing in H.viruses)
			foundAlready = TRUE
			break
		if(foundAlready)
			continue

		var/datum/disease/D
		if(!advanced_virus)
			if(virus_type == /datum/disease/dnaspread)		//Dnaspread needs strain_data set to work.
				if(!H.dna || (H.disabilities & BLIND))	//A blindness disease would be the worst.
					continue
				D = new virus_type()
				var/datum/disease/dnaspread/DS = D
				DS.strain_data["name"] = H.real_name
				DS.strain_data["UI"] = H.dna.uni_identity
				DS.strain_data["SE"] = H.dna.struc_enzymes
			else
				D = new virus_type()
		else
			D = make_virus(max_severity, max_severity)
		D.carrier = TRUE
		H.AddDisease(D)

		if(advanced_virus)
			var/datum/disease/advance/A = D
			var/list/name_symptoms = list() //for feedback
			for(var/datum/symptom/S in A.symptoms)
				name_symptoms += S.name
			message_admins("An event has triggered a random advanced virus outbreak on [key_name_admin(H)]! It has these symptoms: [english_list(name_symptoms)]")
			log_game("An event has triggered a random advanced virus outbreak on [key_name(H)]! It has these symptoms: [english_list(name_symptoms)]")
		break

/datum/round_event/disease_outbreak/proc/make_virus(max_symptoms, max_level)
	if(max_symptoms > SYMPTOM_LIMIT)
		max_symptoms = SYMPTOM_LIMIT
	var/datum/disease/advance/A = new(FALSE, null)
	A.symptoms = list()
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
