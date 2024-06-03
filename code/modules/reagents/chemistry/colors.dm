/proc/mix_color_from_reagents(list/reagent_list)
	if(!istype(reagent_list))
		return

	var/mixcolor
	var/vol_counter = 0
	var/vol_temp

	for(var/datum/reagent/R in reagent_list)
		vol_temp = R.volume
		vol_counter += vol_temp

		if(!mixcolor)
			mixcolor = R.color

		else if (length(mixcolor) >= length(R.color))
			mixcolor = BlendRGB(mixcolor, R.color, vol_temp/vol_counter)
		else
			mixcolor = BlendRGB(R.color, mixcolor, vol_temp/vol_counter)

	return mixcolor

/proc/reagent_threshold_overlay(datum/reagents/reagents, fill_icon, fill_prefix, list/fill_icon_thresholds)
	RETURN_TYPE(/mutable_appearance)

	var/threshold = null
	for(var/i in 1 to fill_icon_thresholds.len)
		if(ROUND_UP(100 * reagents.total_volume / reagents.maximum_volume) >= fill_icon_thresholds[i])
			threshold = i

	if(threshold)
		var/fill_name = "[fill_prefix][fill_icon_thresholds[threshold]]"
		var/mutable_appearance/filling = mutable_appearance(fill_icon, fill_name)
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		return filling

	return null
