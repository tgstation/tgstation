/datum/preference/choiced/fox_ears
	savefile_key = "feature_fox_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	can_randomize = FALSE
	relevant_external_organ = /obj/item/organ/ears/fox

/datum/preference/choiced/fox_ears/init_possible_values()
	return assoc_to_keys_features(SSaccessories.ears_list_fox)

/datum/preference/choiced/fox_ears/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_EARS_FOX] = value

/datum/preference/choiced/fox_ears/create_default_value()
	return /datum/sprite_accessory/ears_fox/default::name
