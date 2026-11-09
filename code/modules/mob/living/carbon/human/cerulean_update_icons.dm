// File of procs for human_update_icons.dm specifically to render cerulean clothing appropriately. so it doesn't get any more lines than it already has...

/**
 *	Modifies the sprite of clothing to have no legs! For pants, which mer folk canonically can't wear.
 *	What we generate will be saved in a cache, how nice!
 */
/obj/item/proc/generate_cerulean_icons(icon/base_icon, key, greyscale_colors, bodyshape)
	var/static/list/cerulean_icon_cache = list()
	var/mob/living/carbon/human/wearer = loc
	var/physique = wearer?.physique == FEMALE ? "f" : NONE
	var/index = "[key][physique ? "-[physique]" : ""]-[type]-[greyscale_colors]"
	var/icon/cerulean_clothing_icon = cerulean_icon_cache[index]

	if(cerulean_clothing_icon)
		return icon(cerulean_clothing_icon)

	if(isnull(greyscale_colors) || length(SSgreyscale.ParseColorString(greyscale_colors)) > 1)
		greyscale_colors = get_general_color(base_icon)

	// if we are generating for modsuits, we need to run through a bespoke proc!
	var/obj/item/clothing/suit/mod/modsuit_item = src
	if(istype(modsuit_item))
		cerulean_clothing_icon = modsuit_item.handle_cerulean_modsuit(base_icon, key, greyscale_colors, physique)
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
				if(physique == "f")
					var/flipper_color = greyscale_colors
					if(suit_item.cerulean_flipper_palette != FLIPPERS)
						flipper_color = suit_item.cerulean_flipper_palette
					if(flipper_color != NO_FLIPPERS)
						generate_fem_flippers(cerulean_clothing_icon, flipper_color)

	//not gen'ing is ok
	if(!cerulean_clothing_icon)
		cerulean_clothing_icon = base_icon
	//return gen'd icon
	cerulean_icon_cache[index] = fcopy_rsc(cerulean_clothing_icon)
	return icon(cerulean_clothing_icon)

/// apply a flipper icon for female physique Ceruleans, who have extra fins to keep their eggs close
/// ideally we color after the theme fetched from var/cerulean_flipper_palette
/obj/item/proc/generate_fem_flippers(icon/clothing_icon, set_color)
	clothing_icon.Blend(
		icon(
			SSgreyscale.GetColoredIconByType(
				/datum/greyscale_config/modular_mod_parts_cerulean/basic,
				set_color,
			),
		"[FLIPPERS]",
		),
	ICON_OVERLAY,
	)
