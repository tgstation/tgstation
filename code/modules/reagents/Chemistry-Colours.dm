/*
 * Returns:
 * 	#RRGGBB(AA) on success, null on failure
 */
/proc/mix_color_from_reagents(const/list/reagent_list)
	if(!istype(reagent_list))
		return

	var/color

	for(var/datum/reagent/reagent in reagent_list)
		if(isnull(color))
			color = reagent.color
		else
			color = BlendRGB(color, reagent.color, 0.5) // see libs/IconProcs/IconProcs.dm

	return color
