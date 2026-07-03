/datum/preference/choiced/species_feature/skrell_tentacle_ornament
	savefile_key = "feature_skrell_head_tentacle_ornament"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_organ = /obj/item/organ/tentacle_ornament

/datum/preference/choiced/species_feature/skrell_tentacle_ornament/get_accessory_list()
	return SSaccessories.feature_list[FEATURE_SKRELL_HEAD_TENTACLE_ORNAMENT]

/datum/preference/choiced/species_feature/skrell_tentacle_ornament/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_SKRELL_HEAD_TENTACLE_ORNAMENT] = value
