/datum/preference/choiced/lizard_tail
	savefile_key = "feature_lizard_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	should_generate_icons = TRUE

/datum/preference/choiced/lizard_tail/init_possible_values()
	var/list/icon/values = possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.tails_list_lizard,
		"tail",
		list("BEHIND"),
	)

	for (var/name in values)
		var/icon/icon = values[name]

		// Lizard tails end at (19, 12), so shift into the center
		icon.Shift(EAST, CEILING((32 - 19) / 2, 1))
		icon.Shift(NORTH, CEILING((32 - 12) / 2, 1))
		icon.Scale(48, 48)
		icon.Crop(1, 1, 32, 32)

		icon.Blend(COLOR_VIBRANT_LIME, BLEND_MULTIPLY)

	return values

/datum/preference/choiced/lizard_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_lizard"] = value
