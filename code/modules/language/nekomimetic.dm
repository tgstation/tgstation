/datum/language/nekomimetic
	name = "Nekomimetic"
	desc = "To the casual observer, this language is an incomprehensible mess of broken Japanese. To the felinids, it's somehow comprehensible."
	key = "f"
	space_chance = 70
	syllables = list(
		"neko", "nyan", "mimi", "moe", "mofu", "fuwa", "kyaa", "kawaii", "poka", "munya",
		"puni", "munyu", "ufufu", "uhuhu", "icha", "doki", "kyun", "kusu", "nya", "nyaa",
		"desu", "kis", "ama", "chuu", "baka", "hewo", "boop", "gato", "kit", "sune", "yori",
		"sou", "baka", "chan", "san", "kun", "mahou", "yatta", "suki", "usagi", "domo", "ori",
		"uwa", "zaazaa", "shiku", "puru", "ira", "heto", "etto"
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
