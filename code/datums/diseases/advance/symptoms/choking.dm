/**Choking
 * Very very noticable.
 * Lowers resistance
 * Decreases stage speed
 * Greatly decreases transmissibility
 * Moderate Level.
 * Bonus: Inflicts spikes of oxyloss
 */

/datum/symptom/choking
	name = "Choking"
	desc = "The virus causes inflammation of the host's air conduits, leading to intermittent choking."
	illness = "Pneumatic Tubes"
	stealth = -3
	resistance = -2
	stage_speed = -2
	transmittable = -2
	level = 3
	severity = 3
	base_message_chance = 15
	symptom_delay_min = 10
	symptom_delay_max = 30
	required_organ = ORGAN_SLOT_LUNGS
	threshold_descs = list(
		"Stage Speed 8" = "Causes choking more frequently.",
		"Stealth 4" = "The symptom remains hidden until active."
	)

/datum/symptom/choking/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStageSpeed() >= 8)
		symptom_delay_min = 7
		symptom_delay_max = 24
	if(A.totalStealth() >= 4)
		suppress_warning = TRUE

/datum/symptom/choking/Activate(datum/disease/advance/advanced_disease)
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/infected_mob = advanced_disease.affected_mob

	switch(advanced_disease.stage)
		if(1, 2)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(infected_mob, span_warning("[pick("You're having difficulty breathing.", "Your breathing becomes heavy.")]"))
		if(3, 4)
			if(!suppress_warning)
				to_chat(infected_mob, span_warning("[pick("Your windpipe feels like a straw.", "Your breathing becomes tremendously difficult.")]"))
			else
				to_chat(infected_mob, span_warning("You feel very [pick("dizzy","woozy","faint")].")) //fake bloodloss messages
			Choke_stage_3_4(infected_mob, advanced_disease)
			infected_mob.emote("gasp")
		else
			to_chat(infected_mob, span_userdanger("[pick("You're choking!", "You can't breathe!")]"))
			Choke(infected_mob, advanced_disease)
			infected_mob.emote("gasp")

/datum/symptom/choking/proc/Choke_stage_3_4(mob/living/M, datum/disease/advance/A)
	M.adjustOxyLoss(rand(6,13))
	return 1

/datum/symptom/choking/proc/Choke(mob/living/M, datum/disease/advance/A)
	M.adjustOxyLoss(rand(10,18))
	return 1
