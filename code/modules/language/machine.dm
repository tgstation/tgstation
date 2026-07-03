/datum/language/machine
	name = "Encoded Audio Language"
	desc = "Эффективный язык закодированных тонов, разработанный синтетиками и киборгами."
	spans = list(SPAN_ROBOT)
	key = "6"
	flags = NO_STUTTER
	syllables = list(
		"бип", "бип", "бип", "бип", "бип", "буп", "буп", "буп",
		"боп", "боп", "ди", "ди", "ду", "ду", "с-с-с", "ссс", "жжж",
		"жжж", "бзз", "кссш", "кии", "врр", "ваа", "тззз",
	)
	space_chance = 0
	sentence_chance = 0
	between_word_sentence_chance = 10
	between_word_space_chance = 10
	additional_syllable_low = 0
	additional_syllable_high = 0
	default_priority = 90

	icon_state = "eal"

/datum/language/machine/get_random_name(
	gender = NEUTER,
	name_count = 2,
	syllable_min = 2,
	syllable_max = 4,
	unique = FALSE,
	force_use_syllables = FALSE,
)
	if(force_use_syllables)
		return ..()
	if(prob(70))
		return "[pick(GLOB.posibrain_names)]-[rand(100, 999)]"
	return pick(GLOB.ai_names)
