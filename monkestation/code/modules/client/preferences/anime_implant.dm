
/datum/preference/color/anime_color
	savefile_key = "feature_animecolor"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL

/datum/preference/color/anime_color/create_default_value()
	return sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]")

/datum/preference/color/anime_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["animecolor"] = value

/datum/preference/color/anime_color/is_valid(value)
	if (!..(value))
		return FALSE
	return TRUE

/datum/preference/choiced/anime_top
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "feature_anime_top"

/datum/preference/choiced/anime_top/init_possible_values()
	return GLOB.anime_top_list

/datum/preference/choiced/anime_top/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["anime_top"] = value

/datum/preference/choiced/anime_middle
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "feature_anime_middle"

/datum/preference/choiced/anime_middle/init_possible_values()
	return GLOB.anime_middle_list

/datum/preference/choiced/anime_middle/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["anime_middle"] = value

/datum/preference/choiced/anime_bottom
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "feature_anime_bottom"

/datum/preference/choiced/anime_bottom/init_possible_values()
	return GLOB.anime_bottom_list

/datum/preference/choiced/anime_bottom/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["anime_bottom"] = value
