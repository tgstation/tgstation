/datum/language/swarmer
	name = "Swarmer"
	desc = "A language only consisting of musical notes."
	spans = list(SPAN_ROBOT)
	key = "s"
	flags = NO_STUTTER
	space_chance = 100
	sentence_chance = 0
	default_priority = 60

	icon_state = "swarmer"

	syllables = list(
		"C", "C",
		"C#", "Db",
		"D", "D",
		"D#", "Eb",
		"E", "E",
		"F", "F",
		"F#", "Gb",
		"G", "G",
		"G#", "Ab",
		"A", "A",
		"A#", "Bb",
		"B", "B")
