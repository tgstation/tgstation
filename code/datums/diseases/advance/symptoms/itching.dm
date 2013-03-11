/*
//////////////////////////////////////

Itching

	Not noticable or unnoticable.
	Resistant.
	Increases stage speed.
	Little transmittable.
	Low Level.

BONUS
	Displays an annoying message!
	Should be used for buffing your disease.

//////////////////////////////////////
*/

/datum/symptom/itching

	name = "Itching"
	stealth = 0
	resistance = 3
	stage_speed = 3
	transmittable = 1
	level = 1

/datum/symptom/itching/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		M << "<span class='notice'>Your [pick("back", "arm", "leg", "elbow", "head")] itches.</span>"
	return