/datum/language/ponish
	name = "Ponish"
	desc = "A pretty, flowing tonal language spoken by ponies. It is known for its profound metaphors and vibrant vocabulary."
	key = "-"
	space_chance = 75
	default_priority = 90
	syllables = list(
		"riváá", "llanseri", "intsnu", "tá", "awupen", "búnzhabee", "tsubki", "waallukú", "zi", "aah", "irrit", "lovinmú",
		"úrhka", "entsulla", "tsa", "wabewa", "fálozha", "suntsuphoá", "sorra", "olrisa", "sinrron", "konsu", "surr", "vusán", "ipuxi"
	)
	icon_state = "ponish"
	always_use_default_namelist = TRUE

/datum/language/ponish/get_random_name(
	gender = NEUTER,
	name_count = default_name_count,
	syllable_min = default_name_syllable_min,
	syllable_max = default_name_syllable_max,
	force_use_syllables = FALSE,
)
	if(force_use_syllables)
		return ..()
	var/name = pick(GLOB.pony_names)
	return name
