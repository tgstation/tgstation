/*
//////////////////////////////////////

Fever

	No change to hidden.
	Increases resistance.
	Increases stage speed.
	Little transmittable.
	Low level.

Bonus
	Heats up your body.

//////////////////////////////////////
*/

/datum/symptom/fever

	name = "Fever"
	stealth = 0
	resistance = 3
	stage_speed = 3
	transmittable = 2
	level = 2
	severity = 2

/datum/symptom/fever/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/M = A.affected_mob
		to_chat(M, "<span class='warning'>[pick("You feel hot.", "You feel like you're burning.")]</span>")
		if(M.bodytemperature < BODYTEMP_HEAT_DAMAGE_LIMIT)
			Heat(M, A)

	return

/datum/symptom/fever/proc/Heat(mob/living/M, datum/disease/advance/A)
	var/get_heat = (sqrt(max(21,21+A.totalTransmittable()*2)))+(sqrt(max(21,20+A.totalStageSpeed()*3)))
	M.bodytemperature = min(M.bodytemperature + (get_heat * A.stage), BODYTEMP_HEAT_DAMAGE_LIMIT - 1)
	return 1
