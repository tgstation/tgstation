/datum/preference/choiced/arachnid_appendages
	savefile_key = "feature_arachnid_appendages"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Arachnid Appendages"
	should_generate_icons = TRUE

/datum/preference/choiced/arachnid_appendages/init_possible_values()
	return possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.arachnid_appendages_list,
		"arachnid_appendages",
		list("BEHIND", "FRONT"),
	)

/datum/preference/choiced/arachnid_appendages/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["arachnid_appendages"] = value

/datum/preference/choiced/arachnid_chelicerae
	savefile_key = "feature_arachnid_chelicerae"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Arachnid Chelicerae"
	should_generate_icons = TRUE

/datum/preference/choiced/arachnid_chelicerae/init_possible_values()
	return possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.arachnid_chelicerae_list,
		"arachnid_chelicerae",
		list("BEHIND", "FRONT"),
	)

/datum/preference/choiced/arachnid_chelicerae/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["arachnid_chelicerae"] = value
