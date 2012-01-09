/mob/living/carbon/var/traumatic_shock = 0
/mob/living/carbon/var/shock_stage = 0

// proc to find out in how much pain the mob is at the moment
/mob/living/carbon/proc/updateshock()
	src.traumatic_shock = src.getOxyLoss() + src.getToxLoss() + src.getFireLoss() + 1.2*src.getBruteLoss() + 2*src.getCloneLoss()
	if(reagents.has_reagent("alkysine"))
		src.traumatic_shock -= 10
	if(reagents.has_reagent("inaprovaline"))
		src.traumatic_shock -= 25
	if(reagents.has_reagent("synaptizine"))
		src.traumatic_shock -= 100 // make synaptizine function as good painkiller

	// broken or ripped off organs will add quite a bit of pain
	if(istype(src,/mob/living/carbon/human))
		var/mob/living/carbon/human/M = src
		for(var/name in M.organs)
			var/datum/organ/external/organ = M.organs[name]
			if(organ.destroyed)
				src.traumatic_shock += 60
			else if(organ.broken)
				src.traumatic_shock += 40

	return src.traumatic_shock


/mob/living/carbon/proc/handle_shock()
	updateshock()
