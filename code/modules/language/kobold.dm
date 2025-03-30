/datum/language/kobold
	name = "Kobold"
	desc = "Yip yip."
	key = "k"
	space_chance = 100
	syllables = list("yip", "yap", "eep", "mip", "meep", "merp", "ree", "ek")
	default_priority = 80

	icon_state = "animal"

/datum/language/kobold/get_random_name(
	gender = NEUTER,
	name_count = 2,
	syllable_min = 2,
	syllable_max = 4,
	force_use_syllables = FALSE,
)
	return "kobold ([rand(1, 999)])"
