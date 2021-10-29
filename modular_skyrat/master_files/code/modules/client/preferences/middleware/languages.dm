/datum/asset/spritesheet/languages
	name = "languages"
	early = TRUE

/datum/asset/spritesheet/languages/register()
	var/list/to_insert = list()

	if(!GLOB.all_languages.len)
		for(var/L in subtypesof(/datum/language))
			var/datum/language/language = L
			if(!initial(language.key))
				continue

			GLOB.all_languages += language

			var/datum/language/instance = new language

			GLOB.language_datum_instances[language] = instance

	for (var/language_name in GLOB.all_languages)
		var/datum/language/language = GLOB.language_datum_instances[language_name]
		var/icon/language_icon = icon(language.icon, icon_state=language.icon_state)
		to_insert[sanitize_css_class_name(language.name)] = language_icon

	for (var/spritesheet_key in to_insert)
		Insert(spritesheet_key, to_insert[spritesheet_key])

	return ..()

/// Middleware to handle languages
/datum/preference_middleware/languages
	var/tainted = FALSE

	action_delegations = list(
		"give_language" = .proc/give_language,
		"remove_language" = .proc/remove_language,
	)
	var/list/name_to_language

/datum/preference_middleware/languages/apply_to_human(mob/living/carbon/human/target, datum/preferences/preferences) //SKYRAT EDIT CHANGE
	target.language_holder.understood_languages.Cut()
	target.language_holder.spoken_languages.Cut()
	target.language_holder.omnitongue = TRUE // a crappy hack but it works
	for(var/lang_path in preferences.languages)
		target.language_holder.understood_languages[lang_path] = list(LANGUAGE_ATOM)
		target.language_holder.spoken_languages[lang_path] = list(LANGUAGE_ATOM)

/datum/preference_middleware/languages/get_ui_assets()
	return list(
		get_asset_datum(/datum/asset/spritesheet/languages),
	)

/datum/preference_middleware/languages/post_set_preference(mob/user, preference, value)
	if(preference == "species")
		preferences.languages = list()
		var/species_type = preferences.read_preference(/datum/preference/choiced/species)
		var/datum/species/species = new species_type()
		for(var/language in species.learnable_languages)
			preferences.languages[language] = LANGUAGE_SPOKEN
		qdel(species)

	. = ..()

/datum/preference_middleware/languages/get_ui_data(mob/user)
	if(!name_to_language)
		name_to_language = list()
		for(var/language_name in GLOB.all_languages)
			var/datum/language/language = GLOB.language_datum_instances[language_name]
			name_to_language[language.name] = language_name

	var/list/data = list()

	var/max_languages = preferences.all_quirks.Find(QUIRK_LINGUIST) ? 4 : 3
	var/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type()
	if(!preferences.languages || !preferences.languages.len || (preferences.languages && preferences.languages.len > max_languages)) // Too many languages, or no languages.
		preferences.languages = list()
		for(var/language in species.learnable_languages)
			preferences.languages[language] = LANGUAGE_SPOKEN
	var/list/selected_languages = list()
	var/list/unselected_languages = list()
	for (var/language_name in GLOB.all_languages)
		var/datum/language/language = GLOB.language_datum_instances[language_name]
		if(language.secret)
			continue
		if(species.always_customizable && !(language.type in species.learnable_languages)) //For the ghostrole species. We don't want ashwalkers speaking beachtongue now.
			continue
		if(preferences.languages[language.type])
			selected_languages += list(list(
				"description" = language.desc,
				"name" = language.name,
				"icon" = sanitize_css_class_name(language.name)
			))
		else
			unselected_languages += list(list(
				"description" = language.desc,
				"name" = language.name,
				"icon" = sanitize_css_class_name(language.name)
			))
	qdel(species)

	data["total_language_points"] = max_languages
	data["selected_languages"] = selected_languages
	data["unselected_languages"] = unselected_languages
	return data

/datum/preference_middleware/languages/proc/give_language(list/params, mob/user)
	var/language_name = params["language_name"]
	var/max_languages = preferences.all_quirks.Find(QUIRK_LINGUIST) ? 4 : 3
	if(preferences.languages && preferences.languages.len == max_languages) // too many languages
		return TRUE
	preferences.languages[name_to_language[language_name]] = LANGUAGE_SPOKEN
	return TRUE

/datum/preference_middleware/languages/proc/remove_language(list/params, mob/user)
	var/language_name = params["language_name"]
	preferences.languages -= name_to_language[language_name]
	return TRUE

/datum/preference_middleware/languages/proc/get_selected_languages()
	var/list/selected_languages = list()

	for (var/language in preferences.languages)
		var/datum/language/language_datum = GLOB.language_datum_instances[language]
		selected_languages += sanitize_css_class_name(language_datum.name)

	return selected_languages
