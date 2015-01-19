/*
//////////////////////////////////////

Ocular Restoration

	Noticable.
	Lowers resistance significantly.
	Decreases stage speed moderately..
	Decreases transmittablity tremendously.
	High level.

Bonus
	Restores eyesight.

//////////////////////////////////////
*/

/datum/symptom/visionaid

	name = "Ocular Restoration"
	stealth = -1
	resistance = -3
	stage_speed = -2
	transmittable = -4
	level = 4

/datum/symptom/visionaid/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 5))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				if (M.reagents.get_reagent_amount("oculine") < 20)
					M.reagents.add_reagent("oculine", 20)
			else
				if(prob(SYMPTOM_ACTIVATION_PROB * 5))
					M << "<span class='notice'>[pick("Your eyes feel great.", "You are now blinking manually.", "You don't feel the need to blink.")]</span>"
	return
