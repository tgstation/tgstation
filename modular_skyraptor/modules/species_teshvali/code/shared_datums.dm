/datum/language/teshvali
	name = "Tesh'Vali"
	desc = "Assorted warbles, wurbles, chitters & chirps common to the Avali and Teshari alike."
	key = "F"
	flags = TONGUELESS_SPEECH
	space_chance = 40
	syllables = list(
		"i", "ii", "si", "aci", "hi", "ni", "li", "schi", "tari",
		"e", "she", "re", "me", "ne",  "te", "se", "le", "ai",
		"a", "ra", "ca", "scha", "tara", "sa", "la", "na",
	)
	icon = 'modular_skyraptor/modules/species_teshvali/icons.dmi'
	icon_state = "birdspeak"
	default_priority = 90

/datum/language_holder/teshvali
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
								/datum/language/teshvali = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
							/datum/language/teshvali = list(LANGUAGE_ATOM))

/obj/item/organ/internal/tongue/get_possible_languages()
	return ..() + /datum/language/teshvali
