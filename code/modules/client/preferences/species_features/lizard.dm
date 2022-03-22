/proc/generate_lizard_side_shots(list/sprite_accessories, key, include_snout = TRUE)
	var/list/values = list()

	var/icon/lizard = icon('icons/mob/human_parts_greyscale.dmi', "lizard_head_m", EAST)

	var/icon/eyes = icon('icons/mob/human_face.dmi', "eyes", EAST)
	eyes.Blend(COLOR_GRAY, ICON_MULTIPLY)
	lizard.Blend(eyes, ICON_OVERLAY)

	if (include_snout)
		lizard.Blend(icon('icons/mob/mutant_bodyparts.dmi', "m_snout_round_ADJ", EAST), ICON_OVERLAY)

	for (var/name in sprite_accessories)
		var/datum/sprite_accessory/sprite_accessory = sprite_accessories[name]

		var/icon/final_icon = icon(lizard)

		if (sprite_accessory.icon_state != "none")
			var/icon/accessory_icon = icon(sprite_accessory.icon, "m_[key]_[sprite_accessory.icon_state]_ADJ", EAST)
			final_icon.Blend(accessory_icon, ICON_OVERLAY)

		final_icon.Crop(11, 20, 23, 32)
		final_icon.Scale(32, 32)
		final_icon.Blend(COLOR_VIBRANT_LIME, ICON_MULTIPLY)

		values[name] = final_icon

	return values

/datum/preference/choiced/lizard_body_markings
	savefile_key = "feature_lizard_body_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Body markings"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "body_markings"

/datum/preference/choiced/lizard_body_markings/init_possible_values()
	var/list/values = list()

	var/icon/lizard = icon('icons/mob/human_parts_greyscale.dmi', "lizard_chest_m")

	for (var/name in GLOB.body_markings_list)
		var/datum/sprite_accessory/sprite_accessory = GLOB.body_markings_list[name]

		var/icon/final_icon = icon(lizard)

		if (sprite_accessory.icon_state != "none")
			var/icon/body_markings_icon = icon(
				'icons/mob/mutant_bodyparts.dmi',
				"m_body_markings_[sprite_accessory.icon_state]_ADJ",
			)

			final_icon.Blend(body_markings_icon, ICON_OVERLAY)

		final_icon.Blend(COLOR_VIBRANT_LIME, ICON_MULTIPLY)
		final_icon.Crop(10, 8, 22, 23)
		final_icon.Scale(26, 32)
		final_icon.Crop(-2, 1, 29, 32)

		values[name] = final_icon

	return values

/datum/preference/choiced/lizard_body_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["body_markings"] = value

/datum/preference/choiced/lizard_frills
	savefile_key = "feature_lizard_frills"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Frills"
	should_generate_icons = TRUE

/datum/preference/choiced/lizard_frills/init_possible_values()
	return generate_lizard_side_shots(GLOB.frills_list, "frills")

/datum/preference/choiced/lizard_frills/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["frills"] = value

/datum/preference/choiced/lizard_horns
	savefile_key = "feature_lizard_horns"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Horns"
	should_generate_icons = TRUE

/datum/preference/choiced/lizard_horns/init_possible_values()
	return generate_lizard_side_shots(GLOB.horns_list, "horns")

/datum/preference/choiced/lizard_horns/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["horns"] = value

/datum/preference/choiced/lizard_legs
	savefile_key = "feature_lizard_legs"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "legs"

/datum/preference/choiced/lizard_legs/init_possible_values()
	return assoc_to_keys(GLOB.legs_list)

/datum/preference/choiced/lizard_legs/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["legs"] = value

/datum/preference/choiced/lizard_snout
	savefile_key = "feature_lizard_snout"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Snout"
	should_generate_icons = TRUE

/datum/preference/choiced/lizard_snout/init_possible_values()
	return generate_lizard_side_shots(GLOB.snouts_list, "snout", include_snout = FALSE)

/datum/preference/choiced/lizard_snout/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["snout"] = value

/datum/preference/choiced/lizard_spines
	savefile_key = "feature_lizard_spines"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "spines"

/datum/preference/choiced/lizard_spines/init_possible_values()
	return assoc_to_keys(GLOB.spines_list)

/datum/preference/choiced/lizard_spines/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["spines"] = value

/datum/preference/choiced/lizard_tail
	savefile_key = "feature_lizard_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_mutant_bodypart = "tail_lizard"

/datum/preference/choiced/lizard_tail/init_possible_values()
	return assoc_to_keys(GLOB.tails_list_lizard)

/datum/preference/choiced/lizard_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_lizard"] = value
