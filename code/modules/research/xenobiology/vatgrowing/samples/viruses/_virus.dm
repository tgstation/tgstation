///A micro_organism that supports the ability to be converted to a real virus, allowing virology to get new symptoms
/datum/micro_organism/virus
	desc = "A virus of unknown origin"
	///The symptom we actually possess
	var/datum/symptom/symptom

///Set a basic symptom on the virus
/datum/micro_organism/virus/New()
	. = ..()
	symptom = pick(/datum/symptom/cough,/datum/symptom/itching, /datum/symptom/fever)
