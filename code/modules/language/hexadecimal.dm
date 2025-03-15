/datum/language/hexadecimal
	name = "Hexadecimal"
	desc = "Galactic Common encoded to hexadecimal in a currently-unknown way."
	spans = list(SPAN_ROBOT)
	key = "2"
	flags = NO_STUTTER
	syllables = list(
		"0","1","2","3","4","5","6","7","8","9","0","A","B","C","D","E","F"
	)
	space_chance = 0
	default_priority = 80

	icon_state = "eal"

/datum/language/hexadecimal/get_random_name(
	gender = NEUTER,
	name_count = 2,
	syllable_min = 2,
	syllable_max = 4,
	unique = FALSE,
	force_use_syllables = FALSE,
)
	if(force_use_syllables)
		return ..()

	return "[pick(GLOB.protogen_names)] [rand(0, 15)]"
