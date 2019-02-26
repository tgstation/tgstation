/datum/brain_trauma/special/unstable_insanity
	name = "Deranged"
	desc = "Patient's mind has collapsed, and they are now experiencing hallucinations"
	scan_desc = "deranged delusions"
	gain_text = "<span class='warning'>There's a buzzing in your head, and you feel watched...</span>"
	lose_text = "<span class='notice'>Your mind finally feels calm again.</span>"
	can_gain = TRUE
	random_gain = FALSE
	resilience = TRAUMA_RESILIENCE_ABSOLUTE

/datum/brain_trauma/special/unstable_insanity/on_life()
	if(prob(1))
		switch(rand(1,3))
			if(1)//eyeballs
				//
			if(2)//talking
