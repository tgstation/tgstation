/datum/language/primitive_genemod
	name = "Ættmál"
	desc = "A liturgical language passed through three centuries of Hearthkin culture, the only tongue which their literature is allowed to be spoken in; \
				especially relating to their pagan practices. While Galactic Uncommon is used as a trade language with outsiders, Ættmál remains sacred and mostly unknown \
				to those outside the Hearth."
	key = "H"
	flags = TONGUELESS_SPEECH
	space_chance = 70
	syllables = list (
		"al", "an", "ar", "að", "eg", "en", "er", "ha", "he", "il", "in", "ir", "ið", "ki", "le", "na", "nd", "ng", "nn", "og", "ra", "ri",
		"se", "st", "ta", "ur", "ði", "va", "ve", "sem", "sta", "til", "tur", "var", "ver", "við", "ður", "það", "þei", "með", "ega", "ann",
		"tur", "egr", "eda", "eva", "ada", "the", "tre", "tai", "thor", "thur", "ohd", "din", "gim", "per", "ger", "héð", "bur", "kóp", "vog",
		"bar", "dar", "akur", "jer", "bær", "múl", "fjörð", "jah", "dah", "dim", "din", "dir", "dur", "nya", "miau", "mjau", "ný", "kt", "hø",
	)
	icon_state = "omgkittyhiii"
	icon = 'modular_doppler/hearthkin/primitive_genemod/icons/language_icon.dmi'
	default_priority = 94
	secret = TRUE

/datum/language/primitive_genemod/get_random_name(
	gender = NEUTER,
	name_count = default_name_count,
	syllable_min = default_name_syllable_min,
	syllable_max = default_name_syllable_max,
	force_use_syllables = FALSE,
)
	if(force_use_syllables)
		return ..()

	if(gender == FEMALE)
		return "[pick(GLOB.hearthkin_names_female)][random_name_spacer][pick_lastname()]"
	if(gender == MALE)
		return "[pick(GLOB.hearthkin_names_male)][random_name_spacer][pick_lastname()]"
	if(gender == NEUTER || gender == PLURAL)
		return "[pick(GLOB.hearthkin_names_neutral)][random_name_spacer][pick_lastname()]"

/proc/pick_lastname()
	var/surname = pick(TRUE,FALSE)
	if(surname)
		return pick(GLOB.hearthkin_names_surname)
	else
		return pick(GLOB.hearthkin_names_title)
