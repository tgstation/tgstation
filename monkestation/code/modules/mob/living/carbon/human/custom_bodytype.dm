GLOBAL_LIST_EMPTY(species_clothing_fallback_cache)

/**
 * Modularly returns one of worn_icon_vox, worn_icon_teshari, etc.
 * Arguments:
 * * item_slot: The slot we're updating. One of LOADOUT_ITEM_HEAD, etc.
 * * item is the item we're checking.
 */
/datum/species/proc/get_custom_worn_icon(item_slot, obj/item/item)
	return null

/**
 * Modularly set one of worn_icon_vox, worn_icon_teshari, etc.
 * Arguments:
 * * item_slot: The slot we're updating. One of LOADOUT_ITEM_HEAD, etc.
 * * item is the item we're updating.
 * * icon is the icon we're setting to the var.
 */
/datum/species/proc/set_custom_worn_icon(item_slot, obj/item/item, icon/icon)
	return

/**
 * Modularly get the species' fallback greyscale config.
 * Only used if you use generate_custom_worn_icon_fallback()
 * Arguments:
 * * item_slot: The slot we're updating. One of LOADOUT_ITEM_HEAD, etc.
 * * item: The item being rendered.
 */
/datum/species/proc/get_custom_worn_config_fallback(item_slot, obj/item/item)
	CRASH("`get_custom_worn_config_fallback()` was not implemented for [type]!")

/datum/species/proc/use_custom_worn_icon_cached()
	LAZYINITLIST(GLOB.species_clothing_fallback_cache[name])

/**
 * Read from freely usable cache of generated icons for your species.
 * Arguments:
 * * file_to_use: icon you're substituting
 * * state_to_use: icon state you're substituting
 * * meta: string containing other info.
 */
/datum/species/proc/get_custom_worn_icon_cached(file_to_use, state_to_use, meta)
	return GLOB.species_clothing_fallback_cache[name]["[file_to_use]-[state_to_use]-[meta]"]

/**
 * Write to a freely usable cache of generated icons for your species.
 * Arguments:
 * * file_to_use: icon you're substituting
 * * state_to_use: icon state you're substituting
 * * meta: string containing other info.
 * * cached_value: Cached value
 */
/datum/species/proc/set_custom_worn_icon_cached(file_to_use, state_to_use, meta, cached_value)
	GLOB.species_clothing_fallback_cache[name]["[file_to_use]-[state_to_use]-[meta]"] = cached_value

/**
 * Allow for custom clothing icon generation. Only called if the species is BODYTYPE_CUSTOM
 * If null is returned, use default human icon.
 * Arguments:
 * * item_slot: The slot we're updating. One of LOADOUT_ITEM_HEAD, etc.
 * * item: The item being rendered.
 */
/datum/species/proc/generate_custom_worn_icon(item_slot, obj/item/item)
	// If already set (possibly by us, or manually, use it.)
	var/icon/final_icon = get_custom_worn_icon(item_slot, item)
	if(final_icon && icon_exists(final_icon, item.worn_icon_state || item.icon_state))
		return final_icon

	// Else check if in custom icon.
	if(!(item_slot in custom_worn_icons))
		return null

	var/icon/species_worn_icon = custom_worn_icons[item_slot]
	var/list/species_icon_states = icon_states(species_worn_icon)

	// Check if there is a custom icon state.
	if(!((item.worn_icon_state || item.icon_state) in species_icon_states))
		return null

	// Remember and use icon.
	set_custom_worn_icon(item_slot, item, species_worn_icon)
	return species_worn_icon

/**
 * Generate a fallback worn icon, if the species supports it. You must call it in an override of generate_custom_worn_icon()
 */
/datum/species/proc/generate_custom_worn_icon_fallback(item_slot, obj/item/item)
	var/icon/human_icon = item.worn_icon || item.icon
	var/human_icon_state = item.worn_icon_state || item.icon_state

	// First, let's just check if we've already made this.
	use_custom_worn_icon_cached()
	var/icon/cached_icon = get_custom_worn_icon_cached(human_icon, human_icon_state, item.greyscale_colors || "x")
	if(cached_icon)
		if(!(human_icon_state in icon_states(cached_icon)))
			cached_icon.Insert(cached_icon, icon_state = human_icon_state) // include the expected icon_state
		return cached_icon

	// Get GAGs config
	var/fallback_config = get_custom_worn_config_fallback(item_slot, item)
	if(!fallback_config)
		return null

	// The GAGs config needs this many colors.
	var/expected_num_colors = SSgreyscale.configurations["[fallback_config]"].expected_colors
	// The colors string.
	var/fallback_greyscale_colors

	// If this outfit is already GAGs, use the existing colors.
	if(item.greyscale_colors)
		// Just use the colors already given to us, but re-align to expected colors.
		var/list/colors = SSgreyscale.ParseColorString(item.greyscale_colors)
		var/default_color = (length(colors) >= 1) ? colors[1] : COLOR_DARK
		var/list/final_list = list()
		for(var/i in 1 to expected_num_colors)
			final_list += (i < length(colors)) ? colors[i] : default_color
		fallback_greyscale_colors = final_list.Join("")
	else
		// OK, we have to actually guess the colors.
		var/icon/final_human_icon = icon(human_icon, human_icon_state)
		var/list/color_list = list()

		for(var/i in 1 to expected_num_colors)
			if(length(item.species_clothing_color_coords) < i)
				color_list += COLOR_DARK
				continue
			var/coord = item.species_clothing_color_coords[i]
			color_list += final_human_icon.GetPixel(coord[1], coord[2]) || COLOR_DARK

		fallback_greyscale_colors = color_list.Join("")

	// Finally, render with GAGs
	var/icon/final_icon = SSgreyscale.GetColoredIconByType(get_custom_worn_config_fallback(item_slot, item), fallback_greyscale_colors)
	// Duplicate to the specific icon_state and set.
	final_icon.Insert(final_icon, icon_state = human_icon_state) // include the expected icon_state
	// Cache the clean copy.
	set_custom_worn_icon_cached(human_icon, human_icon_state, item.greyscale_colors || "x", final_icon)

	return final_icon
