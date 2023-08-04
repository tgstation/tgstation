/datum/preference/choiced/arachnid_appendages
	savefile_key = "feature_arachnid_appendages"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Arachnid Appendages"
	should_generate_icons = TRUE

/datum/preference/choiced/arachnid_appendages/init_possible_values()
	return possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.arachnid_appendages_list,
		"arachnidappendages",
		list("BEHIND", "FRONT"),
	)

/datum/preference/choiced/arachnid_appendages/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["moth_wings"] = value
