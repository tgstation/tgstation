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

/datum/symptom/visionloss/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2)
				M << "<span class='notice'>Your eyes itch.</span>"
			if(3, 4)
				M << "<span class='notice'>Your eyes ache.</span>"
				M.eye_blurry = 10
				M.eye_stat += 1
			else
				M << "<span class='danger'>Your eyes burn horrificly!</span>"
				M.eye_blurry = 20
				M.eye_stat += 5
				if (M.eye_stat >= 10)
					M.disabilities |= NEARSIGHT
					if (prob(M.eye_stat - 10 + 1) && !(M.eye_blind))
						M << "<span class='danger'>You go blind!</span>"
						M.disabilities |= BLIND
						M.eye_blind = 1
	return


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
