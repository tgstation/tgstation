/datum/preference/choiced/pod_hair
	savefile_key = "feature_pod_hair"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Hairstyle"
	should_generate_icons = FALSE

/datum/preference/choiced/pod_hair/init_possible_values()
	return GLOB.pod_hair_list

/datum/preference/choiced/pod_hair/create_default_value()
	return pick(GLOB.pod_hair_list)

/datum/preference/choiced/pod_hair/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["pod_hair"] = value
