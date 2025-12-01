/datum/language/uncommon
	name = "Galactic Uncommon"
	desc = "The second-most spoken Human language."
	key = "!"
	flags = TONGUELESS_SPEECH
	space_chance = 20
	sentence_chance = 0
	between_word_sentence_chance = 10
	between_word_space_chance = 75
	additional_syllable_low = 0
	additional_syllable_high = 0
	syllables = list(
		"ba", "be", "bo", "ca", "ce", "co", "da", "de", "do",
		"fa", "fe", "fo", "ga", "ge", "go", "ha", "he", "ho",
		"ja", "je", "jo", "ka", "ke", "ko", "la", "le", "lo",
		"ma", "me", "mo", "na", "ne", "no", "ra", "re", "ro",
		"sa", "se", "so", "ta", "te", "to", "va", "ve", "vo",
		"xa", "xe", "xo", "ya", "ye", "yo", "za", "ze", "zo"
	)
	icon_state = "galuncom"
	default_priority = 90

	mutual_understanding = list(
		/datum/language/common = 20,
		/datum/language/beachbum = 20,
	)
