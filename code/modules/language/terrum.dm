/datum/language/terrum
	name = "Terrum"
	desc = "Язык големов. Звучит похоже на древнееврейский со Старой Земли."
	key = "g"
	space_chance = 20
	sentence_chance = 0
	between_word_sentence_chance = 10
	between_word_space_chance = 75
	additional_syllable_low = 1
	additional_syllable_high = 2
	syllables = list(
		"ша", "ву", "нах", "ха", "йом", "ма", "ха", "ар", "эт", "мол", "луа",
		"х", "на", "ш", "ни", "ях", "бес", "ол", "хиш", "эв", "ла", "от", "ла",
		"хе", "ца", "хак", "чак", "хин", "хок", "лир", "тов", "еф", "йфе",
		"хо", "ар", "кас", "кал", "ра", "лом", "им", "бок",
		"эрев", "шло", "ло", "та", "им", "йом"
	)
	special_characters = list("'")
	icon_state = "golem"
	default_priority = 90

/datum/language/terrum/get_random_name(
	gender = NEUTER,
	name_count = default_name_count,
	syllable_min = default_name_syllable_min,
	syllable_max = default_name_syllable_max,
	force_use_syllables = FALSE,
)
	if(force_use_syllables)
		return ..()

	var/name = pick(GLOB.golem_names)
	// 3% chance to be given a human surname for "lore reasons"
	if (prob(3))
		name += " [pick(GLOB.last_names)]"
	return name
