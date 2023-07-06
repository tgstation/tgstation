/datum/preference/choiced/language
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "language"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/language/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return "Bilingual" in preferences.all_quirks

/datum/preference/choiced/language/init_possible_values()
	var/list/values = list()

	if(!GLOB.roundstart_languages.len)
		generate_selectable_species_and_languages()

	//we add uncommon as it's foreigner-only.
	var/datum/language/uncommon/uncommon_language = /datum/language/uncommon
	values[initial(uncommon_language.name)] = uncommon_language

	for(var/datum/language/language_type as anything in GLOB.roundstart_languages)
		if(ispath(language_type, /datum/language/common))
			continue
		if(!values[initial(language_type.name)])
			values[initial(language_type.name)] = language_type

	return values

/datum/preference/choiced/language/apply_to_human(mob/living/carbon/human/target, value)
	var/list/datum/language/possible_languages = get_choices()
	var/wanted_language_type = possible_languages[value]
	if(!target.has_language(wanted_language_type))
		target.grant_language(wanted_language_type, source = LANGUAGE_QUIRK)
		return

	for(var/datum/language/spoken as anything in possible_languages)
		if(target.has_language(spoken))
			possible_languages -= spoken

	if(!length(possible_languages))
		to_chat(target, span_boldnotice("You are already familiar with all languages, so you did not learn one."))
		return
	target.grant_language(pick(possible_languages), source = LANGUAGE_QUIRK)
