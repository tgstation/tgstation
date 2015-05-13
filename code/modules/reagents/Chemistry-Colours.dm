/*
 * Returns:
 * 	#RRGGBB(AA) on success, null on failure
 */
/proc/mix_color_from_reagents(const/list/reagent_list)
	if(!istype(reagent_list))
		return

	var/color
	var/reagent_color
	var/vol_counter = 0
	var/vol_temp
	// see libs/IconProcs/IconProcs.dm
	for(var/datum/reagent/reagent in reagent_list)
		if(reagent.id == "blood" && reagent.data["blood_colour"])
			reagent_color = reagent.data["blood_colour"]
		else
			reagent_color = reagent.color

		vol_temp = reagent.volume
		vol_counter += vol_temp

		if(isnull(color))
			color = reagent.color
		else if(length(color) >= length(reagent_color))
			color = BlendRGB(color, reagent_color, vol_temp/vol_counter)
		else
			color = BlendRGB(reagent_color, color, vol_temp/vol_counter)

	return color
