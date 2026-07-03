/datum/language/moffic
	name = "Moffic"
	desc = "Язык молей, который находится на грани полной невразумительности."
	key = "m"
	space_chance = 5
	sentence_chance = 0
	between_word_sentence_chance = 10
	between_word_space_chance = 25
	additional_syllable_low = 0
	additional_syllable_high = 0
	syllables = list(
		"åр", "и", "гåр", "сек", "мо", "фф", "ок", "гдж", "ø", "гå", "ла", "ле",
		"лит", "югг", "ван", "дåр", "нæ", "мøт", "идд", "во", "я", "по", "хан",
		"сå", "åн", "дет", "åтт", "нå", "гö", "бра", "инт", "тюк", "ом", "нäр",
		"тво", "мå", "даг", "ше", "вии", "вуо", "ейл", "тун", "кейт", "тех", "вä",
		"хäй", "хуо", "суо", "ää", "тен", "я", "хой", "шту", "ур", "кöн", "ве", "хöн"
	)
	icon_state = "moth"
	default_priority = 90

	default_name_syllable_min = 5
	default_name_syllable_max = 10

/datum/language/moffic/get_random_name(
	gender = NEUTER,
	name_count = default_name_count,
	syllable_min = default_name_syllable_min,
	syllable_max = default_name_syllable_max,
	force_use_syllables = FALSE,
)
	if(force_use_syllables)
		return ..()

	return "[pick(GLOB.moth_first)] [pick(GLOB.moth_last)]"


// Fuck guest accounts, and fuck language testing.
