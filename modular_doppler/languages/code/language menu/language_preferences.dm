#define MAX_MUTANT_ROWS 4

/datum/preferences/proc/species_updated(species_type)
	all_quirks = list()
	// Reset cultural stuff
	languages[try_get_common_language()] = LANGUAGE_SPOKEN
	save_character()

/// This helper proc gets the current species language holder and does any post-processing that's required in one easy to track place.
/// This proc should *always* be edited or used when modifying or getting the default languages of a player controlled, unrestricted species, to prevent any errant conflicts.
/datum/preferences/proc/get_adjusted_language_holder()
	var/datum/species/species = read_preference(/datum/preference/choiced/species)
	species = new species()
	var/datum/language_holder/language_holder = new species.species_language_holder()

	// Do language post procesing here. Used to house our foreigner functionality.
	// I saw little reason to remove this proc, considering it makes code using this a little easier to read.

	return language_holder

/// Tries to get the topmost language of the language holder. Should be the species' native language, and if it isn't, you should pester a coder.
/datum/preferences/proc/try_get_common_language()
	var/datum/language_holder/language_holder = get_adjusted_language_holder()
	var/language = language_holder.spoken_languages[1]
	return language
