/datum/preference/choiced/spacer_height
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "spacer_height"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/spacer_height/init_possible_values()
	return assoc_to_keys(GLOB.spacer_height_choices)

/datum/preference/choiced/spacer_height/is_accessible(datum/preferences/preferences)
	return ..() && (/datum/quirk/spacer_born::name in preferences.all_quirks)

/datum/preference/choiced/spacer_height/create_default_value()
	return init_possible_values()[1]

/datum/quirk_constant_data/spacer_height
	associated_typepath = /datum/quirk/spacer_born
	customization_options = list(/datum/preference/choiced/spacer_height)

/datum/preference/choiced/spacer_height/apply_to_human(mob/living/carbon/human/target, value)
	return
