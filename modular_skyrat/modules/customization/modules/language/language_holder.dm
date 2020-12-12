/datum/language_holder/New(_owner, datum/preferences/pref_load)
	if(pref_load)
		//If we're loading a holder from prefs, override the languages
		understood_languages.Cut()
		spoken_languages.Cut()
		for(var/lang_path in pref_load.languages)
			understood_languages[lang_path] = list(LANGUAGE_ATOM)
			if(pref_load.languages[lang_path] == LANGUAGE_SPOKEN)
				spoken_languages[lang_path] = list(LANGUAGE_ATOM)
	owner = _owner
	if(istype(owner, /datum/mind))
		var/datum/mind/M = owner
		if(M.current)
			update_atom_languages(M.current)
	get_selected_language()

/datum/language_holder/dwarf
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
								/datum/language/dwarf = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
							/datum/language/dwarf = list(LANGUAGE_ATOM))

/datum/language_holder/vox
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
								/datum/language/vox = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
							/datum/language/vox = list(LANGUAGE_ATOM))
