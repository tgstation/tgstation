/*
//////////////////////////////////////

Deafness

	Slightly noticable.
	Lowers resistance.
	Decreases stage speed slightly.
	Decreases transmittablity.
	Intense Level.

Bonus
	Causes intermittent loss of hearing.

//////////////////////////////////////
*/

/datum/symptom/deafness

	name = "Deafness"
	stealth = -1
	resistance = -2
	stage_speed = -1
	transmittable = -3
	level = 4

/datum/symptom/deafness/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB / 2))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(3, 4)
				M << "<span class='notice'>[pick("You hear a ringing in your ear.", "Your ears pop.")]</span>"
			if(5)
				M << "<span class='danger'>Your ears pop and begin ringing loudly!</span>"
				M.sdisabilities |= DEAF
				spawn(300)	M.sdisabilities &= ~DEAF
//				if(istype(M, /mob/living/carbon/human))
//					var/mob/living/carbon/human/H = M
//					H.silent += 15
	return