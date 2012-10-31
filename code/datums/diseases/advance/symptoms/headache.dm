/*
//////////////////////////////////////

Headache

	Noticable.
	Highly resistant.
	Doesn't increase stage speed..
	Low Level.

BONUS
	Displays an annoying message!
	Should be used for buffing your disease.

//////////////////////////////////////
*/

/datum/symptom/cough

	stealth = -1
	resistance = 4
	stage_speed = 0
	level = 1

/datum/symptom/cough/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		M << "<span class='notice'>[pick("Your head hurts.", "Your head starts pounding.")]</span>"
	return