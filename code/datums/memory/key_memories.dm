/*
 * I am affectionally titling these "key memories"
 *
 * These memories aren't particular special or interesting, but occuply an important role
 * in conveying information to the user about something important they need to check semi-often
 */

/// Your bank account ID, can't get into it without it
/datum/memory/account
	story_value = STORY_VALUE_KEY
	memory_flags = MEMORY_FLAG_NOMOOD|MEMORY_FLAG_NOLOCATION|MEMORY_FLAG_NOPERSISTENCE
	var/remembered_id

/datum/memory/account/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	remembered_id,
)
	src.remembered_id = remembered_id
	return ..()

/datum/memory/account/get_names()
	return list("The bank ID of [protagonist_name], [remembered_id].")

/datum/memory/account/get_starts()
	return list(
		"[protagonist_name] flexing their last brain cells, proudly showing their lucky numbers [remembered_id].",
		"[remembered_id]. The numbers mason, what do they mean!?",
	)

/datum/memory/account/get_moods()
	return list(
		"[protagonist_name] [mood_verb] as they try to keep their drool in.",
		"[protagonist_name] [mood_verb] and runs from their wrangler.",
	)

/// The nuclear bomb code, for nuke ops
/datum/memory/nuke_code
	story_value = STORY_VALUE_KEY
	memory_flags = MEMORY_FLAG_NOMOOD|MEMORY_FLAG_NOLOCATION|MEMORY_FLAG_NOPERSISTENCE
	var/nuclear_code

/datum/memory/nuke_code/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	nuclear_code,
)
	src.nuclear_code = nuclear_code
	return ..()

/datum/memory/nuke_code/get_names()
	return list("[protagonist_name] learns the detonation codes for a nuclear weapon, [nuclear_code].")

/datum/memory/nuke_code/get_starts()
	return list(
		"The number [nuclear_code] written on a sticky note with the words \"FOR SYNDICATE EYES ONLY\" scrawled next to it.",
		"A piece of paper with the number [nuclear_code] being handed to [protagonist_name] from a figure in a blood-red MODsuit.",
	)

/// Tracks what medicines someone with the "allergies" quirk is allergic to
/datum/memory/quirk_allergy
	story_value = STORY_VALUE_KEY
	memory_flags = MEMORY_FLAG_NOMOOD|MEMORY_FLAG_NOLOCATION|MEMORY_FLAG_NOPERSISTENCE
	var/allergy_string

/datum/memory/quirk_allergy/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	allergy_string,
)
	src.allergy_string = allergy_string
	return ..()

/datum/memory/quirk_allergy/get_names()
	return list("The [allergy_string] allergy of [protagonist_name].")

/datum/memory/quirk_allergy/get_starts()
	return list("[protagonist_name] sneezing after coming into contact with [allergy_string].")

/datum/memory/quirk_allergy/get_moods()
	return list("[memorizer] [mood_verb] as they wipe their nose.")

/// Tracks what brand a smoker quirk user likes
/datum/memory/quirk_smoker
	memory_flags = MEMORY_FLAG_NOMOOD|MEMORY_FLAG_NOLOCATION|MEMORY_FLAG_NOPERSISTENCE
	var/preferred_brand

/datum/memory/quirk_smoker/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	preferred_brand,
)
	src.preferred_brand = preferred_brand
	return ..()

/datum/memory/quirk_smoker/get_names()
	return list("[protagonist_name]'s smoking problem.")

/datum/memory/quirk_smoker/get_starts()
	return list(
		"[preferred_brand] cigarettes being plundered by [protagonist_name].",
		"[protagonist_name] buying a box of [preferred_brand] nicotine sticks.",
		"[protagonist_name] fiending for some [preferred_brand] ciggies.",
	)

/datum/memory/quirk_smoker/get_moods()
	return list("[memorizer] [mood_verb] as they light another up.")
