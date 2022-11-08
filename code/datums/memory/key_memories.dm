/*
 * I am affectionally titling these "key memories"
 *
 * These memories aren't particular special or interesting, but occuply an important role
 * in conveying information to the user about something important they need to check semi-often
 */

/// Your bank account ID, can't get into it without it
/datum/memory/account
	var/remembered_id

/datum/memory/account/New(
	datum/mind/memorizer_mind,
	memorizer,
	atom/protagonist_actual,
	atom/deuteragonist_actual,
	atom/antagonist_actual,
	remembered_id,
)
	src.remembered_id = remembered_id
	return ..()

/datum/memory/account/get_names()
	return list("The bank ID of [protagonist], [remembered_id].")

/datum/memory/account/get_starts()
	return list(
		"[protagonist] flexing their last brain cells, proudly showing their lucky numbers [remembered_id].",
		"[remembered_id]. The numbers mason, what do they mean!?",
	)

/datum/memory/account/get_moods()
	return list(
		"[protagonist] [mood_verb] as they try to keep their drool in.",
		"[protagonist] [mood_verb] and runs from their wrangler.",
	)

/// The nuclear bomb code, for nuke ops
/datum/memory/nuke_code
	memory_flags = MEMORY_FLAG_NOMOOD
	var/nuclear_code

/datum/memory/nuke_code/New(
	datum/mind/memorizer_mind,
	memorizer,
	atom/protagonist_actual,
	atom/deuteragonist_actual,
	atom/antagonist_actual,
	nuclear_code,
)
	src.nuclear_code = nuclear_code
	return ..()

/datum/memory/nuke_code/get_names()
	return list("[protagonist] learns the detonation codes for a nuclear weapon, [nuclear_code].")

/datum/memory/nuke_code/get_starts()
	return list(
		"The number [nuclear_code] written on a sticky note with the words \"FOR SYNDICATE EYES ONLY\" scrawled next to it.",
		"A piece of paper with the number [nuclear_code] being handed to [protagonist] from a figure in a blood-red MODsuit.",
	)

/// Tracks what medicines someone with the "allergies" quirk is allergic to
/datum/memory/quirk_allergy
	var/allergy_string

/datum/memory/quirk_allergy/New(
	datum/mind/memorizer_mind,
	memorizer,
	atom/protagonist_actual,
	atom/deuteragonist_actual,
	atom/antagonist_actual,
	allergy_string,
)
	src.allergy_string = allergy_string
	return ..()

/datum/memory/quirk_allergy/get_names()
	return list("The [allergy_string] allergy of [protagonist].")

/datum/memory/quirk_allergy/get_starts()
	return list("[protagonist] sneezing after coming into contact with [allergy_string].")

/datum/memory/quirk_allergy/get_moods()
	return list("[memorizer] [mood_verb] as they wipe their nose.")

/// Tracks what brand a smoker quirk user likes
/datum/memory/quirk_smoker
	var/preferred_brand

/datum/memory/quirk_smoker/New(
	datum/mind/memorizer_mind,
	memorizer,
	atom/protagonist_actual,
	atom/deuteragonist_actual,
	atom/antagonist_actual,
	preferred_brand,
)
	src.preferred_brand = preferred_brand
	return ..()

/datum/memory/quirk_smoker/get_names()
	return list("[protagonist]'s smoking problem.")

/datum/memory/quirk_smoker/get_starts()
	return list(
		"[preferred_brand] cigarettes being plundered by [protagonist].",
		"[protagonist] buying a box of [preferred_brand] nicotine sticks.",
		"[protagonist] fiending for some [preferred_brand] ciggies.",
	)

/datum/memory/quirk_smoker/get_moods()
	return list("[memorizer] [mood_verb] as they light another up.")
