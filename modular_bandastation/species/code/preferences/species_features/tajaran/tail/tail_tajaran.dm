/datum/preference/choiced/species_feature/tail_tajaran
	savefile_key = "feature_tajaran_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_organ = /obj/item/organ/tail/tajaran

/datum/preference/choiced/species_feature/tail_tajaran/get_accessory_list()
	return SSaccessories.feature_list[FEATURE_TAJARAN_TAIL]

/datum/preference/choiced/species_feature/tail_tajaran/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_tajaran"] = value
