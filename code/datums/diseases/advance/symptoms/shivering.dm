/*
//////////////////////////////////////

Shivering

	No change to hidden.
	Increases resistance.
	Increases stage speed.
	Little transmittable.
	Low level.

Bonus
	Cools down your body.

//////////////////////////////////////
*/

/datum/symptom/shivering

	name = "Shivering"
	stealth = 0
	resistance = 2
	stage_speed = 2
	transmittable = 2
	level = 2

/datum/symptom/shivering/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/M = A.affected_mob
		to_chat(M, "<span class='notice'>[pick("You feel cold.", "You start shaking from the cold.")]</span>")
		if(M.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT)
			M.bodytemperature = min(M.bodytemperature - (20 * A.stage), BODYTEMP_COLD_DAMAGE_LIMIT + 1)

	return
