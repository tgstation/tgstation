#define DEFAULT_HEIGHT "Average"

/datum/preference/choiced/mob_height
	savefile_key = "character_height"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	can_randomize = FALSE
	var/list/height_to_actual = list(
		// "Shortest" = HUMAN_HEIGHT_SHORTEST, // Reserved for Settler
		"Short" = HUMAN_HEIGHT_SHORT,
		DEFAULT_HEIGHT = HUMAN_HEIGHT_MEDIUM,
		"Tall" = HUMAN_HEIGHT_TALL,
		// "Taller" = HUMAN_HEIGHT_TALLER, // Reserved for Spacer
		// "Tallest" = HUMAN_HEIGHT_TALLEST, // Reserved for Spacer
	)

/datum/preference/choiced/mob_height/init_possible_values()
	return assoc_to_keys(height_to_actual)

/datum/preference/choiced/mob_height/apply_to_human(mob/living/carbon/human/target, value)
	target.set_mob_height(height_to_actual[value] || DEFAULT_HEIGHT)

/datum/preference/choiced/mob_height/is_accessible(datum/preferences/preferences)
	if(highest_priority_job_is(preferences, list(/datum/job/cyborg, /datum/job/ai)))
		return FALSE
	if(/datum/quirk/settler::name in preferences.all_quirks)
		return FALSE
	if(/datum/quirk/spacer_born::name in preferences.all_quirks)
		return FALSE
	return ..()

/datum/preference/choiced/mob_height/create_default_value(datum/preferences/preferences)
	return DEFAULT_HEIGHT

#undef DEFAULT_HEIGHT
