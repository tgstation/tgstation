/mob/living/proc/burn_calories(var/amount,var/forceburn = 0)
	if(forceburn && ticker && ticker.hardcore_mode)
		forceburn = 0
	if(nutrition - amount > 0 || forceburn)
		var/heatmodifier = 0.7
		nutrition = max(nutrition - amount,0)
		if((M_FAT in mutations))
			heatmodifier = heatmodifier*2
		bodytemperature += amount * heatmodifier
		return 1
	else
		return 0

/mob/living/proc/sweat(var/amount,var/forcesweat = 0)
	if(istype(src,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		if(!H.species.has_sweat_glands)
			return 1
	if(forcesweat && ticker && ticker.hardcore_mode)
		forcesweat = 0
	var/sustenance = amount / 50
	if(nutrition - sustenance > 0 || forcesweat)
		var/heatmodifier = 1
		nutrition = max(nutrition - sustenance,0)
		if((M_FAT in mutations))
			heatmodifier = heatmodifier*2
		bodytemperature -= amount * heatmodifier
		return 1
	else
		return 0