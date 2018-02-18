//Refer to life.dm for caller

/mob/living/carbon/human/handle_shock()
	..()
	if(status_flags & GODMODE)
		return FALSE

	if(health < HEALTH_THRESHOLD_FULLCRIT) //Going under the crit threshold makes you immediately collapse
		pain_shock_stage = max(pain_shock_stage, 61)

	if(pain_level >= BASE_CARBON_PAIN_RESIST)
		pain_shock_stage += 1
	else if(health < HEALTH_THRESHOLD_FULLCRIT)
		pain_shock_stage = max(pain_shock_stage, 61)
	else
		pain_shock_stage = CLAMP(pain_shock_stage - 1, 0, 160)
		return

	if(pain_shock_stage == 10)
		to_chat(src, "<span class='danger'>[pick("It hurts so much!", "You really need some painkillers.", "Dear god, the pain!")]</span>")

	if(pain_shock_stage >= 30)
		if(pain_shock_stage == 30)
			if(!IsUnconscious())
				visible_message("<B>[src]</B> is having trouble keeping their eyes open.")
		eye_blurry = max(2, eye_blurry)
		stuttering = max(stuttering, 5)

	if(pain_shock_stage == 40)
		to_chat(src, "<span class='danger'>[pick("The pain is excruciating!", "Please, just end the pain!", "Your whole body is going numb!")]</span>")

	if(pain_shock_stage >= 60)
		if(pain_shock_stage == 60)
			if(!IsUnconscious())
				visible_message("<B>[src]</B>'s body becomes limp.")
		if(prob(2))
			to_chat(src, "<span class='danger'>[pick("The pain is excruciating!", "Please, just end the pain!", "Your whole body is going numb!")]</span>")
			Knockdown(20)

	if(pain_shock_stage >= 80)
		if(prob(5))
			to_chat(src, "<span class='danger'>[pick("The pain is excruciating!", "Please, just end the pain!", "Your whole body is going numb!")]</span>")
			Knockdown(20)

	if(pain_shock_stage >= 120)
		if(prob(2))
			to_chat(src, "<span class='danger'>[pick("You black out!", "You feel like you could die any moment now.", "You're about to lose consciousness.")]</span>")
			Stun(5)

	if(pain_shock_stage == 150)
		if(!IsUnconscious())
			visible_message("<B>[src]</b> can no longer stand, collapsing!")
		Knockdown(20)

	if(pain_shock_stage >= 150)
		Knockdown(20)