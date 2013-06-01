
/datum/artifact_effect/hurt
	effecttype = "hurt"
	effect_type = 5

/datum/artifact_effect/hurt/DoEffectTouch(var/mob/toucher)
	if(toucher)
		var/weakness = GetAnomalySusceptibility(toucher)
		if(iscarbon(toucher) && prob(weakness * 100))
			var/mob/living/carbon/C = toucher
			C << "\red A painful discharge of energy strikes you!"
			C.adjustOxyLoss(rand(5,25) * weakness)
			C.adjustToxLoss(rand(5,25) * weakness)
			C.adjustBruteLoss(rand(5,25) * weakness)
			C.adjustFireLoss(rand(5,25) * weakness)
			C.adjustBrainLoss(rand(5,25) * weakness)
			C.radiation += 25 * weakness
			C.nutrition -= min(50 * weakness, C.nutrition)
			C.make_dizzy(6 * weakness)
			C.weakened += 6 * weakness

/datum/artifact_effect/hurt/DoEffectAura()
	if(holder)
		for (var/mob/living/carbon/C in range(src.effectrange,holder))
			var/weakness = GetAnomalySusceptibility(C)
			if(prob(weakness * 100))
				if(prob(10))
					C << "\red You feel a painful force radiating from something nearby."
				C.adjustBruteLoss(1 * weakness)
				C.adjustFireLoss(1 * weakness)
				C.adjustToxLoss(1 * weakness)
				C.adjustOxyLoss(1 * weakness)
				C.adjustBrainLoss(1 * weakness)
				C.updatehealth()

/datum/artifact_effect/hurt/DoEffectPulse()
	if(holder)
		for (var/mob/living/carbon/C in range(effectrange, holder))
			var/weakness = GetAnomalySusceptibility(C)
			if(prob(weakness * 100))
				C << "\red A wave of painful energy strikes you!"
				C.adjustBruteLoss(3 * weakness)
				C.adjustFireLoss(3 * weakness)
				C.adjustToxLoss(3 * weakness)
				C.adjustOxyLoss(3 * weakness)
				C.adjustBrainLoss(3 * weakness)
				C.updatehealth()
