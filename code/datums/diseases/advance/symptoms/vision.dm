/*
//////////////////////////////////////

Hyphema (Eye bleeding)

	Slightly noticable.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity.
	Critical Level.

Bonus
	Causes blindness.

//////////////////////////////////////
*/

/datum/symptom/visionloss

	name = "Hyphema"
	stealth = -1
	resistance = -4
	stage_speed = -4
	transmittable = -3
	level = 5
	severity = 4

/datum/symptom/visionloss/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2)
				M << "<span class='warning'>Your eyes itch.</span>"
			if(3, 4)
				M << "<span class='warning'><b>Your eyes burn!</b></span>"
				M.blur_eyes(10)
				M.adjust_eye_damage(1)
			else
				M << "<span class='userdanger'>Your eyes burn horrificly!</span>"
				M.blur_eyes(20)
				M.adjust_eye_damage(5)
				if(M.eye_damage >= 10)
					M.become_nearsighted()
					if(prob(M.eye_damage - 10 + 1))
						if(M.become_blind())
							M << "<span class='userdanger'>You go blind!</span>"


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

/datum/symptom/visionaid/Activate(datum/disease/advance/A)
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
