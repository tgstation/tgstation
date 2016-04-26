/datum/medical_effect/flatline
	name = "Cardiac Arrest"
	description = "The patient's heart has stopped."
	reccomended_treatment = "Electric Shock"
	max_stage = 1


/datum/medical_effect/flatline/process(var/mob/living/carbon/M)
	..()
	M.adjustBrainLoss(3)
	M.Weaken(5)
	M.losebreath += 20
	M.adjustOxyLoss(20)

/datum/medical_effect/heartfailure
	name = "Cardiac Failure"
	description = "The patient is having a cardiac emergency."
	reccomended_treatment = "Atropine or Epinephrine."
	max_stage = 3
	stage_advance_tick = 1
	stage_advance_prob = 5


/datum/medical_effect/heartfailure/process(var/mob/living/carbon/M)
	..()
	switch(stage)
		if (1)
			if (prob(1) && prob(10))
				M << "You feel better."
				M.remove_medical_effect(/datum/medical_effect/heartfailure)
				return
			if (prob(8))
				M.emote(pick("pale", "shudder"))
			if (prob(5))
				M << "<span class = 'danger'>Your arm hurts!</span>"
			else if (prob(5))
				M << "<span class = 'danger'>Your chest hurts!</span>"
		if (2)
			if (prob(1) && prob(10))
				M << "You feel better."
				M.remove_medical_effect(/datum/medical_effect/heartfailure)
				return
			if (prob(8))
				M.emote(pick("pale", "groan"))
			if (prob(5))
				M << "<span class = 'danger'>Your heart lurches in your chest!</span>"
				M.losebreath++
			if (prob(3))
				M << "<span class = 'danger'>Your heart stops beating!</span>"
				M.losebreath += 3
			if (prob(5))
				M.emote(pick("faint", "collapse", "groan"))
		if (3)
			M.adjustOxyLoss(1)
			if (prob(8))
				M.emote(pick("twitch", "gasp"))
			if (prob(5))
				if(!M.has_medical_effect(/datum/medical_effect/flatline))
					M.add_medical_effect(/datum/medical_effect/flatline, 1)

/datum/medical_effect/shock
	name = "Shock"
	description = "The patient is in shock."
	reccomended_treatment = "Saline Solution"
	max_stage = 3
	stage_advance_tick = 1
	stage_advance_prob = 6

/datum/medical_effect/shock/process(var/mob/living/carbon/M)
	..()
	if(M.health >= 25)
		M << "<span class = 'notice'>You feel better.</span>"
		M.remove_medical_effect(/datum/medical_effect/shock)
		return
	switch(stage)
		if(1)
			if(prob(1) && prob(10))
				M << "<span class = 'notice'>You feel better.</span>"
				M.remove_medical_effect(/datum/medical_effect/shock)
				return
			if(prob(8))
				M.emote(pick("shiver", "pale", "moan"))
			if(prob(5))
				M << "<span class = 'danger'>You feel weak!</span>"
		if(2)
			if(prob(1) && prob(10))
				M << "<span class = 'notice'>You feel better.</span>"
				M.remove_medical_effect(/datum/medical_effect/shock)
				return
			if(prob(8))
				M.emote(pick("shiver", "pale", "moan", "shudder", "tremble"))
			if(prob(5))
				M << "<span class = 'danger'>You feel absolutely terrible!</span>"
			if(prob(5))
				M.emote("faint", "collapse", "groan")
		if(3)
			if(prob(1) && prob(10))
				M << "<span class = 'notice'>You feel better.</span>"
				M.remove_medical_effect(/datum/medical_effect/shock)
				return
			if(prob(8))
				M.emote(pick("shudder", "pale", "tremble", "groan", "shake"))
			if(prob(5))
				M << "<span class = 'danger'>You feel horrible!</span>"
			if(prob(5))
				M.emote(pick("faint", "collapse", "groan"))
			if(prob(7))
				M << "<span class = 'danger'>You can't breathe!</span>"
				M.losebreath++
			if(prob(5))
				if(!M.has_medical_effect(/datum/medical_effect/heartfailure))
					M.add_medical_effect(/datum/medical_effect/heartfailure, 1)