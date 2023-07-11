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
