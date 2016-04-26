/datum/medical_effect
	var/name = "Medical Emergency"
	var/description = "Brief summary of effect"
	var/reccomended_treatment = "Treatment method"
	var/stage = 1
	var/current_tick = 0
	var/stage_advance_tick = 10
	var/stage_advance_prob = 100
	var/max_stage = 3

/datum/medical_effect/proc/on_granting(var/mob/living/carbon/M)
	return

/datum/medical_effect/process(var/mob/living/carbon/M)
	current_tick++
	if(current_tick == stage_advance_tick && stage != max_stage)
		if(prob(stage_advance_prob))
			stage++
		current_tick = 0
	return

/datum/medical_effect/proc/on_losing(var/mob/living/carbon/M)
	return