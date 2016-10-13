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
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(4, 5) //basically oculine
			if(M.disabilities & BLIND)
				if(prob(20))
					M << "<span class='warning'>Your vision slowly returns...</span>"
					M.cure_blind()
					M.cure_nearsighted()
					M.blur_eyes(35)

				else if(M.disabilities & NEARSIGHT)
					M << "<span class='warning'>The blackness in your peripheral vision fades.</span>"
					M.cure_nearsighted()
					M.blur_eyes(10)

				else if(M.eye_blind || M.eye_blurry)
					M.set_blindness(0)
					M.set_blurriness(0)
				else if(M.eye_damage > 0)
					M.adjust_eye_damage(-1)
		else
			if(prob(SYMPTOM_ACTIVATION_PROB * 3))
				M << "<span class='notice'>[pick("Your eyes feel great.", "You are now blinking manually.", "You don't feel the need to blink.")]</span>"
	return
