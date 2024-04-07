// Cold
/datum/disease/advance/cold
	copy_type = /datum/disease/advance

/datum/disease/advance/cold/New()
	name = "Cold"
	symptoms = list(new/datum/symptom/sneeze)
	..()

// Flu
/datum/disease/advance/flu
	copy_type = /datum/disease/advance

/datum/disease/advance/flu/New()
	name = "Flu"
	symptoms = list(new/datum/symptom/cough)
	..()

// Syndicate stuff

/datum/disease/advance/syndicate
	copy_type = /datum/disease/advance

/datum/disease/advance/syndicate/New()
	name = "Syndicate Virus Gene"
	symptoms = list(new/datum/symptom/syndicatebuff)
	..()

/datum/disease/advance/syndicate/stealth
	copy_type = /datum/disease/advance

/datum/disease/advance/syndicate/stealth/New()
	name = "Syndicate Stealthy Virus Gene"
	symptoms = list(new/datum/symptom/syndicatebuffstealth)
	..()

/datum/disease/advance/syndicate/resist
	copy_type = /datum/disease/advance

/datum/disease/advance/syndicate/resist/New()
	name = "Syndicate Resistant Virus Gene"
	symptoms = list(new/datum/symptom/syndicatebuffresist)
	..()

/datum/disease/advance/syndicate/speed
	copy_type = /datum/disease/advance

/datum/disease/advance/syndicate/speed/New()
	name = "Syndicate Fast-Acting Virus Gene"
	symptoms = list(new/datum/symptom/syndicatebuffspeed)
	..()

/datum/disease/advance/syndicate/trans
	copy_type = /datum/disease/advance

/datum/disease/advance/syndicate/trans/New()
	name = "Syndicate Transmissable Virus Gene"
	symptoms = list(new/datum/symptom/syndicatebufftrans)
	..()


/datum/disease/advance/supersyndicate
	copy_type = /datum/disease/advance

/datum/disease/advance/supersyndicate/New()
	name = "S. Augmented Virus"
	symptoms = list(new/datum/symptom/supersyndicatebuff,
					new/datum/symptom/inorganic_adaptation,
					new/datum/symptom/heal/darkness,
					new/datum/symptom/heal/water,
					new/datum/symptom/heal/starlight,
					new/datum/symptom/heal/plasma,
					new/datum/symptom/heal/radiation,
					new/datum/symptom/oxygen)
	..()

//Randomly generated Disease, for virus crates and events
/datum/disease/advance/random
	name = "Experimental Disease"
	copy_type = /datum/disease/advance

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
