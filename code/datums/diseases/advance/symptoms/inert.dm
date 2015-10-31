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

	name = "Facial Hypertrichosis"
	stealth = 1
	resistance = 0
	stage_speed = 0
	transmittable = 0
	level = 10 //so it's not on the random rotation
	severity = 1

/datum/symptom/beard/Activate(var/datum/disease/advance/A)
	..()
	return