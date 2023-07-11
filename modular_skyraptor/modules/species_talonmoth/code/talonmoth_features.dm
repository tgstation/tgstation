/proc/generate_talonmoth_side_shots(list/sprite_accessories, key, include_snout = TRUE)
	var/list/values = list()

	var/icon/lizard = icon('modular_skyraptor/modules/species_talonmoth/icons/bodyparts.dmi', "talonmoth_head", EAST)
	var/icon/eyes = icon('modular_skyraptor/modules/species_talonmoth/icons/talonmoth_external.dmi', "talonmotheyes", EAST)
	eyes.Blend(COLOR_GRAY, ICON_MULTIPLY)
	lizard.Blend(eyes, ICON_OVERLAY)

	if (include_snout)
		lizard.Blend(icon('modular_skyraptor/modules/species_talonmoth/icons/talonmoth_external.dmi', "m_snout_talonmoth_long_ADJ", EAST), ICON_OVERLAY)

	for (var/name in sprite_accessories)
		var/datum/sprite_accessory/sprite_accessory = sprite_accessories[name]

		var/icon/final_icon = icon(lizard)

		if (sprite_accessory.icon_state != "none")
			var/icon/accessory_icon = icon(sprite_accessory.icon, "m_[key]_[sprite_accessory.icon_state]_ADJ", EAST)
			final_icon.Blend(accessory_icon, ICON_OVERLAY)

		final_icon.Crop(11, 20, 23, 32)
		final_icon.Scale(32, 32)
		final_icon.Blend(COLOR_WHITE, ICON_MULTIPLY)

		values[name] = final_icon

	return values






//== SNOUT
/datum/preference/choiced/talonmoth_snout
	savefile_key = "feature_talonmoth_snout"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Snout"
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/external/snout/talonmoth

/datum/preference/choiced/talonmoth_snout/init_possible_values()
	return generate_talonmoth_side_shots(GLOB.snouts_list_talonmoth, "snout_talonmoth", include_snout = TRUE)

/datum/preference/choiced/talonmoth_snout/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["snout_talonmoth"] = value

/datum/preference/choiced/talonmoth_snout/create_default_value()
	var/datum/sprite_accessory/snouts/talonmoth/long/snout = /datum/sprite_accessory/snouts/talonmoth/long
	return initial(snout.name)






//== BODY MARKINGS
/datum/preference/choiced/talonmoth_body_markings
	savefile_key = "feature_talonmoth_body_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Body markings"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "bodymarks_talonmoth"

/datum/preference/choiced/talonmoth_body_markings/init_possible_values()
	var/list/values = list()

	var/icon/lizard = icon('modular_skyraptor/modules/species_talonmoth/icons/bodyparts.dmi', "talonmoth_chest_m")

	for (var/name in GLOB.bodymarks_list_talonmoth)
		var/datum/sprite_accessory/sprite_accessory = GLOB.bodymarks_list_talonmoth[name]

		var/icon/final_icon = icon(lizard)

		if (sprite_accessory.icon_state != "none")
			var/icon/body_markings_icon = icon(
				'modular_skyraptor/modules/species_talonmoth/icons/talonmoth_external.dmi',
				"m_bodymarks_talonmoth_[sprite_accessory.icon_state]_ADJ",
			)

			final_icon.Blend(body_markings_icon, ICON_OVERLAY)

		final_icon.Blend(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
		final_icon.Crop(10, 8, 22, 23)
		final_icon.Scale(26, 32)
		final_icon.Crop(-2, 1, 29, 32)

		values[name] = final_icon

	return values

/datum/preference/choiced/talonmoth_body_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["bodymarks_talonmoth"] = value
