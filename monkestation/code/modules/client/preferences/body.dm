/datum/preference/choiced/body_height
	savefile_key = "body_height"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/choiced/body_height/init_possible_values()
	return assoc_to_keys(GLOB.body_heights)

/datum/preference/choiced/body_height/create_default_value()
	return "Normal"

/datum/preference/choiced/body_height/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.body_height = value
