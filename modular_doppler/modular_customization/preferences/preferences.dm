
/datum/preferences
	/// Preference of how the preview should show the character.
	var/preview_pref = PREVIEW_PREF_JOB

	/// Associative list, keyed by language typepath, pointing to LANGUAGE_UNDERSTOOD, or LANGUAGE_SPOKEN, for whether we understand or speak the language
	var/list/languages = list()

	/// Associative list containing all powers, pointing to their respective cost
	var/list/powers = list()

// Updates the mob's chat color in the global cache
/datum/preferences/safe_transfer_prefs_to(mob/living/carbon/human/character, icon_updates = TRUE, is_antag = FALSE)
	. = ..()
	GLOB.chat_colors_by_mob_name[character.name] = list(character.chat_color, character.chat_color_darkened) // by now the mob has had its prefs applied to it
