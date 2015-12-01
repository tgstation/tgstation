//Refer to life.dm for caller

/mob/living/carbon/human/handle_shock()
	..()
	if(status_flags & GODMODE)
		return 0 //Godmode
	if(analgesic || (species && species.flags & NO_PAIN))
		return //Analgesic avoids all traumatic shock temporarily

	if(health < config.health_threshold_softcrit) //Going under the crit threshold makes you immediately collapse
		shock_stage = max(shock_stage, 61)

	if(traumatic_shock >= 80)
		shock_stage += 1
	else if(health < config.health_threshold_softcrit)
		shock_stage = max(shock_stage, 61)
	else
		shock_stage = min(shock_stage, 160)
		shock_stage = max(shock_stage - 1, 0)
		return

	if(shock_stage == 10)
		to_chat(src, "<span class='danger'>[pick("It hurts so much!", "You really need some painkillers..", "Dear god, the pain!")]</span>")

	if(shock_stage >= 30)
		if(shock_stage == 30)
			emote("me", 1, "is having trouble keeping their eyes open.")
		eye_blurry = max(2, eye_blurry)
		stuttering = max(stuttering, 5)

	if(shock_stage == 40)
		to_chat(src, "<span class='danger'>[pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!")]</span>")

	if(shock_stage >= 60)
		if(shock_stage == 60)
			emote("me",1,"'s body becomes limp.")
		if(prob(2))
			to_chat(src, "<span class='danger'>[pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!")]</span>")
			Weaken(20)

	if(shock_stage >= 80)
		if(prob(5))
			to_chat(src, "<span class='danger'>[pick("The pain is excrutiating!", "Please, just end the pain!", "Your whole body is going numb!")]</span>")
			Weaken(20)

	if(shock_stage >= 120)
		if(prob(2))
			to_chat(src, "<span class='danger'>[pick("You black out!", "You feel like you could die any moment now.", "You're about to lose consciousness.")]</span>")
			Paralyse(5)

	if(shock_stage == 150)
		emote("me", 1, "can no longer stand, collapsing!")
		Weaken(20)

	if(shock_stage >= 150)
		Weaken(20)
