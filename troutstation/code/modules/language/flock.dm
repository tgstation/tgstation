/datum/language/flock
	name = "Polyphonic"
	desc = "A series of machine chirps and chirrups intermixed with complex harmonics."
	spans = list(SPAN_FLOCK)
	key = "1"
	flags = NO_STUTTER
	syllables = list("=", "*", "|", "/", "\\", ".", "-", "_")
	space_chance = 0
	sentence_chance = 0
	between_word_sentence_chance = 0
	between_word_space_chance = 0
	additional_syllable_low = 0
	additional_syllable_high = 0
	default_priority = 20

	icon_state = "drone" // todo: change
	always_use_default_namelist = TRUE // Nonsense language
