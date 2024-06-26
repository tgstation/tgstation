/datum/symptom/actionspd
	name = "Muscular Dexterity"
	desc = "The virus stimulates and compresses the muscules within the host, speeding up 'progress bar' actions by 5%."
	stealth = -2
	resistance = 0
	stage_speed = 0
	transmittable = 0
	level = 11
	symptom_delay_min = 1
	symptom_delay_max = 1
	threshold_descs = list(
		"Resistance 7" = "All progress bar actions are sped up by an additional 5%.",
		"Stage Speed 2" = "Carrying bodies is faster.",
		"Stage Speed 4" = "Surgery is faster.",
		"Stage Speed 6" = "Construction is faster.",
		"Stage Speed 10" = "Shooting guns is faster.",
	)
	var/buffed = FALSE
	var/bodycarryspd = FALSE
	var/surgeryspd = FALSE
	var/constructspd = FALSE
	var/gunspd = FALSE

/datum/symptom/actionspd/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalResistance() >= 7)
		buffed = TRUE
	if(A.totalStageSpeed() >= 2)
		bodycarryspd = TRUE
	if(A.totalStageSpeed() >= 4)
		surgeryspd = TRUE
	if(A.totalStageSpeed() >= 6)
		constructspd = TRUE
	if(A.totalStageSpeed() >= 10)
		gunspd = TRUE

/datum/symptom/actionspd/on_stage_change(datum/disease/advance/A)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/M = A.affected_mob
	if(A.stage >= 4)
		if(buffed)
			M.add_actionspeed_modifier(/datum/actionspeed_modifier/diseasestimbuffed)
		else
			M.add_actionspeed_modifier(/datum/actionspeed_modifier/diseasestim)

		if(bodycarryspd)
			ADD_TRAIT(M, TRAIT_QUICKER_CARRY, DISEASE_TRAIT)
		if(surgeryspd)
			ADD_TRAIT(M, TRAIT_FASTMED, DISEASE_TRAIT)
		if(constructspd)
			ADD_TRAIT(M, TRAIT_QUICK_BUILD, DISEASE_TRAIT)
		if(gunspd)
			ADD_TRAIT(M, TRAIT_DOUBLE_TAP, DISEASE_TRAIT)
	else
		M.remove_actionspeed_modifier(/datum/actionspeed_modifier/diseasestimbuffed)
		M.remove_actionspeed_modifier(/datum/actionspeed_modifier/diseasestim)

		REMOVE_TRAIT(M, TRAIT_QUICKER_CARRY, DISEASE_TRAIT)
		REMOVE_TRAIT(M, TRAIT_FASTMED, DISEASE_TRAIT)
		REMOVE_TRAIT(M, TRAIT_QUICK_BUILD, DISEASE_TRAIT)
		REMOVE_TRAIT(M, TRAIT_DOUBLE_TAP, DISEASE_TRAIT)
	return TRUE

/datum/symptom/actionspd/End(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	A.affected_mob.remove_actionspeed_modifier(/datum/actionspeed_modifier/diseasestimbuffed)
	A.affected_mob.remove_actionspeed_modifier(/datum/actionspeed_modifier/diseasestim)

	REMOVE_TRAIT(A.affected_mob, TRAIT_QUICKER_CARRY, DISEASE_TRAIT)
	REMOVE_TRAIT(A.affected_mob, TRAIT_FASTMED, DISEASE_TRAIT)
	REMOVE_TRAIT(A.affected_mob, TRAIT_QUICK_BUILD, DISEASE_TRAIT)
	REMOVE_TRAIT(A.affected_mob, TRAIT_DOUBLE_TAP, DISEASE_TRAIT)
