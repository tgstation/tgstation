/datum/language_holder/synthetic/New(atom/_owner)
	understood_languages += list(/datum/language/tencodes = list(LANGUAGE_ATOM))
	spoken_languages += list(/datum/language/tencodes = list(LANGUAGE_ATOM))

	return ..()
