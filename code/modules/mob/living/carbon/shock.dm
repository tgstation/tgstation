/mob/living/carbon/var/traumatic_shock = 0
/mob/living/carbon/var/shock_stage = 0

// proc to find out in how much pain the mob is at the moment
/mob/living/carbon/proc/updateshock()
	src.traumatic_shock = src.getOxyLoss() + src.getToxLoss() + src.getFireLoss() + 1.5*src.getBruteLoss() + 2*src.getCloneLoss()
	if(reagents.has_reagent("alkysine"))
		src.traumatic_shock -= 10
	if(reagents.has_reagent("inaprovaline"))
		src.traumatic_shock -= 15
	if(reagents.has_reagent("synaptizine"))
		src.traumatic_shock -= 50

	return src.traumatic_shock


/mob/living/carbon/proc/handle_shock()
	updateshock()