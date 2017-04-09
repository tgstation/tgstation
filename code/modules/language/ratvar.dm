/datum/language/ratvar
	name = "Ratvarian"
	desc = "A timeless language full of power and incomprehensible to the unenlightened."
	speech_verb = "clinks"
	ask_verb = "clunks"
	exclaim_verb = "clanks"
	key = "r"
	default_priority = 10
	spans = list(SPAN_ROBOT, "brass")

/datum/language/ratvar/scramble(var/input)
	. = text2ratvar(input)
