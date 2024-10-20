
//================================TASTE===================================================
/**
 * Returns what this reagents in our given list taste like
 *
 * Arguments:
 * * list/reagent_list - List of reagents to taste.
 * * mob/living/taster - Who is doing the tasting. Some mobs can pick up specific flavours.
 * * minimum_percent - The lower the minimum percent, the more sensitive the message is.
 * * weight_modifier - Value to multiply each reagent's taste weight with.
 */
/proc/generate_reagents_taste_message(list/reagent_list, mob/living/taster, minimum_percent)
	var/list/out = list()
	var/list/tastes = list() //descriptor = strength
	if(minimum_percent <= 100)
		for(var/datum/reagent/reagent as anything in reagent_list)
			if(!reagent.taste_mult)
				continue

			var/list/taste_data = reagent.get_taste_description(taster)
			for(var/taste in taste_data)
				if(taste in tastes)
					tastes[taste] += taste_data[taste] * reagent.volume * reagent.taste_mult
				else
					tastes[taste] = taste_data[taste] * reagent.volume * reagent.taste_mult
		//deal with percentages
		// TODO it would be great if we could sort these from strong to weak
		var/total_taste = counterlist_sum(tastes)
		if(total_taste > 0)
			for(var/taste_desc in tastes)
				var/percent = tastes[taste_desc]/total_taste * 100
				if(percent < minimum_percent)
					continue
				var/intensity_desc = "a hint of"
				if(percent > minimum_percent * 2 || percent == 100)
					intensity_desc = ""
				else if(percent > minimum_percent * 3)
					intensity_desc = "the strong flavor of"
				if(intensity_desc != "")
					out += "[intensity_desc] [taste_desc]"
				else
					out += "[taste_desc]"

	return english_list(out, "something indescribable")
