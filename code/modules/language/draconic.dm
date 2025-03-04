/datum/language/draconic
	name = "Draconic"
	desc = "The common language of lizard-people, composed of sibilant hisses and rattles."
	key = "o"
	flags = TONGUELESS_SPEECH
	space_chance = 40
	syllables = list(
		"za", "az", "ze", "ez", "zi", "iz", "zo", "oz", "zu", "uz", "zs", "sz",
		"ha", "ah", "he", "eh", "hi", "ih", "ho", "oh", "hu", "uh", "hs", "sh",
		"la", "al", "le", "el", "li", "il", "lo", "ol", "lu", "ul", "ls", "sl",
		"ka", "ak", "ke", "ek", "ki", "ik", "ko", "ok", "ku", "uk", "ks", "sk",
		"sa", "as", "se", "es", "si", "is", "so", "os", "su", "us", "ss", "ss",
		"ra", "ar", "re", "er", "ri", "ir", "ro", "or", "ru", "ur", "rs", "sr",
		"a",  "a",  "e",  "e",  "i",  "i",  "o",  "o",  "u",  "u",  "s",  "s"
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
