/datum/language/slugcat
	name = "Slugcat"
	desc = "The assorted warbling that slugcats are known for.  Hearing it spoken is a rarity."
	key = "G"
	flags = TONGUELESS_SPEECH
	space_chance = 30
	syllables = list(
		"wa", "wawa", "awa", "a"
	)
	icon = 'modular_skyraptor/modules/species_slugcat/icons.dmi'
	icon_state = "slugspeak"
	default_priority = 90

//scugs basically get omnitongue becuase of the Mark of Communication- though they can't speak in the various robot languages
/datum/language_holder/slugcat_mark
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
								/datum/language/slugcat = list(LANGUAGE_ATOM),
								/datum/language/teshvali = list(LANGUAGE_ATOM),
								/datum/language/uncommon = list(LANGUAGE_ATOM),
								/datum/language/machine = list(LANGUAGE_ATOM),
								/datum/language/drone = list(LANGUAGE_ATOM),
								/datum/language/draconic = list(LANGUAGE_ATOM),
								/datum/language/moffic = list(LANGUAGE_ATOM),
								/datum/language/calcic = list(LANGUAGE_ATOM),
								/datum/language/voltaic = list(LANGUAGE_ATOM),
								/datum/language/nekomimetic = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
							/datum/language/slugcat = list(LANGUAGE_ATOM),
							/datum/language/teshvali = list(LANGUAGE_ATOM),
							/datum/language/uncommon = list(LANGUAGE_ATOM),
							/datum/language/draconic = list(LANGUAGE_ATOM),
							/datum/language/moffic = list(LANGUAGE_ATOM),
							/datum/language/calcic = list(LANGUAGE_ATOM),
							/datum/language/nekomimetic = list(LANGUAGE_ATOM))

/obj/item/organ/internal/tongue/get_possible_languages()
	return ..() + /datum/language/slugcat
