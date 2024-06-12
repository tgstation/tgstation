/datum/language/moffic
	name = "Moffic"
	desc = "The language of the Mothpeople borders on complete unintelligibility."
	key = "m"
	space_chance = 10
	syllables = list(
		"år", "i", "går", "sek", "mo", "ff", "ok", "gj", "ø", "gå", "la", "le",
		"lit", "ygg", "van", "dår", "næ", "møt", "idd", "hvo", "ja", "på", "han",
		"så", "ån", "det", "att", "nå", "gö", "bra", "int", "tyc", "om", "när",
		"två", "må", "dag", "sjä", "vii", "vuo", "eil", "tun", "käyt", "teh", "vä",
		"hei", "huo", "suo", "ää", "ten", "ja", "heu", "stu", "uhr", "kön", "we", "hön"
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
