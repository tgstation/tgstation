/datum/language/swarmer
	name = "Swarmer"
	desc = "A language only consisting of musical notes."
	speech_verb = "tones"
	ask_verb = "tones inquisitively"
	exclaim_verb = "tones loudly"
	colour = "changeling"
	key = "s"
	flags = NO_STUTTER
	space_chance = 100
	sentence_chance = 0
	default_priority = 60
	// since various flats and sharps are the same,
	// all non-accidental notes are doubled in the list
	syllables = list(
					"C", "C",
					"C♯", "D♭",
					"D", "D",
					"D♯", "E♭",
					"E", "E",
					"F", "F",
					"F♯", "G♭",
					"G", "G",
					"G♯", "A♭",
					"A", "A",
					"A♯", "B♭",
					"B", "B")
