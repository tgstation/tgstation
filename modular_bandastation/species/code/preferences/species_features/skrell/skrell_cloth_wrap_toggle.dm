// This is a crutch for correct synchronization between cloth_wrap and head_tentacles, needed for correct button display in TGUI character setup
/datum/preference/choiced/species_feature/skrell_cloth_wrap_toggle
	savefile_key = "feature_skrell_cloth_wrap_toggle"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_organ = /obj/item/organ/cloth_wrap

/datum/preference/choiced/species_feature/skrell_cloth_wrap_toggle/get_accessory_list()
	return SSaccessories.feature_list[FEATURE_SKRELL_CLOTH_WRAP_TOGGLE]

/datum/preference/choiced/species_feature/skrell_cloth_wrap_toggle/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_SKRELL_CLOTH_WRAP_TOGGLE] = value
