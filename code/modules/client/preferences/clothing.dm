/proc/generate_underwear_icon(datum/sprite_accessory/accessory, icon/base_icon, color)
	var/icon/final_icon = new(base_icon)

	if (!isnull(accessory))
		var/icon/accessory_icon = icon('icons/mob/clothing/underwear.dmi', accessory.icon_state)
		if (color && !accessory.use_static)
			accessory_icon.Blend(color, ICON_MULTIPLY)
		final_icon.Blend(accessory_icon, ICON_OVERLAY)

	final_icon.Crop(10, 1, 22, 13)
	final_icon.Scale(32, 32)

	return final_icon

/// Backpack preference
/datum/preference/choiced/backpack
	savefile_key = "backpack"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Backpack"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE

/datum/preference/choiced/backpack/init_possible_values()
	return list(
		GBACKPACK,
		GSATCHEL,
		LSATCHEL,
		GDUFFELBAG,
		GMESSENGER,
		DBACKPACK,
		DSATCHEL,
		DDUFFELBAG,
		DMESSENGER,
	)

/datum/preference/choiced/backpack/icon_for(value)
	switch (value)
		if (GBACKPACK)
			return /obj/item/storage/backpack
		if (GSATCHEL)
			return /obj/item/storage/backpack/satchel
		if (LSATCHEL)
			return /obj/item/storage/backpack/satchel/leather
		if (GDUFFELBAG)
			return /obj/item/storage/backpack/duffelbag
		if (GMESSENGER)
			return /obj/item/storage/backpack/messenger

		// In a perfect world, these would be your department's backpack.
		// However, this doesn't factor in assistants, or no high slot, and would
		// also increase the spritesheet size a lot.
		// I play medical doctor, and so medical doctor you get.
		if (DBACKPACK)
			return /obj/item/storage/backpack/medic
		if (DSATCHEL)
			return /obj/item/storage/backpack/satchel/med
		if (DDUFFELBAG)
			return /obj/item/storage/backpack/duffelbag/med
		if (DMESSENGER)
			return /obj/item/storage/backpack/messenger/med

/datum/preference/choiced/backpack/apply_to_human(mob/living/carbon/human/target, value)
	target.backpack = value

/// Jumpsuit preference
/datum/preference/choiced/jumpsuit
	savefile_key = "jumpsuit_style"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Jumpsuit"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE

/datum/preference/choiced/jumpsuit/init_possible_values()
	return list(
		PREF_SUIT,
		PREF_SKIRT,
	)

/datum/preference/choiced/jumpsuit/icon_for(value)
	switch (value)
		if (PREF_SUIT)
			return /obj/item/clothing/under/color/grey
		if (PREF_SKIRT)
			return /obj/item/clothing/under/color/jumpskirt/grey

/datum/preference/choiced/jumpsuit/apply_to_human(mob/living/carbon/human/target, value)
	target.jumpsuit_style = value

/// Socks preference
/datum/preference/choiced/socks
	savefile_key = "socks"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Socks"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE

/datum/preference/choiced/socks/init_possible_values()
	return assoc_to_keys_features(SSaccessories.socks_list)

/datum/preference/choiced/socks/icon_for(value)
	var/static/icon/lower_half

	if (isnull(lower_half))
		lower_half = icon('icons/blanks/32x32.dmi', "nothing")
		lower_half.Blend(icon('icons/mob/human/bodyparts_greyscale.dmi', "human_r_leg"), ICON_OVERLAY)
		lower_half.Blend(icon('icons/mob/human/bodyparts_greyscale.dmi', "human_l_leg"), ICON_OVERLAY)

	return generate_underwear_icon(SSaccessories.socks_list[value], lower_half)

/datum/preference/choiced/socks/apply_to_human(mob/living/carbon/human/target, value)
	target.socks = value

/// Undershirt preference
/datum/preference/choiced/undershirt
	savefile_key = "undershirt"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Undershirt"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE

/datum/preference/choiced/undershirt/init_possible_values()
	return assoc_to_keys_features(SSaccessories.undershirt_list)

/datum/preference/choiced/undershirt/icon_for(value)
	var/static/icon/body
	if (isnull(body))
		body = icon('icons/mob/human/bodyparts_greyscale.dmi', "human_r_leg")
		body.Blend(icon('icons/mob/human/bodyparts_greyscale.dmi', "human_l_leg"), ICON_OVERLAY)
		body.Blend(icon('icons/mob/human/bodyparts_greyscale.dmi', "human_r_arm"), ICON_OVERLAY)
		body.Blend(icon('icons/mob/human/bodyparts_greyscale.dmi', "human_l_arm"), ICON_OVERLAY)
		body.Blend(icon('icons/mob/human/bodyparts_greyscale.dmi', "human_r_hand"), ICON_OVERLAY)
		body.Blend(icon('icons/mob/human/bodyparts_greyscale.dmi', "human_l_hand"), ICON_OVERLAY)
		body.Blend(icon('icons/mob/human/bodyparts_greyscale.dmi', "human_chest_m"), ICON_OVERLAY)

	var/icon/icon_with_undershirt = icon(body)

	if (value != "Nude")
		var/datum/sprite_accessory/accessory = SSaccessories.undershirt_list[value]
		icon_with_undershirt.Blend(icon('icons/mob/clothing/underwear.dmi', accessory.icon_state), ICON_OVERLAY)

	icon_with_undershirt.Crop(9, 9, 23, 23)
	icon_with_undershirt.Scale(32, 32)
	return icon_with_undershirt

/datum/preference/choiced/undershirt/apply_to_human(mob/living/carbon/human/target, value)
	target.undershirt = value

/// Underwear preference
/datum/preference/choiced/underwear
	savefile_key = "underwear"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Underwear"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE

/datum/preference/choiced/underwear/init_possible_values()
	return assoc_to_keys_features(SSaccessories.underwear_list)

/datum/preference/choiced/underwear/icon_for(value)
	var/static/icon/lower_half

	if (isnull(lower_half))
		lower_half = icon('icons/blanks/32x32.dmi', "nothing")
		lower_half.Blend(icon('icons/mob/human/bodyparts_greyscale.dmi', "human_chest_m"), ICON_OVERLAY)
		lower_half.Blend(icon('icons/mob/human/bodyparts_greyscale.dmi', "human_r_leg"), ICON_OVERLAY)
		lower_half.Blend(icon('icons/mob/human/bodyparts_greyscale.dmi', "human_l_leg"), ICON_OVERLAY)

	return generate_underwear_icon(SSaccessories.underwear_list[value], lower_half, COLOR_ALMOST_BLACK)

/datum/preference/choiced/underwear/apply_to_human(mob/living/carbon/human/target, value)
	target.underwear = value

/datum/preference/choiced/underwear/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	var/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = GLOB.species_prototypes[species_type]
	return !(TRAIT_NO_UNDERWEAR in species.inherent_traits)

/datum/preference/choiced/underwear/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "underwear_color"

	return data
