/*Self-Respiration
 * Slight increase to stealth
 * Greatly reduces resistance
 * Greatly reduces stage speed
 * Reduces transmission tremendously
 * Lethal level
 * Bonus: Gives the carrier TRAIT_NOBREATH, preventing suffocation and CPR
*/
/datum/symptom/oxygen
	name = "Self-Respiration"
	desc = "The virus rapidly synthesizes oxygen, effectively removing the need for breathing."
	stealth = 1
	resistance = -3
	stage_speed = -3
	transmittable = -4
	level = 6
	base_message_chance = 3
	symptom_delay_min = 1
	symptom_delay_max = 1
	required_organ = ORGAN_SLOT_LUNGS
	threshold_descs = list(
		"Resistance 8" = "Additionally regenerates lost blood."
	)
	var/regenerate_blood = FALSE

/datum/symptom/oxygen/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalResistance() >= 8) //blood regeneration
		regenerate_blood = TRUE

/datum/symptom/oxygen/Activate(datum/disease/advance/advanced_disease)
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/infected_mob = advanced_disease.affected_mob
	switch(advanced_disease.stage)
		if(4, 5)
			infected_mob.losebreath = max(0, infected_mob.losebreath - 4)
			infected_mob.adjustOxyLoss(-7)
			if(prob(base_message_chance))
				to_chat(infected_mob, span_notice("You realize you haven't been breathing."))
			if(regenerate_blood && infected_mob.blood_volume < BLOOD_VOLUME_NORMAL)
				infected_mob.blood_volume += 1
		else
			if(prob(base_message_chance))
				to_chat(infected_mob, span_notice("Your lungs feel great."))
	return

/datum/symptom/oxygen/on_stage_change(datum/disease/advance/advanced_disease)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/infected_mob = advanced_disease.affected_mob
	if(advanced_disease.stage >= 4)
		ADD_TRAIT(infected_mob, TRAIT_NOBREATH, DISEASE_TRAIT)
		if(advanced_disease.stage == 4)
			to_chat(infected_mob, span_notice("You don't feel the need to breathe anymore."))
	else
		REMOVE_TRAIT(infected_mob, TRAIT_NOBREATH, DISEASE_TRAIT)
		if(advanced_disease.stage_peaked && advanced_disease.stage == 3)
			to_chat(infected_mob, span_notice("You feel the need to breathe again."))
	return TRUE

/datum/symptom/oxygen/End(datum/disease/advance/advanced_disease)
	. = ..()
	if(!.)
		return
	REMOVE_TRAIT(advanced_disease.affected_mob, TRAIT_NOBREATH, DISEASE_TRAIT)
