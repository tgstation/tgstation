/*
//////////////////////////////////////

Weakness

	Slightly noticeable.
	Lowers resistance slightly.
	Decreases stage speed moderately.
	Decreases transmittablity moderately.
	Moderate Level.

Bonus
	Deals stamina damage to the host

//////////////////////////////////////
*/

/datum/symptom/weakness

	name = "Weakness"
	stealth = -1
	resistance = -1
	stage_speed = -2
	transmittable = -2
	level = 3
	severity = 3

/datum/symptom/weakness/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2)
				to_chat(M, "<span class='warning'>[pick("You feel weak.", "You feel lazy.")]</span>")
			if(3, 4)
				to_chat(M, "<span class='warning'><b>[pick("You feel very frail.", "You think you might faint.")]</span>")
				M.adjustStaminaLoss(15)
			else
				to_chat(M, "<span class='userdanger'>[pick("You feel tremendously weak!", "Your body trembles as exhaustion creeps over you.")]</span>")
				M.adjustStaminaLoss(30)
				if(M.getStaminaLoss() > 60 && !M.stat)
					M.visible_message("<span class='warning'>[M] faints!</span>", "<span class='userdanger'>You swoon and faint...</span>")
					M.AdjustSleeping(100)
	return
