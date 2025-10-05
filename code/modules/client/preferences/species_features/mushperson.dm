/datum/preference/choiced/mushroom_cap
	savefile_key = "feature_mushperson_cap"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/mushroom_cap

/datum/preference/choiced/mushroom_cap/init_possible_values()
	return assoc_to_keys_features(SSaccessories.caps_list)

/datum/preference/choiced/mushroom_cap/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_MUSH_CAP] = value
