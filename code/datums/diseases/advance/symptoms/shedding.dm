/*
//////////////////////////////////////
Excessive Shedding

	Noticable.
	Decreases resistance slightly.
	Reduces stage speed slightly.
	Transmittable.
	Intense Level.

BONUS
	Makes the mob bald.

//////////////////////////////////////
*/

/datum/symptom/shedding

	name = "Excessive Shedding"
	stealth = -1
	resistance = -1
	stage_speed = -1
	transmittable = 2
	level = 4

/datum/symptom/shedding/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3, 4)
				M << "<span class='notice'>[pick("You notice you're covered in dandruff.", "Your skin feels flakey.")]</span>"
			else
				if(istype(M, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = M
					if(!(H.f_style == "Shaved") || !(H.h_style == "Bald"))
						H << "<span class='notice'>Your hair starts to fall out in clumps...</span>"
						spawn(50)
							H.f_style = "Shaved"
							H.h_style = "Bald"
							H.update_hair()
				else
					M << "<span class='notice'>[pick("You notice you're covered in dandruff.", "Your skin feels flakey.")]</span>"
	return