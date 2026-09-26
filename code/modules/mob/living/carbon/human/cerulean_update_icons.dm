/// define for lady physique Ceruleans, who have extra fins, to keep her eggs close. we'll cover these up if the modsuit is sealed
#define FEM_FLIPPER "f"

// File of procs for human_update_icons.dm specifically to render cerulean clothing appropriately. so it doesn't get any more lines than it already has...

/**
 *	Modifies the sprite of clothing to have no legs! For pants, which mer folk canonically can't wear.
 *	What we generate will be saved in a cache, how nice!
 */
/obj/item/proc/wear_cerulean_version(icon/base_icon, key, greyscale_colors, bodyshape)
	var/static/list/cerulean_icon_cache = list()
	var/mob/living/carbon/human/wearer = loc
	var/physique = wearer?.physique == FEMALE ? FEM_FLIPPER : NONE
	var/index = "[key][physique ? "-[physique]" : ""]-[type]-[greyscale_colors]"
	var/icon/cerulean_clothing_icon = cerulean_icon_cache[index]

	if(cerulean_clothing_icon)
		return icon(cerulean_clothing_icon)

	if(isnull(greyscale_colors) || length(SSgreyscale.ParseColorString(greyscale_colors)) > 1)
		greyscale_colors = get_general_color(base_icon)

	// if we are generating for modsuits, we need to run through a bespoke proc!
	var/obj/item/clothing/suit/mod/modsuit_item = src
	if(istype(modsuit_item))
		cerulean_clothing_icon = modsuit_item.handle_cerulean_modsuit(base_icon, greyscale_colors, physique)
	// go to work
	else if(bodyshapes_with_variations & BODYSHAPE_CERULEAN)
		// if we have to mask
		if(supports_variations_flags & CERULEAN_MASKING)
			// we are just cutting the pant
			if(supports_variations_flags & CLOTHING_CERULEAN_MASK_LEGS)
				cerulean_clothing_icon = apply_icon_mask(base_icon, LEGS_MASK)
			// remove any pixels that typically appear between the legs
			if(supports_variations_flags & CLOTHING_CERULEAN_MASK_INBETWEEN)
				cerulean_clothing_icon = apply_icon_mask(base_icon, BACK_COAT_MASK)

		// no masks, we have custom sprites
		else
			// uniforms
			var/obj/item/clothing/under/uniform_item = src
			if(istype(uniform_item) && icon_exists(CERULEAN_UNIFORM_FILE, icon_state))
			/*
				if(greyscale_config_worn) //if we r gags we gotta color
					cerulean_clothing_icon = icon(
						SSgreyscale.GetColoredIconByType(
							/datum/greyscale_config/uniform_worn_cerulean,
							greyscale_colors,
						),
						icon_state,
					)
				else
					cerulean_clothing_icon = icon(CERULEAN_UNIFORM_FILE, icon_state)
			*/
				cerulean_clothing_icon = icon(CERULEAN_UNIFORM_FILE, icon_state)
			// suits
			var/obj/item/clothing/suit/suit_item = src
			if(istype(suit_item) && icon_exists(CERULEAN_SUIT_FILE, icon_state))
				if(greyscale_config_worn)
					cerulean_clothing_icon = icon(
						SSgreyscale.GetColoredIconByType(
							/datum/greyscale_config/suit_worn_cerulean,
							greyscale_colors,
						),
						icon_state,
					)
				else
					cerulean_clothing_icon = icon(CERULEAN_SUIT_FILE, icon_state)

				// flippy flippers
				if(physique == FEM_FLIPPER && suit_item.cerulean_flipper_palette != NO_FLIPPERS)
					cerulean_clothing_icon.Blend(
						icon(
							SSgreyscale.GetColoredIconByType(
								/datum/greyscale_config/modular_mod_parts_cerulean/basic,
								suit_item.cerulean_flipper_palette || greyscale_colors,
							),
							"[FLIPPERS]",
						),
						ICON_OVERLAY,
					)

	//not gen'ing is ok
	if(!cerulean_clothing_icon)
		cerulean_clothing_icon = base_icon
	//return gen'd icon
	cerulean_icon_cache[index] = fcopy_rsc(cerulean_clothing_icon)
	return icon(cerulean_clothing_icon)

/// define for the string added to modsuit icon_states when sealed
#define SEALED "sealed"


/**
 *	This proc handles icon building for Ceruleans wearing modsuits.
 *	If a drawn sprite exists, we prioritize it. If it doesn't, we'll look for an entry in var/list/cerulean_tail_palette
 *	If that doesn't, we'll generate a basic modsuit icon for the Cerulean.
 */
/obj/item/clothing/suit/mod/proc/handle_cerulean_modsuit(icon/base_icon, greyscale_colors, physique)
	/// whether the modsuit is sealed or open, we read this from our lovely key
	var/sealed = findtext(icon_state, SEALED) ? TRUE : FALSE
	/// the entry in var/list/cerulean_tail_palette
	var/datum/mod_theme/theme = GLOB.mod_themes[find_mod_theme(icon_state)]

	/// our full icon state string, lets find a pre-drawn modsuit!
	var/icon_state_string = "[physique == FEM_FLIPPER ? "[FEM_FLIPPER]-" : ""][icon_state]"
	if(icon_exists(CERULEAN_MODSUIT_FILE, icon_state_string))
		// we have a pre-drawn modsuit, yay
		return icon(CERULEAN_MODSUIT_FILE, icon_state_string)

	// lets cut away the legs first, we really don't need them
	apply_icon_mask(base_icon, LEGS_MASK)
	// lets run through generating according to what our variables are set to
	if(!isnull(theme?.cerulean_tail_palette))
		// add a colored icon for each modular part, according to the theme fetched
		var/list/modular_part_list = theme.cerulean_tail_palette.Copy()
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
				"undefined[sealed ? "-[SEALED]" : ""]",
			),
			ICON_OVERLAY,
		)
	// apply a flipper icon if we are sealed and have a female physique.
	// ideally we color after the theme fetched from var/cerulean_flipper_palette
	if(physique == FEM_FLIPPER && sealed && theme.cerulean_flipper_palette != NO_FLIPPERS)
		var/color_to_use = (theme.cerulean_flipper_palette == FLIPPERS) ? greyscale_colors : theme.cerulean_flipper_palette
		base_icon.Blend(
			icon(
				SSgreyscale.GetColoredIconByType(
					/datum/greyscale_config/modular_mod_parts_cerulean/basic,
					color_to_use,
				),
				"[FLIPPERS]",
			),
			ICON_OVERLAY,
		)

	// 🪸🐟
	return base_icon

/// Simple proc to search through mod_themes global to return a theme path
/proc/find_mod_theme(haystack)
	for(var/datum/mod_theme/theme_entry as anything in GLOB.mod_themes)
		if(findtext(haystack, theme_entry.name))
			return theme_entry

#undef FEM_FLIPPER
#undef SEALED
