/*Anticoagulant
 * Increases stealth
 * No change to resistance
 * Reduces to stage speed
 * Reduces transmissibility
 * Fatal Level
 * Bonus: Worsens blood loss
*/

/datum/symptom/bleeding
	name = "Anticoagulant"
	desc = "The virus prevents the body from clotting blood. Unnoticable unless the host is bleeding."
	stealth = 1
	resistance = 0
	stage_speed = -2
	transmittable = -2
	severity = 3
	level = 7
	threshold_descs = list(
		"Stage Speed 9" = "The host becomes more vulnerable to bleeding wounds.",
		"Stealth 3" = "The symptom remains hidden even while active."
	)
	var/easybleed = FALSE
	var/hidden = FALSE

/datum/symptom/bleeding/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStageSpeed() >= 9)
		easybleed = TRUE
	if(A.totalStealth() >= 3)
		hidden = TRUE

/datum/symptom/bleeding/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/carbon_host = A.affected_mob
	for(var/datum/wound/possible_bleeding_wound as anything in carbon_host.all_wounds)
		if(possible_bleeding_wound.blood_flow && !hidden)
			if(4 > A.stage >= 2)
				to_chat(carbon_host, span_warning("Your bleeding wounds start to itch."))
			if(A.stage >= 4)
				to_chat(carbon_host, span_warning("Your bleeding wounds itch like crazy as more blood leaves your body."))
			return

/datum/symptom/bleeding/on_stage_change(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/carbon_host = A.affected_mob
	if(A.stage >= 4)
		ADD_TRAIT(carbon_host, TRAIT_BLOOD_FOUNTAIN, DISEASE_TRAIT)
		if(easybleed)
			ADD_TRAIT(carbon_host, TRAIT_EASYBLEED, DISEASE_TRAIT)
		return
	REMOVE_TRAIT(carbon_host, TRAIT_BLOOD_FOUNTAIN, DISEASE_TRAIT)
	REMOVE_TRAIT(carbon_host, TRAIT_EASYBLEED, DISEASE_TRAIT)


/datum/symptom/bleeding/End(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/carbon_host = A.affected_mob
	REMOVE_TRAIT(carbon_host, TRAIT_BLOOD_FOUNTAIN, DISEASE_TRAIT)
	REMOVE_TRAIT(carbon_host, TRAIT_EASYBLEED, DISEASE_TRAIT)
