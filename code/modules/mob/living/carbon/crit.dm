/mob/living/carbon/handle_crit()

	/////////////////////////////////////////////
	//// cogwerks - critical health rewrite /////
	/////////////////////////////////////////////
	//// goal: make crit a medical emergency ////
	//// instead of game over black screen time /
	/////////////////////////////////////////////
	if(getBrainLoss() >= 100 && health < 0)
		Weaken(1)
		losebreath++
		return

	if(getBrainLoss() >= 120) // braindeath, the real killer
		visible_message("<span class = 'danger'>[src]'s expression becomes completely blank, a lifeless look in their eyes.</span>")
		death()
		return

	if (health < 0)
		if (prob(5))
			emote(pick("faint", "collapse", "cry","moan","gasp","shudder","shiver"))
		if (stuttering <= 5)
			stuttering += 5
		if (eye_blurry <= 5)
			blur_eyes(5)
		if (prob(7))
			confused += 2
		if (prob(5))
			Paralyse(2)
		switch(health)
			if (-INFINITY to -100)
				adjustOxyLoss(1)
				if (prob(health * -0.1))
					if(!has_medical_effect(/datum/medical_effect/flatline))
						add_medical_effect(/datum/medical_effect/flatline, 1)
				if (prob(health * -0.2))
					if(!has_medical_effect(/datum/medical_effect/heartfailure))
						add_medical_effect(/datum/medical_effect/heartfailure, 1)
			if (-99 to -80)
				adjustOxyLoss(1)
				if (prob(4))
					src << "<span class = 'danger'><b>Your chest hurts...</b></span>"
					Paralyse(1)
					if(!has_medical_effect(/datum/medical_effect/heartfailure))
						add_medical_effect(/datum/medical_effect/heartfailure, 1)
			if (-79 to -51)
				if (prob(10))
					if(!has_medical_effect(/datum/medical_effect/shock))
						add_medical_effect(/datum/medical_effect/shock, 1)
				if (prob(health * -0.08))
					if(!has_medical_effect(/datum/medical_effect/heartfailure))
						add_medical_effect(/datum/medical_effect/heartfailure, 1)
					//boutput(world, "\b LOG: ADDED HEART FAILURE TO [src].")
				if (prob(6))
					src << "<span class = 'danger'><b>You feel [pick("horrible pain", "awful", "like shit", "absolutely awful", "like death", "like you are dying", "nothing", "warm", "sweaty", "tingly", "really, really bad", "horrible")]!</b></span>"
					Weaken(3)
				if (prob(3))
					Paralyse(1)
			if (-50 to 0)
				adjustOxyLoss(1)
				if (prob(3))
					if(!has_medical_effect(/datum/medical_effect/shock))
						add_medical_effect(/datum/medical_effect/shock, 1)
				if (prob(5))
					src << "<span class = 'danger'><b>You feel [pick("terrible", "awful", "like shit", "sick", "numb", "cold", "sweaty", "tingly", "horrible")]!</b></span>"
					Weaken(3)