/datum/symptom/nanite_boost
	name = "Nano-symbiosis"
	desc = "The virus reacts to nanites in the host's bloodstream by enhancing their replication cycle."
	stealth = 0
	resistance = 2
	stage_speed = 2
	transmittable = -1
	level = 7
	severity = 0
	symptom_delay_min = 1
	symptom_delay_max = 1
	threshold_descs = list(
		"Transmission 5" = "Increases the virus' growth rate while nanites are present.",
		"Stage Speed 7" = "Increases the replication boost.",
	)
	///Whether nanites will also help boost the disease.
	var/reverse_boost = FALSE

/datum/symptom/nanite_boost/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.properties["transmittable"] >= 5) //reverse boost
		reverse_boost = TRUE
	if(A.properties["stage_rate"] >= 7) //more nanites
		power = 2

/datum/symptom/nanite_boost/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/M = A.affected_mob
	SEND_SIGNAL(M, COMSIG_NANITE_ADJUST_VOLUME, 0.5 * power)
	if(reverse_boost && SEND_SIGNAL(M, COMSIG_HAS_NANITES))
		if(prob(A.stage_prob))
			A.stage = min(A.stage + 1,A.max_stages)

/datum/symptom/nanite_destroy
	name = "Silicolysis"
	desc = "The virus reacts to nanites in the host's bloodstream by attacking and consuming them."
	stealth = 0
	resistance = 4
	stage_speed = -1
	transmittable = 1
	level = 7
	severity = 0
	symptom_delay_min = 1
	symptom_delay_max = 1
	threshold_descs = list(
		"Stage Speed 5" = "Increases the virus' growth rate while nanites are present.",
		"Resistance 7" = "Severely increases the rate at which the nanites are destroyed.",
	)
	///Whether nanites will also help boost the disease.
	var/reverse_boost = FALSE

/datum/symptom/nanite_destroy/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.properties["stage_rate"] >= 5) //reverse boost
		reverse_boost = TRUE
	if(A.properties["resistance"] >= 7) //less nanites
		power = 3

/datum/symptom/nanite_destroy/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/M = A.affected_mob
	SEND_SIGNAL(M, COMSIG_NANITE_ADJUST_VOLUME, -0.4 * power)
	if(reverse_boost && SEND_SIGNAL(M, COMSIG_HAS_NANITES))
		if(prob(A.stage_prob))
			A.stage = min(A.stage + 1,A.max_stages)

/datum/disease_ability/symptom/medium/nano_boost
	symptoms = list(/datum/symptom/nanite_boost)

/datum/disease_ability/symptom/medium/nano_destroy
	symptoms = list(/datum/symptom/nanite_destroy)
