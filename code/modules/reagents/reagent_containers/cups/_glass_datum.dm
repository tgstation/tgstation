GLOBAL_LIST_INIT(glass_style_singletons, create_glass_styles())

/proc/create_glass_styles()
	/*
	 * List format:
	 *
	 * list(
	 *   glasses = list(
	 *     beer = style datum,
	 *     rum = style datum,
	 *     vodka = style datum,
	 *   ),
	 *   shot glasses = list(
	 *     vodka = different style datum,
	 *   ),
	 * )
	 */
	var/list/final_list = list()
	for(var/datum/glass_style/style as anything in typesof(/datum/glass_style))
		if(!initial(style.required_drink_type) || !initial(style.required_container_type))
			continue

		var/datum/glass_style/new_style = new style()
		if(!islist(final_list[new_type.required_container_type]))
			final_list[new_type.required_container_type] = list()
		// Check that our slot is free. If it's not free, this is an error
		if(final_list[new_type.required_container_type][required_drink_type])
			stack_trace("[style] collided with another glass style singleton during instantiation. \
				This means its reagent ([required_drink_type]) has two styles set for the same container type. \
				This is invalid - please correct this.")

		final_list[new_type.required_container_type][required_drink_type] = new_style

	return final_list

/**
 * ## Glass style singleton
 *
 * Used by [/datum/component/takes_reagent_appearance], and a few other places,
 * to modify the looks of a reagent container (not /reagent_containers, any atom with reagents)
 * when certain types of reagents are put into and become the majority reagent of the container
 *
 * For example, pouring Vodka into a glass will change its icon to look like the vodka glass sprite
 * while pouring it into a shot glass will change to the vodka shot glass sprite
 *
 * A reagent type can have multiple glass styles so long as each style is linked to a different container type,
 * this allows one reagent to style multiple things across a variety of icon files
 */
/datum/glass_style
	/// Required - What EXACT type of reagent is needed for this style to be used
	/// If not supplied, will be assumed to be an abstract type and will not be instantiated
	var/required_drink_type
	/// Required - What EXACT type of atom is needed for this style to be used
	/// If not supplied, will be assumed to be an abstract type and will not be instantiated
	var/required_container_type
	/// Optional - What the glass is renamed to
	var/name
	/// Optional - What the glass description is changed to
	var/desc
	/// Suggested - What icon file to use for this glass style
	var/icon
	/// Suggested - What icon state is used for this glass style
	var/icon_state

/datum/glass_style/drinking_glass
	required_container_type = /obj/item/reagent_containers/cup/glass/drinkingglass
	icon = 'icons/obj/drinks/drinks.dmi'

/datum/glass_style/shot_glass
	required_container_type = /obj/item/reagent_containers/cup/glass/drinkingglass/shotglass
	icon = 'icons/obj/drinks/shot_glasses.dmi'
	// shot glasses drop name and desc anyways.
