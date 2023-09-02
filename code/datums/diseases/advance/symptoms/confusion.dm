/**Confusion
 * Slightly increases stealth
 * Slightly lowers resistance
 * Decreases stage speed
 * No effect to transmissibility
 * Intense level
 * Bonus: Makes the affected mob be confused for short periods of time.
 */
/datum/symptom/confusion
	name = "Confusion"
	desc = "The virus interferes with the proper function of the neural system, leading to bouts of confusion and erratic movement."
	illness = "Shattered Reality"
	stealth = 1
	resistance = -1
	stage_speed = -3
	transmittable = 0
	level = 4
	severity = 2
	base_message_chance = 25
	symptom_delay_min = 10
	symptom_delay_max = 30
	threshold_descs = list(
		"Resistance 6" = "Causes brain damage over time.",
		"Transmission 6" = "Increases confusion duration and strength.",
		"Stealth 4" = "The symptom remains hidden until active.",
	)
	var/brain_damage = FALSE
	var/causes_illiteracy = FALSE

/datum/symptom/confusion/Start(datum/disease/advance/advanced_disease)
	. = ..()
	if(!.)
		return
	if(advanced_disease.totalStageSpeed() >= 6)
		causes_illiteracy = TRUE
	if(advanced_disease.totalResistance() >= 6)
		brain_damage = TRUE
	if(advanced_disease.totalTransmittable() >= 6)
		power = 1.5
	if(advanced_disease.totalStealth() >= 4)
		suppress_warning = TRUE

/datum/symptom/confusion/End(datum/disease/advance/advanced_disease)
	advanced_disease.affected_mob.remove_status_effect(/datum/status_effect/confusion)
	return ..()

/datum/symptom/confusion/Activate(datum/disease/advance/advanced_disease)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/infected_mob = advanced_disease.affected_mob
	switch(advanced_disease.stage)
		if(1, 2, 3, 4)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(infected_mob, span_warning("[pick("Your head hurts.", "Your mind blanks for a moment.")]"))
		else
			to_chat(infected_mob, span_userdanger("You can't think straight!"))
			infected_mob.adjust_confusion_up_to(16 SECONDS * power, 30 SECONDS)
			if(brain_damage)
				infected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3 * power, 80)
				infected_mob.updatehealth()
	return
