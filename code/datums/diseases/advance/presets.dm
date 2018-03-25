// Cold

/datum/disease/advance/cold/New()
	name = "Cold"
	symptoms = list(new/datum/symptom/sneeze)
	..()


// Flu

/datum/disease/advance/flu/New()
	name = "Flu"
	symptoms = list(new/datum/symptom/cough)
	..()


// Voice Changing

/datum/disease/advance/voice_change/New()
	name = "Epiglottis Mutation"
	symptoms = list(new/datum/symptom/voice_change)
	..()


// Toxin Filter

/datum/disease/advance/heal/New()
	name = "Liver Enhancer"
	symptoms = list(new/datum/symptom/heal)
	..()


// Hallucigen

/datum/disease/advance/hallucigen/New()
	name = "Second Sight"
	symptoms = list(new/datum/symptom/hallucigen)
	..()

// Sensory Restoration

/datum/disease/advance/mind_restoration/New()
	name = "Intelligence Booster"
	symptoms = list(new/datum/symptom/mind_restoration)
	..()

// Sensory Destruction

/datum/disease/advance/narcolepsy/New()
	name = "Experimental Insomnia Cure"
	symptoms = list(new/datum/symptom/narcolepsy)
	..()