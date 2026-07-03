/datum/language/draconic
	name = "Draconic"
	desc = "Общий язык унатхов, состоящий из шипящих и дребезжащих звуков."
	key = "o"
	flags = TONGUELESS_SPEECH
	space_chance = 12
	sentence_chance = 0
	between_word_sentence_chance = 10
	between_word_space_chance = 75
	additional_syllable_low = 0
	additional_syllable_high = 3
	syllables = list(
		"за", "аз", "зэ", "эз", "зи", "из", "зо", "оз", "зу", "уз", "зс", "сз",
		"ха", "ах", "хэ", "эх", "хи", "их", "хо", "ох", "ху", "ух", "хс", "ш",
		"ла", "ал", "лэ", "эл", "ли", "ил", "ло", "ол", "лу", "ул", "лс", "сл",
		"ка", "ак", "кэ", "эк", "ки", "ик", "ко", "ок", "ку", "ук", "кс", "ск",
		"са", "ас", "сэ", "эс", "си", "ис", "со", "ос", "су", "ус", "сс", "сс",
		"ра", "ар", "рэ", "эр", "ри", "ир", "ро", "ор", "ру", "ур", "рс", "ср",
		"а",  "а",  "э",  "э",  "и",  "и",  "о",  "о",  "у",  "у",  "с",  "с"
	)
	special_characters = list("-")
	icon_state = "lizard"
	default_priority = 90
	default_name_syllable_min = 3
	default_name_syllable_max = 5
	random_name_spacer = "-"

/datum/language/draconic/get_random_name(
	gender = NEUTER,
	name_count = default_name_count,
	syllable_min = default_name_syllable_min,
	syllable_max = default_name_syllable_max,
	force_use_syllables = FALSE,
)
	if(force_use_syllables)
		return ..()
	if(gender != MALE && gender != FEMALE)
		gender = pick(MALE, FEMALE)

	if(gender == MALE)
		return "[pick(GLOB.lizard_names_male)][random_name_spacer][pick(GLOB.lizard_names_male)]"
	return "[pick(GLOB.lizard_names_female)][random_name_spacer][pick(GLOB.lizard_names_female)]"
