/datum/language/calcic
	name = "Calcic"
	desc = "Разрозненный и отрывистый язык плазмаменов. Также понимается скелетами."
	key = "b"
	space_chance = 10
	sentence_chance = 2
	between_word_sentence_chance = 10
	between_word_space_chance = 75
	additional_syllable_low = 0
	additional_syllable_high = 1
	syllables = list(
		"к", "кк", "акк", "икк", "кл", "тк", "ск", "иск", "так",
		"кл", "хс", "сс", "кс", "лк", "дк", "гк", "ка", "ска", "ла", "пк",
		"вк", "ак", "ик", "ип", "ски", "бк", "кб", "та", "ис", "ит", "ли", "ди",
		"дс", "йа", "скк", "крк", "хс", "вс", "мк", "ааа", "скраа", "скее", "хсс",
		"раа", "клк", "тк", "стк", "клк"
	)
	icon_state = "calcic"
	default_priority = 90

/datum/language/calcic/get_random_name(
	gender = NEUTER,
	name_count = default_name_count,
	syllable_min = default_name_syllable_min,
	syllable_max = default_name_syllable_max,
	force_use_syllables = FALSE,
)
	if(force_use_syllables)
		return ..()

	return "[pick(GLOB.plasmaman_names)] \Roman[rand(1, 99)]"

// Yeah, this goes to skeletons too, since it's basically just skeleton clacking.
