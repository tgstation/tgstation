
#define TEXT_NO_TASTE "something indescribable"

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
	// We can't taste anything
	if(minimum_percent > 100)
		return TEXT_NO_TASTE

	// Associative list of our tastes, descriptor - strength
	var/list/tastes = list()
	// Total of our taste strengths so far
	var/total_taste = 0

	for(var/datum/reagent/reagent as anything in reagent_list)
		if(!reagent.taste_mult)
			continue

		var/list/taste_data = reagent.get_taste_description(taster)
		for(var/taste in taste_data)
			var/taste_strength = taste_data[taste] * reagent.volume * reagent.taste_mult
			if(taste in tastes)
				tastes[taste] += taste_strength
			else
				tastes[taste] = taste_strength
			total_taste += taste_strength

	// None of our reagents had any flavour
	if(total_taste <= 0)
		return TEXT_NO_TASTE

	// If we have exactly one taste, don't bother with relative strengths
	if(length(tastes) == 1)
		return tastes[1]

	// Sort tastes descending by strength, so strong flavours come first
	sortTim(tastes, cmp = GLOBAL_PROC_REF(cmp_numeric_dsc), associative = TRUE)

	// Lazylists for different taste strength categories, no need to initialize if we don't have such flavors
	var/list/strong
	var/list/mild
	var/list/hint

	for(var/taste_desc in tastes)
		var/percent = tastes[taste_desc]/total_taste * 100
		if(percent < minimum_percent)
			continue

		if(percent <= minimum_percent * 2)
			LAZYADD(hint, taste_desc)
		else if(percent > minimum_percent * 4)
			LAZYADD(strong, taste_desc)
		else
			LAZYADD(mild, taste_desc)

	var/list/out = list()

	if(LAZYLEN(strong))
		out += "the strong flavor of [english_list(strong, TEXT_NO_TASTE)]"
	if(LAZYLEN(mild))
		// Prefix "some " if there are strong flavors to avoid seeming like a strong flavor
		out += "[LAZYLEN(strong) ? "some " : ""][english_list(mild, TEXT_NO_TASTE)]"
	if(LAZYLEN(hint))
		out += "a hint of [english_list(hint, TEXT_NO_TASTE)]"

	return english_list(out, TEXT_NO_TASTE)

#undef TEXT_NO_TASTE
