/*
 * Returns:
 * 	#RRGGBB(AA) on success, null on failure
 */
/proc/mix_color_from_reagents(const/list/reagent_list)
	if(!istype(reagent_list))
		return

	var/color

	// see libs/IconProcs/IconProcs.dm
	for(var/datum/reagent/reagent in reagent_list)
		if(isnull(color))
			color = reagent.color
		else if(length(color) >= length(reagent.color))
			color = BlendRGB(color, reagent.color, 0.5)
		else
			color = BlendRGB(reagent.color, color, 0.5)

	return color
