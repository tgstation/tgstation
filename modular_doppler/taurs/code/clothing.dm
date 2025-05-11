GLOBAL_LIST_EMPTY(taur_clothing_icons)

/obj/item
	/// Does this object get cropped when worn by a taur on their suit or uniform slot?
	var/gets_cropped_on_taurs = FALSE // Primitive values such as 1 (true) have minimal memory impact when on a basetype, as long as the value doesnt change.

/obj/item/clothing/suit
	gets_cropped_on_taurs = TRUE

/obj/item/clothing/under
	gets_cropped_on_taurs = TRUE

/obj/item/clothing/under/color/jumpskirt
	gets_cropped_on_taurs = FALSE // its a skirt

/obj/item/clothing/under/dress/skirt
	gets_cropped_on_taurs = FALSE // its a skirt

/**
 * Proc to generate a taur variation of clothes, with the intent of caching them.
 * It is meant for suits and uniforms at the moment, to cut out the bottom half so that
 * it doesn't look too out of place.
 *
 * Arguments:
 * * index - The index at which the icon will be stored. Overwrites existing icons if there was one,
 * do your checks before calling this proc.
 * * icon_to_process (/icon) - The icon we want to run through the process of masking off the bottom part of.
 * * icon_state - The icon_state of the icon we're being given, to obtain a proper icon object.
 * * cropping_state - The icon state used for the cropping mask.
 */
/proc/generate_taur_clothing(index, icon/icon_to_process, icon_state, cropping_state)
	var/icon/taur_clothing_icon = icon("icon" = icon_to_process, "icon_state" = icon_state)
	var/taur_icon_state = cropping_state
	var/icon/taur_cropping_mask = icon("icon" = 'modular_doppler/taurs/icons/taur_masking_helpers.dmi', "icon_state" = taur_icon_state)
	taur_clothing_icon.Blend(taur_cropping_mask, ICON_MULTIPLY)
	taur_clothing_icon = fcopy_rsc(taur_clothing_icon)
	GLOB.taur_clothing_icons[index] = taur_clothing_icon

/**
 * Proc that handles returning a mutable appearance that can fit on a taur body without looking too janky!
 *
 * It will check the cache to see if there was already an icon created for the taur version of that item,
 * and will generate one if there was none, and will return the proper icon straight from `GLOB.taur_clothing_icons`,
 * to avoid expensive icon operations.
 *
 * Arguments:
 * * icon_state - The icon state that was used to create the icon that will now be processed.
 * Used to store the taur icon in the cache.
 * * icon_to_process (/icon) - The icon that we want to process. Do note that this is already
 * an icon, and NOT an icon file, because we want to be able to operate on icons that have been
 * modified to fit female bodytypes, for instance.
 * * female_type - The `female_flags` of the clothing item used to generate the icon that
 * we're operating on, if appropriate, to allow the caching of female-fitted uniforms.
 * * greyscale_colors - The colors of the icon if it was a greyscale one, to make this GAGS-compatible.
 * * cropping_state - The icon state used for the cropping mask.
 *
 * Returns a taur-compatible mutable_appearance!
 */
/proc/wear_taur_version(icon_state, icon/icon_to_process, female_type, greyscale_colors, cropping_state)
	RETURN_TYPE(/mutable_appearance)

	var/index = "[icon_state]-[greyscale_colors]-[female_type]-[cropping_state]"
	var/icon/taur_clothing_icon = GLOB.taur_clothing_icons[index]
	if(!taur_clothing_icon) 	//Create standing/laying icons if they don't exist
		generate_taur_clothing(index, icon_to_process, icon_state, cropping_state)
	return icon(GLOB.taur_clothing_icons[index])
