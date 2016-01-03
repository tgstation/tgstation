/mob/living/proc/burn_calories(var/amount)
	if(nutrition - amount > 0)
		var/heatmodifier = 0.6
		nutrition = max(nutrition - amount,0)
		if((M_FAT in mutations))
			heatmodifier = heatmodifier*2
		bodytemperature += amount * heatmodifier
		return 1
	else
		return 0

/mob/living/proc/sweat(var/amount)
	if(nutrition - amount > 0)
		var/heatmodifier = 1
		nutrition = max(nutrition - amount,0)
		if((M_FAT in mutations))
			heatmodifier = heatmodifier*2
		bodytemperature -= amount * heatmodifier
		return 1
	else
		return 0