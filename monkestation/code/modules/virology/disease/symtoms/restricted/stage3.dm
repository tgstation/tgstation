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

/datum/symptom/mutation
	name = "DNA Degradation"
	desc = "Attacks the infected's DNA, causing it to break down."
	stage = 3
	badness = EFFECT_DANGER_DEADLY
	max_multiplier = 5
	restricted = TRUE

/datum/symptom/mutation/activate(mob/living/carbon/mob)
	switch(round(multiplier, 1))
		if(2)
			if(prob(1))
				mob.emote("itch")
			if(prob(1))
				mob.emote("yawn")
		if(3)
			if(prob(1))
				mob.emote("itch")
			if(prob(1))
				mob.emote("drool")
			if(prob(1.5))
				mob.adjustCloneLoss(1, FALSE)
			if(prob(1))
				to_chat(mob, span_danger("Your skin feels strange."))

		if(4)
			if(prob(1))
				mob.emote("itch")
			if(prob(1))
				mob.emote("drool")
			if(prob(2.5))
				mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1, 170)
				mob.adjustCloneLoss(2, FALSE)
			if(prob(7.5))
				mob.adjust_stutter(6 SECONDS)
		if(5)
			if(prob(1))
				mob.emote("itch")
			if(prob(1))
				mob.emote("drool")
			if(prob(2.5))
				to_chat(mob, span_danger("Your skin starts degrading!"))
			if(prob(5))
				mob.adjustCloneLoss(5, FALSE)
				mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 170)
