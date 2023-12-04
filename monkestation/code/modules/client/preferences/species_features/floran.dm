/datum/preference/choiced/floran_leaves
	savefile_key = "feature_floran_leaves"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Floran Leaves"
	should_generate_icons = TRUE

/datum/preference/choiced/floran_leaves/init_possible_values()
	return possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.floran_leaves_list,
		"floran_leaves",
		list("ADJ"),
	)

/datum/preference/choiced/floran_leaves/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["floran_leaves"] = value
