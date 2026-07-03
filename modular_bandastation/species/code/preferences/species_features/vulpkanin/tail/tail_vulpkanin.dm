/datum/preference/choiced/species_feature/tail_vulpkanin
	savefile_key = "feature_vulpkanin_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_organ = /obj/item/organ/tail/vulpkanin

/datum/preference/choiced/species_feature/tail_vulpkanin/get_accessory_list()
	return SSaccessories.feature_list[FEATURE_VULPKANIN_TAIL]

/datum/preference/choiced/species_feature/tail_vulpkanin/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_VULPKANIN_TAIL] = value
