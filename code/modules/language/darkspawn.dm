/datum/language/darkspawn
	name = "Darkspeak"
	desc = "A language used by the darkspawn."
	speech_verb = "clicks"
	ask_verb = "chirps"
	exclaim_verb = "chitters"
	flags = NO_STUTTER | LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD
	key = "a"
	default_priority = 10
	icon_state = "darkspeak"

/datum/language/darkspawn/scramble(input)
	. = caesar_cipher(input, 22)
