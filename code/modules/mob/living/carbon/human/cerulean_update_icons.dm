// File of procs for human_update_icons.dm specifically to render cerulean clothing appropriately. so it doesn't get any more lines than it already has...

/**
 *              sSSs,
 *	         V, \_SSSS,
 *	          \\/((`\Ss
 *	    ._     \/)_|\\Ss
 *	    \ `-.-""'  ///SS
 *	    /_.-'`-==-' ' '
 *	Modifies the sprite of clothing to have no legs! For pants, which mer folk canonically can't wear.
 *	What we generate will be saved in a cache, how nice! Our index look slightly different than the sister proc wear_digi_version(...)
 *	we also assign physique into the end of the key, and read this in handle_cerulean_modsuit(...)
 */
/proc/wear_cerulean_version(icon/base_icon, obj/item/item, key, greyscale_colors)
	ASSERT(istype(item), "wear_cerulean_version: no item passed")
	ASSERT(istext(key), "wear_cerulean_version: no key passed")
	if(isnull(greyscale_colors) || length(SSgreyscale.ParseColorString(greyscale_colors)) > 1)
		greyscale_colors = item.get_general_color(base_icon)

	var/static/list/mer_clothing_icons = list()
	var/index = "[key]-[item.type]-[greyscale_colors]"
	var/icon/mer_clothing_icon = mer_clothing_icons[index]

	if(mer_clothing_icon)
		return icon(mer_clothing_icon)

	if(istype(item, /obj/item/clothing/suit/mod))
		var/mob/living/carbon/human/wearer = item.loc
		var/physique = wearer?.physique == FEMALE ? "f" : "m"
		index = "[key]-[item.type]-[greyscale_colors]-[physique]"
		mer_clothing_icon = mer_clothing_icons[index]
		if(mer_clothing_icon)
			return icon(mer_clothing_icon)
		// if we are generating for modsuits, we need to run through a bespoke proc!
		mer_clothing_icon = handle_cerulean_modsuit(base_icon, item, "[key]-[physique]", greyscale_colors)
	else
		// we are just cutting the pant
		if(item.supports_variations_flags & CLOTHING_CERULEAN_MASK_LEGS)
			mer_clothing_icon = apply_icon_mask(base_icon, LEGS_MASK)
		// remove any pixels that typically appear between the legs
		if(item.supports_variations_flags & CLOTHING_CERULEAN_MASK_INBETWEEN)
			mer_clothing_icon = apply_icon_mask(base_icon, BACK_COAT_MASK)

	if(!mer_clothing_icon)
		stack_trace("[item.type] was set to generate a Cerulean fish-tail clothing icon, but there was no result.")
		return base_icon

	mer_clothing_icons[index] = fcopy_rsc(mer_clothing_icon)
	return icon(mer_clothing_icon)

/// in reference to GLOB.mer_mod_theme and its entries. if (un)defined, the following proc generates accordingly
#define NO_THEME_ENTRY "undefined"
#define FEM_FLIPPER "f" //lady physique Ceruleans have extra fins, to keep her eggs close. we'll cover these up if the modsuit is sealed
#define SEALED "sealed"

/**
 *	This proc handles icon building for Ceruleans wearing modsuits.
 *	If a drawn sprite exists, we prioritize it. If it doesn't, we'll look for an entry in GLOB.mer_mod_theme
 *	If that doesn't, we'll generate a basic modsuit icon for the Cerulean.
 */
/proc/handle_cerulean_modsuit(icon/base_icon, obj/item/clothing/chestpiece, key, greyscale_colors)
	/// whether the modsuit is sealed or open, we read this from our lovely key
	var/sealed = findtext(key, SEALED) ? TRUE : FALSE
	/// whether our wearer has boy or girl physique, read from the last symbol of our key
	var/physique = copytext_char(key, length(key))
	/// the entry in GLOB.mer_mod_theme
	var/datum/mod_theme/theme = return_mer_mod_theme_from_key(key)

	/// our full icon state string, lets find a pre-drawn modsuit!
	var/icon_state_string = "[physique == FEM_FLIPPER ? "[FEM_FLIPPER]-" : ""][chestpiece.icon_state]"
	if(icon_exists(CERULEAN_MODSUIT_FILE, icon_state_string))
		// we have a pre-drawn modsuit, yay
		return icon(CERULEAN_MODSUIT_FILE, icon_state_string)

	// lets cut away the legs first, we really don't need them
	apply_icon_mask(base_icon, LEGS_MASK)
	// lets run through generating according to what our variables are set to
	if(!isnull(GLOB.mer_mod_theme[theme]) && theme != NO_THEME_ENTRY)
		// add a colored icon for each modular part, according to the theme fetched from GLOB.mer_mod_theme
		var/list/modular_part_list = GLOB.mer_mod_theme[theme]
		for(var/index in 1 to length(modular_part_list))
			base_icon.Blend(
				icon(
					SSgreyscale.GetColoredIconByType(
						/datum/greyscale_config/modular_mod_parts_cerulean,
						modular_part_list[modular_part_list[index]],
					),
					"[modular_part_list[index]][sealed ? "-[SEALED]" : ""]",
				),
				ICON_OVERLAY,
			)
	else
		// we have no drawn sprite and no entry in the preset combinations alist. one little neglected modsuit :(
		// lets generate from our broadstroke preset
		base_icon.Blend(
			icon(
				SSgreyscale.GetColoredIconByType(
					/datum/greyscale_config/modular_mod_parts_cerulean/basic,
					greyscale_colors,
				),
				"[NO_THEME_ENTRY][sealed ? "-[SEALED]" : ""]",
			),
			ICON_OVERLAY,
		)
	// apply a flipper icon if we are sealed and have a female physique.
	// ideally we color after the theme fetched from GLOB.mod_theme_to_flipper_color
	if(physique == FEM_FLIPPER && sealed && GLOB.mod_theme_to_flipper_color[theme] != NO_FLIPPERS)
		base_icon.Blend(
			icon(
				SSgreyscale.GetColoredIconByType(
					/datum/greyscale_config/modular_mod_parts_cerulean/basic,
					GLOB.mod_theme_to_flipper_color[theme] ? GLOB.mod_theme_to_flipper_color[theme] : greyscale_colors,
				),
				"[FLIPPERS]",
			),
			ICON_OVERLAY,
			)

	// 🪸🐟
	return base_icon


#undef FEM_FLIPPER
#undef SEALED

/// Simple proc to search through some lists to return what the above proc is looking for
/proc/return_mer_mod_theme_from_key(key)
	var/static/list/all_theme_entries = (GLOB.mer_mod_theme + GLOB.mod_theme_to_flipper_color)
	for(var/datum/mod_theme/theme_entry as anything in all_theme_entries)
		if(findtext(key, theme_entry.name))
			return theme_entry
	return NO_THEME_ENTRY

#undef NO_THEME_ENTRY
