/mob/living/carbon/human/AltUnarmedAttack(atom/A, proximity)
	if(!has_active_hand())
		to_chat(src, "<span class='notice'>You look at the state of the universe and sigh.</span>") //lets face it, people rarely ever see this message in its intended condition.
		return TRUE

	if(!A.alt_attack_hand(src))
		A.attack_hand(src)
		return TRUE
	return TRUE

/mob/living/carbon/human/AltRangedAttack(atom/A, params)
	if(!has_active_hand())
		to_chat(src, "<span class='notice'>You ponder your life choices and sigh.</span>")
		return TRUE

	if(!incapacitated())
		switch(a_intent)
			if(INTENT_HELP)
				visible_message("<span class='notice'>[src] waves to [A].</span>", "<span class='notice'>You wave to [A].</span>")
			if(INTENT_DISARM)
				visible_message("<span class='notice'>[src] shoos away [A].</span>", "<span class='notice'>You shoo away [A].</span>")
			if(INTENT_GRAB)
				visible_message("<span class='notice'>[src] beckons [A] to come.</span>", "<span class='notice'>You beckon [A] to come.</span>") //This sounds lewder than it actually is. Fuck.
			if(INTENT_HARM)
				visible_message("<span class='notice'>[src] shakes [p_their()] fist at [A].</span>", "<span class='notice'>You shake your fist at [A].</span>")
		return TRUE

/atom/proc/alt_attack_hand(mob/user)
	return FALSE
