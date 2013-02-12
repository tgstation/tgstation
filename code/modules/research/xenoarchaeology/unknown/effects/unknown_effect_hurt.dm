
/datum/artifact_effect/hurt
	effecttype = "hurt"

/datum/artifact_effect/hurt/DoEffectTouch(var/mob/holder)
	//caeltodo
	if(holder)
		if (istype(holder, /mob/living/carbon/))
			var/mob/living/carbon/C = holder
			C << "\red A painful discharge of energy strikes you!"
			C.adjustOxyLoss(rand(5,25))
			C.adjustToxLoss(rand(5,25))
			C.adjustBruteLoss(rand(5,25))
			C.adjustFireLoss(rand(5,25))
			C.adjustBrainLoss(rand(5,25))
			C.radiation += 25
			C.nutrition -= min(50, C.nutrition)
			C.make_dizzy(6)
			C.weakened += 6
			return 1

/datum/artifact_effect/hurt/DoEffectAura()
	if(holder)
		for (var/mob/living/carbon/M in range(src.effectrange,holder))
			if(ishuman(M) && istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
				continue
			if(prob(10)) M << "\red You feel a painful force radiating from something nearby."
			M.adjustBruteLoss(1)
			M.adjustFireLoss(1)
			M.adjustToxLoss(1)
			M.adjustOxyLoss(1)
			M.adjustBrainLoss(1)
			M.updatehealth()
		return 1

/datum/artifact_effect/hurt/DoEffectPulse()
	if(holder)
		for (var/mob/living/carbon/human/M in range(effectrange, holder))
			M << "\red A wave of painful energy strikes you!"
			M.adjustBruteLoss(3)
			M.adjustFireLoss(3)
			M.adjustToxLoss(3)
			M.adjustOxyLoss(3)
			M.adjustBrainLoss(3)
			M.updatehealth()
		return 1
