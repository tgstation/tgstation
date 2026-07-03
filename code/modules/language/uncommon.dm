/datum/language/uncommon
	name = "Galactic Uncommon"
	desc = "Второй по распространённости язык человечества."
	key = "!"
	flags = TONGUELESS_SPEECH
	space_chance = 20
	sentence_chance = 0
	between_word_sentence_chance = 10
	between_word_space_chance = 75
	additional_syllable_low = 0
	additional_syllable_high = 0
	syllables = list(
		"ба", "бе", "бо", "ка", "ке", "ко", "да", "де", "до",
		"фа", "фе", "фо", "га", "ге", "го", "ха", "хе", "хо",
		"джа", "дже", "джо", "ка", "ке", "ко", "ла", "ле", "ло",
		"ма", "ме", "мо", "на", "не", "но", "ра", "ре", "ро",
		"са", "се", "со", "та", "те", "то", "ва", "ве", "во",
		"кса", "ксе", "ксо", "я", "е", "ё", "за", "зе", "зо"
	)
	icon_state = "galuncom"
	default_priority = 90

	mutual_understanding = list(
		/datum/language/common = 20,
		/datum/language/beachbum = 20,
	)
