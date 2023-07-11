/proc/generate_slugcat_side_shots(list/sprite_accessories, key, include_snout = TRUE)
	var/list/values = list()

	var/icon/lizard = icon('modular_skyraptor/modules/species_slugcat/icons/bodyparts.dmi', "slugcat_head", EAST)
	var/icon/eyes = icon('modular_skyraptor/modules/species_slugcat/icons/slugcat_external.dmi', "scugeyes", EAST)
	eyes.Blend(COLOR_GRAY, ICON_MULTIPLY)
	lizard.Blend(eyes, ICON_OVERLAY)

	if (include_snout)
		lizard.Blend(icon('modular_skyraptor/modules/species_slugcat/icons/slugcat_external.dmi', "m_snout_scug_standard_ADJ", EAST), ICON_OVERLAY)

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
/datum/preference/choiced/slugcat_snout
	savefile_key = "feature_slugcat_snout"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Snout"
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/external/snout/slugcat

/datum/preference/choiced/slugcat_snout/init_possible_values()
	return generate_slugcat_side_shots(GLOB.snouts_list_slugcat, "snout_scug", include_snout = TRUE)

/datum/preference/choiced/slugcat_snout/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["snout_scug"] = value

/datum/preference/choiced/slugcat_snout/create_default_value()
	var/datum/sprite_accessory/snouts/slugcat/standard/snout = /datum/sprite_accessory/snouts/slugcat/standard
	return initial(snout.name)

//== HORNS
/datum/preference/choiced/slugcat_horns
	savefile_key = "feature_slugcat_horns"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Horns"
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/external/horns/slugcat

/datum/preference/choiced/slugcat_horns/init_possible_values()
	return generate_slugcat_side_shots(GLOB.horns_list_slugcat, "horns_scug", include_snout = TRUE)

/datum/preference/choiced/slugcat_horns/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["horns_scug"] = value

/datum/preference/choiced/slugcat_horns/create_default_value()
	var/datum/sprite_accessory/horns/slugcat/standard/horns = /datum/sprite_accessory/horns/slugcat/standard
	return initial(horns.name)

/datum/preference/choiced/slugcat_horns/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "horns_color"

	return data



//== TAIL
/datum/preference/choiced/slugcat_tail
	savefile_key = "feature_slugcat_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/external/tail/slugcat
	main_feature_name = "Tail"
	should_generate_icons = FALSE

/datum/preference/choiced/slugcat_tail/init_possible_values()
	return assoc_to_keys_features(GLOB.tails_list_slugcat)

/datum/preference/choiced/slugcat_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_scug"] = value

/datum/preference/choiced/slugcat_tail/create_default_value()
	var/datum/sprite_accessory/tails/slugcat/standard/tail = /datum/sprite_accessory/tails/slugcat/standard
	return initial(tail.name)



//== FRILLS
/datum/preference/choiced/slugcat_frills
	savefile_key = "feature_slugcat_frills"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Frills"
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/external/frills/slugcat

/datum/preference/choiced/slugcat_frills/init_possible_values()
	return generate_slugcat_side_shots(GLOB.frills_list_slugcat, "frills_scug", include_snout = TRUE)

/datum/preference/choiced/slugcat_frills/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["frills_scug"] = value

/datum/preference/choiced/slugcat_frills/create_default_value()
	var/datum/sprite_accessory/frills/slugcat/none/frills = /datum/sprite_accessory/frills/slugcat/none
	return initial(frills.name)

/datum/preference/choiced/slugcat_frills/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "frills_color"

	return data



//== EARS
/*/datum/preference/choiced/slugcat_ears
	savefile_key = "feature_human_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	can_randomize = TRUE
	relevant_mutant_bodypart = "ears"

/datum/preference/choiced/slugcat_ears/init_possible_values()
	return assoc_to_keys_features(GLOB.slugcat_ears_list)

/datum/preference/choiced/slugcat_ears/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["ears"] = value

/datum/preference/choiced/slugcat_ears/create_default_value()
	var/datum/sprite_accessory/ears/slugcat/ears = /datum/sprite_accessory/ears/slugcat/perky
	return initial(ears.name)*/





//== BODY MARKINGS
/datum/preference/choiced/slugcat_body_markings
	savefile_key = "feature_slugcat_body_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Body markings"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "bodymarks_scug"

/datum/preference/choiced/slugcat_body_markings/init_possible_values()
	var/list/values = list()

	var/icon/lizard = icon('modular_skyraptor/modules/species_slugcat/icons/bodyparts.dmi', "slugcat_chest_m")

	for (var/name in GLOB.bodymarks_list_slugcat)
		var/datum/sprite_accessory/sprite_accessory = GLOB.bodymarks_list_slugcat[name]

		var/icon/final_icon = icon(lizard)

		if (sprite_accessory.icon_state != "none")
			var/icon/body_markings_icon = icon(
				'modular_skyraptor/modules/species_slugcat/icons/slugcat_external.dmi',
				"m_bodymarks_scug_[sprite_accessory.icon_state]_ADJ",
			)

			final_icon.Blend(body_markings_icon, ICON_OVERLAY)

		final_icon.Blend(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
		final_icon.Crop(10, 8, 22, 23)
		final_icon.Scale(26, 32)
		final_icon.Crop(-2, 1, 29, 32)

		values[name] = final_icon

	return values

/datum/preference/choiced/slugcat_body_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["bodymarks_scug"] = value
