
/datum/artifact_effect/heal
	effecttype = "heal"

/datum/artifact_effect/heal/DoEffectTouch(var/mob/user)
	//caeltodo
	if(user)
		if (istype(user, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = holder
			H << "\blue You feel a soothing energy invigorate you."

			for(var/datum/organ/external/affecting in H.organs)
				if(affecting && istype(affecting))
					affecting.heal_damage(25, 25)
			//H:heal_organ_damage(25, 25)
			//
			H.adjustOxyLoss(-25)
			H.adjustToxLoss(-25)
			H.adjustBruteLoss(-25)
			H.adjustFireLoss(-25)
			H.adjustBrainLoss(-25)
			H.radiation -= min(H.radiation, 25)
			H.nutrition += 50
			H.bodytemperature = initial(H.bodytemperature)
			//
			H.vessel.add_reagent("blood",50)
			spawn(1)
				H.fixblood()
			H.regenerate_icons()
			return 1

		else if (istype(user, /mob/living/carbon/monkey/))
			var/mob/living/carbon/monkey/M = holder
			M << "\blue You feel a soothing energy invigorate you."
			M.adjustOxyLoss(-25)
			M.adjustToxLoss(-25)
			M.adjustBruteLoss(-25)
			M.adjustFireLoss(-25)
			M.adjustBrainLoss(-25)
			return 1

/datum/artifact_effect/heal/DoEffectAura()
	//caeltodo
	for (var/mob/living/carbon/M in range(src.effectrange,holder))
		if(ishuman(M) && istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
			continue
		if(prob(10)) M << "\blue You feel a soothing energy radiating from something nearby."
		M.adjustBruteLoss(-1)
		M.adjustFireLoss(-1)
		M.adjustToxLoss(-1)
		M.adjustOxyLoss(-1)
		M.adjustBrainLoss(-1)
		M.updatehealth()
	return 1

/datum/artifact_effect/heal/DoEffectPulse()
	for (var/mob/living/carbon/M in range(src.effectrange,holder))
		if(ishuman(M) && istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
			continue
		M << "\blue A wave of energy invigorates you."
		M.adjustBruteLoss(-5)
		M.adjustFireLoss(-5)
		M.adjustToxLoss(-5)
		M.adjustOxyLoss(-5)
		M.adjustBrainLoss(-5)
		M.updatehealth()
	return 1
