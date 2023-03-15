//point of note: a lot of the darkspawns' abilities cause them to hear stuff
//this stuff is plain English run through rot22; you can translate it back with rot4
//the darkspeak language doesn't fall under this, though
/datum/language/darkspawn
	name = "Darkspeak"
	desc = "A language used by the darkspawn. Even with harsh syllables, it rolls silkily off the tongue."
	syllables = list("ko", "ii", "ma", "an", "sah", "lo", "na")
	flags = NO_STUTTER
	key = "a"
	default_priority = 10
	space_chance = 40
	icon = 'massmeta/icons/misc/language.dmi'
	icon_state = "darkspeak"
