/datum/language/myrtongue
	name = "Myrtongue"
	desc = "The anteater language, a series of clicks, grunts, and snorts."
	key = "a"
	space_chance = 30
	sentence_chance = 0
	between_word_sentence_chance = 10
	between_word_space_chance = 75
	additional_syllable_low = -1
	additional_syllable_high = 2
	syllables = list(
		"gu", "gl", "hk", "kl", "gr", "kr", "sn", "ks", "hk", "ts", "ch", "sh",
		"zn", "ku", "gru", "kru", "glu", "klu", "hrk", "gul", "gol", "ku", "ko",
		"grn", "gra", "ulg", "hlk", "kl", "vrm", "vrr", "grr", "gor", "vur", "rul"
	)
	icon = 'troutstation/icons/ui/chat/language.dmi'
	icon_state = "anteater"
	default_priority = 90

	default_name_syllable_min = 3
	default_name_syllable_max = 6

/datum/language/myrtongue/get_random_name(
	gender = NEUTER,
	name_count = default_name_count,
	syllable_min = default_name_syllable_min,
	syllable_max = default_name_syllable_max,
	force_use_syllables = FALSE,
)
	if(force_use_syllables)
		return ..()

	return "[pick(GLOB.anteater_first)] [pick(GLOB.anteater_last)]"
