/*
//////////////////////////////////////
Inert Virus

	Noticable.
	No stat change

BONUS
	Nothing. Symptom disappears when other symptoms manifest

//////////////////////////////////////
*/

/datum/symptom/inert

	name = "Inert Virus"
	stealth = 1
	resistance = 0
	stage_speed = 0
	transmittable = 0
	level = 10 //so it's not on the random rotation
	severity = 1

/datum/symptom/inert/Activate(var/datum/disease/advance/A)
	..()
	return