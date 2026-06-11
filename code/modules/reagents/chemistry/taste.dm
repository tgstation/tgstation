
#define TEXT_NO_TASTE "something indescribable"

//=============================== TASTE GRAPH ====================================
//                                                                              //
// Flavor Intensity Thresholds (Relative to Detection Threshold % 'DT'):        //
// 0%             1x DT              2x DT              4x DT             100%  //
// |----------------|------------------|------------------|-----------------|   //
// |   Undetected   |       Weak       |       Mild       |      Strong     |   //
// |----------------|------------------|------------------|-----------------|   //
//                                                                              //
//==============================================================================//

/**
 * Returns what the reagents in our given list taste like
 *
 * Arguments:
 * * list/reagent_list - List of reagents to taste.
 * * mob/living/taster - Who is doing the tasting. Some mobs can pick up specific flavours.
 * * detection_threshold_percent - The minimum relative percentage a flavor must reach to be tasted.
 */
/proc/generate_reagents_taste_message(list/reagent_list, mob/living/taster, detection_threshold_percent)
	// We can't taste anything
	if(detection_threshold_percent > 100)
		return TEXT_NO_TASTE

	// Associative list of our tastes - list("taste description" = strength)
	var/list/tastes = list()
	var/total_taste_strength = 0

	for(var/datum/reagent/reagent as anything in reagent_list)
		if(!reagent.taste_mult)
			continue

		var/list/taste_data = reagent.get_taste_description(taster)
		for(var/taste_desc in taste_data)
			var/taste_strength = taste_data[taste_desc] * reagent.volume * reagent.taste_mult
			tastes[taste_desc] += taste_strength
			total_taste_strength += taste_strength

	// None of our reagents had any flavour
	if(total_taste_strength <= 0)
		return TEXT_NO_TASTE

	// If we have exactly one taste, don't bother with relative strengths
	if(length(tastes) == 1)
		return tastes[1]

	// Sort tastes descending by strength, so strong flavours come first
	sortTim(tastes, cmp = GLOBAL_PROC_REF(cmp_numeric_dsc), associative = TRUE)

	// Lazylists for different taste strength categories, no need to initialize if we don't have such flavors
	var/list/strong_tastes
	var/list/mild_tastes
	var/list/weak_tastes

	for(var/taste_desc in tastes)
		var/relative_taste_percent = (tastes[taste_desc] / total_taste_strength) * 100

		// From weakest to strongest
		if(relative_taste_percent < detection_threshold_percent)
			continue // too weak to detect
		else if(relative_taste_percent <= detection_threshold_percent * 2)
			LAZYADD(weak_tastes, taste_desc)
		else if(relative_taste_percent <= detection_threshold_percent * 4)
			LAZYADD(mild_tastes, taste_desc)
		else
			LAZYADD(strong_tastes, taste_desc)

	var/list/taste_messages = list()

	if(LAZYLEN(strong_tastes))
		taste_messages += "the strong flavor of [english_list(strong_tastes, TEXT_NO_TASTE)]"
	if(LAZYLEN(mild_tastes))
		// Prefix "some " if there are strong flavors to avoid seeming like a strong flavor
		taste_messages += "[LAZYLEN(strong_tastes) ? "some " : ""][english_list(mild_tastes, TEXT_NO_TASTE)]"
	if(LAZYLEN(weak_tastes))
		taste_messages += "a hint of [english_list(weak_tastes, TEXT_NO_TASTE)]"

	return english_list(taste_messages, TEXT_NO_TASTE)

#undef TEXT_NO_TASTE
