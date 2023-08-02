/proc/generate_avalari_side_shots(list/sprite_accessories, key, include_snout = TRUE)
	var/list/values = list()

	var/icon/lizard = icon('modular_skyraptor/modules/species_teshvali/icons/bodyparts.dmi', "avalari_head", EAST)
	var/icon/eyes = icon('modular_skyraptor/modules/species_teshvali/icons/avalari_external.dmi', "avalarieyes", EAST)
	eyes.Blend(COLOR_GRAY, ICON_MULTIPLY)
	lizard.Blend(eyes, ICON_OVERLAY)

	if (include_snout)
		lizard.Blend(icon('modular_skyraptor/modules/species_teshvali/icons/avalari_external.dmi', "m_snout_avalari_standard_ADJ", EAST), ICON_OVERLAY)

	for (var/name in sprite_accessories)
		var/datum/sprite_accessory/sprite_accessory = sprite_accessories[name]

		var/icon/final_icon = icon(lizard)

		if (sprite_accessory.icon_state != "none")
			var/icon/accessory_icon = icon(sprite_accessory.icon, "m_[key]_[sprite_accessory.icon_state]_ADJ", EAST)
			final_icon.Blend(accessory_icon, ICON_OVERLAY)

		final_icon.Crop(10, 16, 22, 28)
		final_icon.Scale(32, 32)
		final_icon.Blend(COLOR_WHITE, ICON_MULTIPLY)

		values[name] = final_icon

	return values






//== SNOUT
/datum/preference/choiced/avalari_snout
	savefile_key = "feature_avalari_snout"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Snout"
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/external/snout/avalari

/datum/preference/choiced/avalari_snout/init_possible_values()
	return generate_avalari_side_shots(GLOB.snouts_list_avalari, "snout_avalari", include_snout = TRUE)

/datum/preference/choiced/avalari_snout/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["snout_avalari"] = value

/datum/preference/choiced/avalari_snout/create_default_value()
	var/datum/sprite_accessory/snouts/avalari/standard/snout = /datum/sprite_accessory/snouts/avalari/standard
	return initial(snout.name)

//== HORNS
/datum/preference/choiced/avalari_horns
	savefile_key = "feature_avalari_horns"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Horns"
	should_generate_icons = TRUE
	relevant_external_organ = /obj/item/organ/external/horns/avalari

/datum/preference/choiced/avalari_horns/init_possible_values()
	return generate_avalari_side_shots(GLOB.horns_list_avalari, "horns_avalari", include_snout = TRUE)

/datum/preference/choiced/avalari_horns/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["horns_avalari"] = value

/datum/preference/choiced/avalari_horns/create_default_value()
	var/datum/sprite_accessory/horns/avalari/mane/horns = /datum/sprite_accessory/horns/avalari/mane
	return initial(horns.name)

/datum/preference/choiced/avalari_horns/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "horns_color"

	return data



//== TAIL
/datum/preference/choiced/avalari_tail
	savefile_key = "feature_avalari_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/external/tail/avalari
	main_feature_name = "Tail"
	should_generate_icons = FALSE

/datum/preference/choiced/avalari_tail/init_possible_values()
	return assoc_to_keys_features(GLOB.tails_list_avalari)

/datum/preference/choiced/avalari_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_avalari"] = value

/datum/preference/choiced/avalari_tail/create_default_value()
	var/datum/sprite_accessory/tails/avalari/fluffy/tail = /datum/sprite_accessory/tails/avalari/fluffy
	return initial(tail.name)



//== BODY MARKINGS
/datum/preference/choiced/avalari_body_markings
	savefile_key = "feature_avalari_body_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Body markings"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "bodymarks_avalari"

/datum/preference/choiced/avalari_body_markings/init_possible_values()
	var/list/values = list()

	var/icon/lizard = icon('modular_skyraptor/modules/species_teshvali/icons/bodyparts.dmi', "avalari_chest_m")

	for (var/name in GLOB.bodymarks_list_avalari)
		var/datum/sprite_accessory/sprite_accessory = GLOB.bodymarks_list_avalari[name]

		var/icon/final_icon = icon(lizard)

		if (sprite_accessory.icon_state != "none")
			var/icon/body_markings_icon = icon(
				'modular_skyraptor/modules/species_teshvali/icons/avalari_external.dmi',
				"m_bodymarks_avalari_[sprite_accessory.icon_state]_ADJ",
			)

			final_icon.Blend(body_markings_icon, ICON_OVERLAY)

		final_icon.Blend(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
		final_icon.Crop(10, 8, 22, 23)
		final_icon.Scale(26, 32)
		final_icon.Crop(-2, 1, 29, 32)

		values[name] = final_icon

	return values

/datum/preference/choiced/avalari_body_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["bodymarks_avalari"] = value
