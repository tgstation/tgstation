/datum/medical_effect/shock
	name = "Shock"
	description = "Randomly passing out, odd behavior. Usually a result of blood loss or critical condition."
	reccomended_treatment = "Saline-Glucose Solution, replacing lost blood"
	stage_advance_tick = 10
	stage_advance_prob = 35

/datum/medical_effect/shock/process(var/mob/living/carbon/human/H)
	..()
	switch(stage)
		if(1)
			if(prob(15))
				H.emote(pick("gasp","cry","quiver","moan"))
			if(prob(15))
				if(!H.paralysis)
					H.Paralyse(rand(1,3))
					H << "You pass out!"
					return
		if(2)
			if(prob(15))
				H.emote(pick("gasp","cry","quiver","moan"))
			if(prob(15))
				if(!H.paralysis)
					H.Paralyse(rand(1,3))
					H << "You pass out!"
					return
		if(3)
			if(prob(15))
				H.emote(pick("gasp","cry","quiver","moan"))
			if(prob(15))
				if(!H.paralysis)
					H.Paralyse(rand(1,3))
					H << "You pass out!"
					return
			if(prob(15))
				for(var/datum/medical_effect/E in H.medical_effects)
					if(istype(E, /datum/medical_effect/cardiac_failure))
						return
				H.add_medical_effect(/datum/medical_effect/cardiac_failure, 1)

/datum/medical_effect/cardiac_failure
	name = "Cardiac Failure"
	description = "Not enough oxygen is being pumped to the body, causing oxygen damage and other side effects."
	reccomended_treatment = "Atropine and Epinephrine, CPR (low success chance)"
	stage_advance_tick = 20
	stage_advance_prob = 20

/datum/medical_effect/cardiac_failure/process(var/mob/living/carbon/human/H)
	..()
	switch(stage)
		if(1)
			if(prob(15))
				H.emote(pick("shiver","pale","sway"))
			H.adjustOxyLoss(1)
			return
		if(2)
			if(prob(15))
				H.emote(pick("shiver","pale","sway"))
			H.adjustOxyLoss(2)
			H.dizziness++
			H.drowsyness++
			H.stuttering++
			H.slurring++
			return
		if(3)
			if(prob(15))
				H.emote(pick("shiver","pale","sway"))
			H.adjustOxyLoss(3)
			H.dizziness += 2
			H.drowsyness += 2
			H.stuttering += 2
			H.slurring += 2
			if(prob(25))
				for(var/datum/medical_effect/E in H.medical_effects)
					if(istype(E, /datum/medical_effect/cardiac_arrest))
						return
				H.add_medical_effect(/datum/medical_effect/cardiac_arrest, 1)

/datum/medical_effect/cardiac_arrest
	name = "Cardiac Arrest"
	description = "The heart has completely stopped beating. Immediate treatment is needed, otherwise the patient will die of no oxygenation."
	reccomended_treatment = "Defibrilator and strong electric shocks."
	max_stage = 1

/datum/medical_effect/cardiac_arrest/process(var/mob/living/carbon/human/H)
	..()
	H.Paralyse(5)
	H.losebreath += 5
	H.adjustBrainLoss(rand(1,5))
	H.adjustOxyLoss(20)