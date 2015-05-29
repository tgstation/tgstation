
/proc/mix_color_from_reagents(var/list/reagent_list)
	if(!istype(reagent_list))
		return

	var/color
	var/vol_counter = 0
	var/vol_temp

	for(var/datum/reagent/R in reagent_list)
		vol_temp = R.volume
		vol_counter += vol_temp

		if(!color)
			color = R.color

		else if (length(color) >= length(R.color))
			color = BlendRGB(color, R.color, vol_temp/vol_counter)
		else
			color = BlendRGB(R.color, color, vol_temp/vol_counter)

	return color


