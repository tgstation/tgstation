/datum/preference/choiced/species_feature/skrell_cloth_wrap
	savefile_key = "feature_skrell_cloth_wrap"
	savefile_identifier = PREFERENCE_CHARACTER
	relevant_organ = /obj/item/organ/cloth_wrap

/datum/preference/choiced/species_feature/skrell_cloth_wrap/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = /datum/preference/color/skrell_cloth_wrap_color::savefile_key

	return data
