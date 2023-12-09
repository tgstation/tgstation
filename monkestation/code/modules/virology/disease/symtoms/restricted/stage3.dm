/datum/symptom/bad_adrenaline
	name = "Bad Adrenaline"
	desc = "If left untreated the subject will suffer from lethargy, dizziness and periodic loss of conciousness."
	stage = 3
	restricted = TRUE
	max_multiplier = 2


/datum/symptom/bad_adrenaline/activate(mob/living/carbon/affected_mob)
	switch(round(multiplier))
		if(1)
			if(prob(2.5))
				to_chat(affected_mob, span_warning(pick("You feel lightheaded.", "You feel lethargic.")))
		if(2)
			if(prob(5))
				affected_mob.Unconscious(40)

			if(prob(10))
				affected_mob.adjust_slurring(14 SECONDS)

			if(prob(7))
				affected_mob.set_dizzy_if_lower(20 SECONDS)

			if(prob(2.5))
				to_chat(affected_mob, span_warning(pick("You feel pain shoot down your legs!", "You feel like you are going to pass out at any moment.", "You feel really dizzy.")))
