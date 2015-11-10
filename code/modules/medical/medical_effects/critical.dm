/datum/medical_effect/shock
	name = "Shock"
	description = "Randomly passing out, odd behavior. Usually a result of blood loss or critical condition."
	reccomended_treatment = "Saline-Glucose Solution, replacing lost blood"
	stage_advance_tick = 10
	stage_advance_prob = 50

/datum/medical_effect/shock/process(var/mob/living/carbon/human/H)
	..()
	switch(stage)
		if(1)
			if(prob(25))
				H.emote(pick("gasp","cry","quiver","moan"))
			if(prob(25))
				H.Paralyse(rand(1,3))
				H << "You pass out!"
				return
		if(2)
			if(prob(rand(25,50)))
				H.emote(pick("gasp","cry","quiver","moan"))
			if(prob(rand(25,50)))
				H.Paralyse(rand(3,5))
				H << "You pass out!"
				return
		if(3)
			if(prob(rand(25,75)))
				H.emote(pick("gasp","cry","quiver","moan"))
			if(prob(rand(25,75)))
				H.Paralyse(rand(3,5))
				H << "You pass out!"
			if(prob(25))
				for(var/datum/medical_effect/E in H.medical_effects)
					if(istype(E, /datum/medical_effect/cardiac_failure))
						return
				H.add_medical_effect(/datum/medical_effect/cardiac_failure, 1)

/datum/medical_effect/cardiac_failure
	name = "Cardiac Failure"
	description = "Not enough oxygen is being pumped to the body, causing oxygen damage and other side effects."
	reccomended_treatment = "Atropine and Epinephrine, CPR (low success chance)"
	stage_advance_tick = 20
	stage_advance_prob = 45

/datum/medical_effect/cardiac_failure/process(var/mob/living/carbon/human/H)
	..()
	switch(stage)
		if(1)
			H.adjustOxyLoss(2)
			return
		if(2)
			H.adjustOxyLoss(3)
			M.dizziness++
			M.drowsyness++
			M.stuttering++
			M.slurring++
			return
		if(3)
			H.adjustOxyLoss(4)
			M.dizziness += 2
			M.drowsyness += 2
			M.stuttering += 2
			M.slurring += 2
			if(prob(25))
				for(var/datum/medical_effect/E in H.medical_effects)
					if(istype(E, /datum/medical_effect/cardiac_arrest))
						return
				H.add_medical_effect(/datum/medical_effect/cardiac_arrest, 1)

/datum/medical_effect/cardiac_arrest
	name = "Cardiac Arrest"
	description = "The heart has completely stopped beating. Immediate treatment is needed, otherwise the patient will die of "
	reccomended_treatment = "Defibrilator and strong electric shocks."
	max_stage = 1

/datum/medical_effect/cardiac_failure/process(var/mob/living/carbon/human/H)
	..()
	H.Paralyse(5)
	H.losebreath += 5
	H.adjustBrainLoss(rand(1,5))
	H.adjustOxyLoss(20)