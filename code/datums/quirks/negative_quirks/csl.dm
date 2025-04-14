/datum/quirk/csl
	name = "Common Second Language"
	desc = "Common is not your native tongue - it's something you had to pick up along the way. \
		Parsing common will be difficult (but not impossible), and you may drift back to your native tongue \
		when you are stressed, anxious, or angry."
	icon = FA_ICON_LANDMARK_DOME
	value = -2
	gain_text = span_danger("You have difficulty parsing Common.")
	lose_text = span_notice("Common starts to click for you.")

/datum/quirk/csl/add(client/client_source)
	if(iscarbon(quirk_holder))
		quirk_holder.remove_language(/datum/language/common, UNDERSTOOD_LANGUAGE, LANGUAGE_SPECIES)
	else
		quirk_holder.remove_language(/datum/language/common, UNDERSTOOD_LANGUAGE, LANGUAGE_ATOM)
	quirk_holder.grant_partial_language(/datum/language/common, text2num(client_source?.preferences?.read_preference(/datum/preference/choiced/csl_strength)) || 90, type)
	RegisterSignal(quirk_holder, COMSIG_SPECIES_GAIN, PROC_REF(reremove_common))
	RegisterSignal(quirk_holder, COMSIG_MOB_SAY, PROC_REF(translate_everything))
	RegisterSignal(quirk_holder, COMSIG_MOVABLE_LANGUAGE_BEING_TRANSLATED, PROC_REF(translate_parts))

/datum/quirk/csl/remove()
	UnregisterSignal(quirk_holder, COMSIG_SPECIES_GAIN)
	UnregisterSignal(quirk_holder, COMSIG_MOB_SAY)
	UnregisterSignal(quirk_holder, COMSIG_MOVABLE_LANGUAGE_BEING_TRANSLATED)

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
	var/obj/item/organ/tongue/tongue = quirk_holder.get_organ_by_type(/obj/item/organ/tongue)
	if(length(tongue?.languages_native) > 0)
		language_pool &= tongue.languages_native

	if(length(language_pool) < 1)
		return // guess we couldn't find one

	return language_pool[1]

// Every time we change species we need to re-remove common from our list
/datum/quirk/csl/proc/reremove_common(...)
	SIGNAL_HANDLER
	quirk_holder.remove_language(/datum/language/common, UNDERSTOOD_LANGUAGE, LANGUAGE_SPECIES)

// At low sanity we translate everything to our native language
/datum/quirk/csl/proc/translate_everything(datum/source, list/say_args)
	SIGNAL_HANDLER

	if(say_args[SPEECH_FORCED] || quirk_holder.mob_mood?.sanity > 75)
		return
	say_args[SPEECH_LANGUAGE] = get_native_language()

// While all of our messages become our native language, we also add some mutual understanding to everyone else
/datum/quirk/csl/proc/translate_parts(datum/source, atom/movable/translating_for, language, list/mutual_understanding)
	SIGNAL_HANDLER

	if(quirk_holder.mob_mood?.sanity > 75)
		return

	var/native_language = get_native_language()
	if(isnull(native_language) || native_language != language)
		return // guh? i guess we do nothing
	if(quirk_holder.get_selected_language() == native_language)
		return // we are willingly speaking

	// starts at 95%, then goes down to 20%
	mutual_understanding[native_language] = max(mutual_understanding[native_language], round(quirk_holder.mob_mood?.sanity + 20, 5))

/datum/quirk_constant_data/csl
	associated_typepath = /datum/quirk/csl
	customization_options = list(
		/datum/preference/choiced/csl_strength,
	)
