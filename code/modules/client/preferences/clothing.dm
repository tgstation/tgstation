/proc/generate_values_for_underwear(list/accessory_list, list/icons, color)
	var/icon/lower_half = icon('icons/blanks/32x32.dmi', "nothing")

	for (var/icon in icons)
		lower_half.Blend(icon('icons/mob/species/human/bodyparts_greyscale.dmi', icon), ICON_OVERLAY)

	var/list/values = list()

	for (var/accessory_name in accessory_list)
		var/icon/icon_with_socks = new(lower_half)

		if (accessory_name != "Nude")
			var/datum/sprite_accessory/accessory = accessory_list[accessory_name]

			var/icon/accessory_icon = icon('icons/mob/clothing/underwear.dmi', accessory.icon_state)
			if (color && !accessory.use_static)
				accessory_icon.Blend(color, ICON_MULTIPLY)
			icon_with_socks.Blend(accessory_icon, ICON_OVERLAY)

		icon_with_socks.Crop(10, 1, 22, 13)
		icon_with_socks.Scale(32, 32)

		values[accessory_name] = icon_with_socks

	return values

/// Backpack preference
/datum/preference/choiced/backpack
	savefile_key = "backpack"
	savefile_identifier = PREFERENCE_CHARACTER
	main_feature_name = "Backpack"
	category = PREFERENCE_CATEGORY_CLOTHING
	should_generate_icons = TRUE

/datum/preference/choiced/backpack/init_possible_values()
	var/list/values = list()

	values[GBACKPACK] = /obj/item/storage/backpack
	values[GSATCHEL] = /obj/item/storage/backpack/satchel
	values[LSATCHEL] = /obj/item/storage/backpack/satchel/leather
	values[GDUFFELBAG] = /obj/item/storage/backpack/duffelbag

	// In a perfect world, these would be your department's backpack.
	// However, this doesn't factor in assistants, or no high slot, and would
	// also increase the spritesheet size a lot.
	// I play medical doctor, and so medical doctor you get.
	values[DBACKPACK] = /obj/item/storage/backpack/medic
	values[DSATCHEL] = /obj/item/storage/backpack/satchel/med
	values[DDUFFELBAG] = /obj/item/storage/backpack/duffelbag/med

	return values

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
	var/list/values = list()

	values[PREF_SUIT] = /obj/item/clothing/under/color/grey
	values[PREF_SKIRT] = /obj/item/clothing/under/color/jumpskirt/grey

	return values

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
	return generate_values_for_underwear(GLOB.socks_list, list("human_r_leg", "human_l_leg"))

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
	var/icon/body = icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_r_leg")
	body.Blend(icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_l_leg"), ICON_OVERLAY)
	body.Blend(icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_r_arm"), ICON_OVERLAY)
	body.Blend(icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_l_arm"), ICON_OVERLAY)
	body.Blend(icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_r_hand"), ICON_OVERLAY)
	body.Blend(icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_l_hand"), ICON_OVERLAY)
	body.Blend(icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_chest_m"), ICON_OVERLAY)

	var/list/values = list()

	for (var/accessory_name in GLOB.undershirt_list)
		var/icon/icon_with_undershirt = icon(body)

		if (accessory_name != "Nude")
			var/datum/sprite_accessory/accessory = GLOB.undershirt_list[accessory_name]
			icon_with_undershirt.Blend(icon('icons/mob/clothing/underwear.dmi', accessory.icon_state), ICON_OVERLAY)

		icon_with_undershirt.Crop(9, 9, 23, 23)
		icon_with_undershirt.Scale(32, 32)
		values[accessory_name] = icon_with_undershirt

	return values

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
	return generate_values_for_underwear(GLOB.underwear_list, list("human_chest_m", "human_r_leg", "human_l_leg"), COLOR_ALMOST_BLACK)

/datum/preference/choiced/underwear/apply_to_human(mob/living/carbon/human/target, value)
	target.underwear = value

/datum/preference/choiced/underwear/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	var/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type
	return !(NO_UNDERWEAR in species.species_traits)

/datum/preference/choiced/underwear/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "underwear_color"

	return data
