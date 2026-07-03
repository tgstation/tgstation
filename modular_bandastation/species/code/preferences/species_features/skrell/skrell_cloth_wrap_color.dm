/datum/preference/color/skrell_cloth_wrap_color
	savefile_key = "skrell_cloth_wrap_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_organ = /obj/item/organ/cloth_wrap

/datum/preference/color/skrell_cloth_wrap_color/create_default_value()
	return COLOR_WHITE

/datum/preference/color/skrell_cloth_wrap_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_SKRELL_CLOTH_WRAP_COLOR] = value

/datum/preference/color/skrell_cloth_wrap_color/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE
	var/pref = preferences.read_preference(/datum/preference/choiced/species_feature/skrell_cloth_wrap_toggle) // reads the value of cloth_wrap_toggle because the regular cloth_wrap depends on head_tentacles, not the choice in prefs
	return pref == /datum/sprite_accessory/skrell_cloth_wrap_toggle/on::name
