/datum/preference/choiced/lizard_tail
	savefile_key = "feature_lizard_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/choiced/lizard_tail/init_possible_values()
	return assoc_to_keys(GLOB.tails_list_lizard)

/datum/preference/choiced/lizard_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_lizard"] = value

/datum/preference/choiced/lizard_spines
	savefile_key = "feature_lizard_spines"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/choiced/lizard_spines/init_possible_values()
	return assoc_to_keys(GLOB.spines_list)

/datum/preference/choiced/lizard_spines/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["spines"] = value
