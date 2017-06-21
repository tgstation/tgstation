/datum/reagent/toxin/mutagen/reaction_mob(mob/living/W, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(!istype(W, /mob/living/carbon))
		return FALSE
	var/mob/living/carbon/M = W
	if(!M.has_dna())
		return FALSE
	if(method==VAPOR)
		if(M.reagents)
			var/modifier = Clamp((1 - touch_protection), 0, 1)
			var/amount = round(reac_volume*modifier, 0.1)
			if(amount >= 0.5)
				M.reagents.add_reagent(id, amount)
		if(prob(min(33, reac_volume)))
			M.randmuti()
			if(prob(98))
				M.randmutb()
			else
				M.randmutvg()
			M.updateappearance()
			M.domutcheck()
	else
		M.randmuti()
		if(prob(98))
			M.randmutb()
		else
			M.randmutvg()
		M.updateappearance()
		M.domutcheck()
	return TRUE