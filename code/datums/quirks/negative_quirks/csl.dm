/datum/quirk/csl
	name = "Common Second Language"
	desc = "Common is not your native tongue - it's something you had to pick up along the way. \
		Some words in common will sound foreign, and you may drift back to your native tongue \
		when you are anxious or upset."
	icon = FA_ICON_LANDMARK_DOME
	quirk_flags = QUIRK_HIDE_FROM_SCAN
	value = -2
	gain_text = span_danger("You have difficulty parsing Common.")
	lose_text = span_notice("Common starts to click for you.")
	medical_record_text = "Patient is CSL."
	/// What language typepath is our primary language?
	var/native_language

/datum/quirk/csl/add(client/client_source)
	if(iscarbon(quirk_holder))
		quirk_holder.remove_language(/datum/language/common, UNDERSTOOD_LANGUAGE, LANGUAGE_SPECIES)
	else
		quirk_holder.remove_language(/datum/language/common, UNDERSTOOD_LANGUAGE, LANGUAGE_ATOM)
	quirk_holder.grant_partial_language(/datum/language/common, text2num(client_source?.prefs?.read_preference(/datum/preference/choiced/csl_strength)) || 90, type)
	RegisterSignal(quirk_holder, COMSIG_SPECIES_GAIN, PROC_REF(reremove_common))
	RegisterSignal(quirk_holder, COMSIG_MOB_SAY, PROC_REF(translate_parts))
	native_language = get_native_language()

/datum/quirk/csl/remove()
	UnregisterSignal(quirk_holder, COMSIG_SPECIES_GAIN)
	UnregisterSignal(quirk_holder, COMSIG_MOB_SAY)

	if(QDELING(quirk_holder))
		return

	quirk_holder.remove_partial_language(/datum/language/common, type)
	var/mob/living/carbon/carbon_quirk_holder = quirk_holder
	if(istype(carbon_quirk_holder) && carbon_quirk_holder.dna.species)
		// only give back common if they're a species that should speak it
		var/datum/language_holder/species_holder = GLOB.prototype_language_holders[carbon_quirk_holder.dna.species.species_language_holder]
		if(LAZYACCESS(species_holder.spoken_languages, /datum/language/common))
			quirk_holder.grant_language(/datum/language/common, UNDERSTOOD_LANGUAGE, LANGUAGE_SPECIES)
	else
		quirk_holder.grant_language(/datum/language/common, UNDERSTOOD_LANGUAGE, LANGUAGE_ATOM)

/datum/quirk/csl/is_species_appropriate(datum/species/mob_species)
	var/datum/language_holder/species_holder = GLOB.prototype_language_holders[mob_species.species_language_holder]
	if(isnull(species_holder))
		return FALSE
	if(length(species_holder.spoken_languages) < 2)
		return FALSE
	return ..()

/// Gets our native language from our list of spoken languages
/datum/quirk/csl/proc/get_native_language()
	var/list/language_pool = quirk_holder.get_language_holder()?.spoken_languages?.Copy()
	if(!length(language_pool))
		return // no languages to pick from at all?

	// Don't want this
	language_pool -= /datum/language/common
	// If we have native languages set, prefer them
	var/list/prioritized_language_pool
	var/obj/item/organ/tongue/tongue = quirk_holder.get_organ_by_type(/obj/item/organ/tongue)
	if(length(tongue?.languages_native) > 0)
		prioritized_language_pool = language_pool & tongue.languages_native

	if(length(language_pool) < 1)
		return // guess we couldn't find one

	return length(prioritized_language_pool) > 0 ? prioritized_language_pool[1] : language_pool[1]

// Every time we change species we need to re-remove common from our list
/datum/quirk/csl/proc/reremove_common(...)
	SIGNAL_HANDLER
	quirk_holder.remove_language(/datum/language/common, UNDERSTOOD_LANGUAGE, LANGUAGE_SPECIES)
	native_language = get_native_language()

// At low sanity we translate everything to our native language
/datum/quirk/csl/proc/translate_parts(datum/source, list/say_args)
	SIGNAL_HANDLER

	if(say_args[SPEECH_FORCED] || isnull(native_language) || quirk_holder.mob_mood?.sanity > 75)
		return
	// init this list if nothing else has
	LAZYINITLIST(say_args[SPEECH_MODS][LANGUAGE_MUTUAL_BONUS])
	// force speak language, add mutual bonuses so everyone else can understand
	say_args[SPEECH_LANGUAGE] = native_language
	say_args[SPEECH_MODS][LANGUAGE_MUTUAL_BONUS][native_language] = max(round(8 * sqrt(quirk_holder.mob_mood?.sanity), 5), say_args[SPEECH_MODS][LANGUAGE_MUTUAL_BONUS][native_language])

/datum/quirk_constant_data/csl
	associated_typepath = /datum/quirk/csl
	customization_options = list(
		/datum/preference/choiced/csl_strength,
	)
