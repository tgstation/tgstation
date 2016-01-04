/mob/living/proc/burn_calories(var/amount)
	if(nutrition - amount > 0)
		var/heatmodifier = 0.7
		nutrition = max(nutrition - amount,0)
		if((M_FAT in mutations))
			heatmodifier = heatmodifier*2
		bodytemperature += amount * heatmodifier
		return 1
	else
		return 0

/mob/living/proc/sweat(var/amount)
	var/sustenance = amount / 50
	if(nutrition - sustenance > 0)
		var/heatmodifier = 1
		nutrition = max(nutrition - sustenance,0)
		if((M_FAT in mutations))
			heatmodifier = heatmodifier*2
		bodytemperature -= amount * heatmodifier
		return 1
	else
		return 0