/obj/item/clothing/head/mod
	name = "\improper MOD helmet"
	desc = "A helmet for a MODsuit."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-helmet"
	base_icon_state = "helmet"
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	armor_type = /datum/armor/none
	body_parts_covered = HEAD
	heat_protection = HEAD
	cold_protection = HEAD
	item_flags = NONE

// Even without a hat stabilizer, hats can be worn - however, they'll fall off very easily
/obj/item/clothing/head/mod/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_SPEED_POTION, INNATE_TRAIT)
	AddComponent(/datum/component/hat_stabilizer, loose_hat = TRUE)
	AddElement(/datum/element/equipment_bodypart_texture, BODY_ZONE_HEAD, /datum/bodypart_texture/mesh/space)

/obj/item/clothing/suit/mod
	name = "\improper MOD chestplate"
	desc = "A chestplate for a MODsuit."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-chestplate"
	base_icon_state = "chestplate"
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	blood_overlay_type = "armor"
	allowed = list(
		/obj/item/tank/internals,
		/obj/item/flashlight,
		/obj/item/tank/jetpack/captain,
	)
	armor_type = /datum/armor/none
	body_parts_covered = CHEST|GROIN
	heat_protection = CHEST|GROIN
	cold_protection = CHEST|GROIN
	drop_sound = null
	item_flags = NONE

/obj/item/clothing/suit/mod/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_SPEED_POTION, INNATE_TRAIT)
	AddElement(/datum/element/equipment_bodypart_texture, BODY_ZONE_CHEST, /datum/bodypart_texture/mesh/space)

/**
 *	This proc handles icon building for Ceruleans wearing modsuits.
 *	If a drawn sprite exists, we prioritize it. If it doesn't, we'll look for an entry in var/list/cerulean_tail_palette
 *	If that doesn't, we'll generate a basic modsuit icon for the Cerulean.
 */
/obj/item/clothing/suit/mod/proc/handle_cerulean_modsuit(icon/base_icon, key, greyscale_colors, physique)
	/// our full icon state string, lets find a pre-drawn modsuit!
	var/icon_state_string = "[physique == "f" ? "f-" : ""][icon_state]"
	if(icon_exists(CERULEAN_MODSUIT_FILE, icon_state_string))
		// we have a pre-drawn modsuit, yay
		return icon(CERULEAN_MODSUIT_FILE, icon_state_string)

	/// whether the modsuit is sealed or open, we read this from our lovely key
	var/sealed = findtext(icon_state, "sealed") ? TRUE : FALSE
	/// find out what modsuit theme this mod has
	var/datum/mod_theme/theme = find_mod_theme(key)
	/// lets cut away the legs first, we really don't need them
	var/icon/cerulean_mod_icon = apply_icon_mask(base_icon, LEGS_MASK)
	// lets run through generating according to what our variables are set to
	if(!isnull(theme?.cerulean_tail_palette))
		// add a colored icon for each modular part, according to the theme fetched
		var/list/modular_part_list = theme.cerulean_tail_palette.Copy()
		for(var/index in 1 to length(modular_part_list))
			cerulean_mod_icon.Blend(
				icon(
					SSgreyscale.GetColoredIconByType(
						/datum/greyscale_config/modular_mod_parts_cerulean,
						modular_part_list[modular_part_list[index]],
					),
					"[modular_part_list[index]][sealed ? "-sealed" : ""]",
				),
				ICON_OVERLAY,
			)
	else
		// we have no drawn sprite and no entry in the preset combinations alist. one little neglected modsuit :(
		// lets generate from our broadstroke preset
		cerulean_mod_icon.Blend(
			icon(
				SSgreyscale.GetColoredIconByType(
					/datum/greyscale_config/modular_mod_parts_cerulean/basic,
					greyscale_colors,
				),
				"undefined[sealed ? "-sealed" : ""]",
			),
			ICON_OVERLAY,
		)

	if(physique == "f")
		var/flipper_color = greyscale_colors
		if(theme)
			if(theme.cerulean_flipper_palette != FLIPPERS)
				flipper_color = theme.cerulean_flipper_palette
		if(flipper_color != NO_FLIPPERS)
			generate_fem_flippers(cerulean_mod_icon, flipper_color)

	return cerulean_mod_icon

/obj/item/clothing/gloves/mod
	name = "\improper MOD gauntlets"
	desc = "A pair of gauntlets for a MODsuit."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-gauntlets"
	base_icon_state = "gauntlets"
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	armor_type = /datum/armor/none
	body_parts_covered = HANDS|ARMS
	heat_protection = HANDS|ARMS
	cold_protection = HANDS|ARMS
	equip_sound = null
	pickup_sound = null
	drop_sound = null
	item_flags = NONE

/obj/item/clothing/gloves/mod/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_SPEED_POTION, INNATE_TRAIT)

/obj/item/clothing/shoes/mod
	name = "\improper MOD boots"
	desc = "A pair of boots for a MODsuit."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-boots"
	base_icon_state = "boots"
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	armor_type = /datum/armor/none
	body_parts_covered = FEET|LEGS
	heat_protection = FEET|LEGS
	cold_protection = FEET|LEGS
	item_flags = IGNORE_DIGITIGRADE
	fastening_type = SHOES_SLIPON
	equip_sound = null

/obj/item/clothing/shoes/mod/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_SPEED_POTION, INNATE_TRAIT)

/obj/item/clothing/shoes/mod/proc/update_footstep_sounds()
	switch(slowdown)
		if(0.3 to INFINITY)
			AddComponent(/datum/component/shoe_footstep, list('sound/items/modsuit/rigstep_chonk.ogg'), volume = 50)
		if(0.2 to 0.3)
			AddComponent(/datum/component/shoe_footstep, list('sound/items/modsuit/rigstep_heavy.ogg'), volume = 50)
		if(0.1 to 0.2)
			AddComponent(/datum/component/shoe_footstep, list('sound/items/modsuit/rigstep_medium.ogg'), volume = 50)
		if(-INFINITY to 0.1)
			AddComponent(/datum/component/shoe_footstep, list('sound/items/modsuit/rigstep.ogg'), volume = 50)

/obj/item/clothing/glasses/mod
	name = "\improper MOD glasses"
	desc = "A pair of glasses for a MODsuit."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-glasses"
	base_icon_state = "glasses"
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	armor_type = /datum/armor/none
	equip_sound = null
	pickup_sound = null
	drop_sound = null

/obj/item/clothing/glasses/mod/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_SPEED_POTION, INNATE_TRAIT)

/obj/item/clothing/neck/mod
	name = "\improper MOD tie"
	desc = "An tie for a MODsuit."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-tie"
	base_icon_state = "tie"
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	armor_type = /datum/armor/none
	equip_sound = null
	pickup_sound = null
	drop_sound = null
	item_flags = NONE

/obj/item/clothing/neck/mod/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_SPEED_POTION, INNATE_TRAIT)
