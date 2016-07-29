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
		if(reagent.id == BLOOD && reagent.data["blood_colour"])
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

/proc/mix_alpha_from_reagents(const/list/reagent_list)
	if(!istype(reagent_list))
		return

	var/alpha
	var/total_alpha

	for(var/datum/reagent/reagent in reagent_list)
		total_alpha += reagent.alpha

	alpha = total_alpha / reagent_list.len

	return alpha

/proc/get_reagent_name(var/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/DG)
	if(!DG)
		return

	var/list/reagent_list = DG.reagents.reagent_list

	if(!reagent_list.len)
		DG.name = "glass of...nothing?"
		DG.desc = "You can't see anything inside that glass, odd"//this shouldn't ever happen
	else if(reagent_list.len > 4)
		DG.name = "mixture of chemicals"
		DG.desc = "There's too many different chemicals in the glass, you cannot tell them apart."
		DG.viewcontents = 0
	else
		var/highest_quantity = 0
		for(var/datum/reagent/reagent in reagent_list)
			var/new_reag = DG.reagents.get_reagent_amount(reagent.id)
			if(new_reag > highest_quantity)
				highest_quantity = new_reag
				DG.name = "glass of [reagent.name]"
				DG.desc = reagent.description
