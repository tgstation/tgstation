/*
//////////////////////////////////////

Radioactive Metabolism

	Noticeable.
	Lowers resistance.
	Increases stage speed.
	No change to transmittability.
	Fatal Level.

Bonus
	Emits radioactive pulses.

//////////////////////////////////////
*/

/datum/symptom/radioactive

	name = "Radioactive Metabolism"
	stealth = -1
	resistance = -2
	stage_speed = 2
	transmittable = -4
	level = 7
	severity = 6

/datum/symptom/radioactive/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(2,3)
				M << "<span class='warning'>[pick("You feel nauseous.", "Your skin glows eerily.")]</span>"
			if(4,5)
				M << "<span class='userdanger'>[pick("A flash of light outlines your bones.", "You feel a strong heat irradiate from inside you.")]</span>"
				Radpulse(M, A)
	return

/datum/symptom/radioactive/proc/Radpulse(mob/living/M, datum/disease/advance/A)
	var/get_rad = ((sqrt(20+A.totalStageSpeed()))*10)
	radiation_pulse(get_turf(src), 1, 4, get_rad, 0)
	return 1