/datum/preference/toggle/skin_tone
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "skin_tone_toggle"
	default_value = FALSE

/datum/preference/toggle/skin_tone/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.dna.features["uses_skintones"] = value


