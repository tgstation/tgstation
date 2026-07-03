
/datum/preference/color/vulpkanin_tail_markings_color
	savefile_key = "vulpkanin_tail_markings_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_organ = /obj/item/organ/tail/vulpkanin

/datum/preference/color/vulpkanin_tail_markings_color/create_default_value()
	return COLOR_WHITE

/datum/preference/color/vulpkanin_tail_markings_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_VULPKANIN_TAIL_MARKINGS_COLOR] = value

/datum/preference/color/vulpkanin_tail_markings_color/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	var/pref = preferences.read_preference(/datum/preference/choiced/species_feature/tail_vulpkanin)
	return (pref == "Default" || pref == "Bushy" || pref == "Straight Bushy") && preferences.read_preference(/datum/preference/choiced/species_feature/vulpkanin_tail_markings) != SPRITE_ACCESSORY_NONE
