/datum/language/nekomimetic
	name = "Nekomimetic"
	desc = "Для непосвящённого этот язык представляет собой непонятную мешанину из ломаного японского. Для фелинидов же он каким-то образом понятен."
	key = "f"
	space_chance = 15
	sentence_chance = 0
	between_word_sentence_chance = 10
	between_word_space_chance = 75
	additional_syllable_low = -1
	additional_syllable_high = 1
	syllables = list(
		"неко", "нян", "мими", "моэ", "мофу", "фува", "кяа", "каваи", "пока", "муня",
		"пуни", "мую", "уфуфу", "ухуху", "ича", "доки", "кюн", "кусу", "ня", "няа",
		"десу", "кис", "ама", "чю", "бака", "хево", "буп", "гато", "кит", "суне", "ёри",
		"со", "бака", "тян", "сан", "кун", "махо", "ятта", "суки", "усаги", "домо", "ори",
		"ува", "дзаадзаа", "шику", "пуру", "ира", "хето", "этто"
	)
	icon_state = "neko"
	default_priority = 90
	default_name_syllable_min = 2
	default_name_syllable_max = 2

/datum/language/nekomimetic/get_random_name(
	gender = NEUTER,
	name_count = default_name_count,
	syllable_min = default_name_syllable_min,
	syllable_max = default_name_syllable_max,
	force_use_syllables = FALSE,
)
	if(prob(33))
		return default_name(gender)
	return ..()
