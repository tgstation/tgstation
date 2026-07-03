/datum/preference/color/tajaran_body_markings_color
	priority = PREFERENCE_PRIORITY_BODYPARTS
	savefile_key = "tajaran_body_markings_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_body_markings = /datum/bodypart_overlay/simple/body_marking/tajaran_chest

/datum/preference/color/tajaran_body_markings_color/create_default_value()
	return COLOR_WHITE

/datum/preference/color/tajaran_body_markings_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_TAJARAN_BODY_MARKINGS_COLOR] = value
