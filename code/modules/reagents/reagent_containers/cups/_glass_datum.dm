/// Global list of all glass style singletons created. See [/proc/create_glass_styles] for list format.
GLOBAL_LIST_INIT(glass_style_singletons, create_glass_styles())

/**
 * Constructs a nested list of glass style singletons
 *
 * List format:
 * * list(glasses = list(beer = style datum, vodka = style datum), shot glasses = list(vodka = different style datum))
 *
 * Where
 * * "glasses" and "shotglasses" are item typepaths
 * * "beer" and "vodka" are reagent typepaths
 * * "style datum" is a glass style singleton datum
 *
 * Returns the list.
 */
/proc/create_glass_styles()
	var/list/final_list = list()
	for(var/datum/glass_style/style as anything in typesof(/datum/glass_style))
		if(!initial(style.required_drink_type) || !initial(style.required_container_type))
			continue

		var/datum/glass_style/new_style = new style()
		var/container_type = new_style.required_container_type
		var/reagent_type = new_style.required_drink_type
		if(!islist(final_list[container_type]))
			final_list[container_type] = list()
		// Check that our slot is free. If it's not free, this is an error
		if(final_list[container_type][reagent_type])
			stack_trace("[style] collided with another glass style singleton during instantiation. \
				This means its reagent ([reagent_type]) has two styles set for the same container type. \
				This is invalid - please correct this.")

		final_list[container_type][reagent_type] = new_style

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
	var/datum/reagent/required_drink_type
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

/// Helper to apply the entire style to something.
/datum/glass_style/proc/set_all(obj/item/thing)
	set_name(thing)
	set_desc(thing)
	set_appearance(thing)

/// Sets the passed item to our name.
/datum/glass_style/proc/set_name(obj/item/thing)
	thing.name = name

/// Sets the passed item to our description.
/datum/glass_style/proc/set_desc(obj/item/thing)
	thing.desc = desc

/// Sets the passed item to our icon and icon state.
/datum/glass_style/proc/set_appearance(obj/item/thing)
	thing.icon = icon
	thing.icon_state = icon_state

/datum/glass_style/drinking_glass
	required_container_type = /obj/item/reagent_containers/cup/glass/drinkingglass
	icon = 'icons/obj/drinks/drinks.dmi'

/datum/glass_style/shot_glass
	required_container_type = /obj/item/reagent_containers/cup/glass/drinkingglass/shotglass
	icon = 'icons/obj/drinks/shot_glasses.dmi'

/datum/glass_style/has_foodtype
	/// This style changes the "drink type" of the container it's placed it as well, it's like food types
	var/drink_type = NONE

/datum/glass_style/has_foodtype/drinking_glass
	required_container_type = /obj/item/reagent_containers/cup/glass/drinkingglass
	icon = 'icons/obj/drinks/drinks.dmi'

/datum/glass_style/has_foodtype/juicebox
	required_container_type = /obj/item/reagent_containers/cup/glass/bottle/juice/smallcarton
	icon = 'icons/obj/drinks/boxes.dmi'

/datum/glass_style/has_foodtype/soup
	required_container_type = /obj/item/reagent_containers/cup/bowl
	icon = 'icons/obj/food/soupsalad.dmi'

/datum/glass_style/has_foodtype/soup/New()
	. = ..()
	// By default: If name or description is unset, it will inherent from the soup reagent set
	if(!name)
		name = initial(required_drink_type.name)
	if(!desc)
		desc = initial(required_drink_type.description)
