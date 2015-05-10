/*
 * Returns:
 * 	#RRGGBB(AA) on success, null on failure
 */
/proc/mix_color_from_reagents(const/list/reagent_list)
	if(!istype(reagent_list))
		return

	var/color
	var/reagent_color
	var/i = 0
	// see libs/IconProcs/IconProcs.dm
	for(var/datum/reagent/reagent in reagent_list)
		if(reagent.id == "blood" && reagent.data["blood_colour"])
			reagent_color = reagent.data["blood_colour"]
		else
			reagent_color = reagent.color
		i++
		if(isnull(color))
			color = reagent.color
		else if(length(color) >= length(reagent_color))
			color = BlendRGB(color, reagent_color, 1/i)
		else
			color = BlendRGB(reagent_color, color, 1/i)

	return color
