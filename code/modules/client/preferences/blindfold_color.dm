/// Preference for the roundstart color of the blindfold given by the Blindness quirk.
/datum/preference/color/blindfold_color
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "blindfold_color"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/color/blindfold_color/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return /datum/quirk/item_quirk/blindness::name in preferences.all_quirks

/datum/preference/color/blindfold_color/apply_to_human(mob/living/carbon/human/target, value)
	return
