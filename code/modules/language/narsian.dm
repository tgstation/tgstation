/datum/language/narsie
	name = "Nar'Sian"
	desc = "Древний, пропитанный кровью, невероятно сложный язык культистов Нар'Си."
	key = "n"
	space_chance = 75 //very high due to the potential length of each syllable
	sentence_chance = 10
	between_word_sentence_chance = 5
	between_word_space_chance = 95
	additional_syllable_low = -1
	additional_syllable_high = 0
	var/static/list/base_syllables = list(
		"х", "в", "к", "е", "г", "д", "р", "н", "х", "о", "п",
		"ра", "со", "ат", "ил", "та", "гх", "ш", "я", "те", "ш", "ол", "ма", "ом", "иг", "ни", "ин",
		"ша", "мир", "сас", "мах", "зар", "ток", "лир", "нква", "нап", "олт", "вал", "кха",
		"фве", "атх", "иро", "етх", "гал", "гиб", "бар", "джин", "кла", "ату", "кал", "лиг",
		"йока", "драк", "лосо", "арта", "вейх", "инес", "тотх", "фара", "амар", "няг", "эске", "ретх", "дедо", "бтох", "никт", "нетх",
		"канас", "гарис", "улофт", "тарат", "хари", "тхнор", "рекка", "рагга", "рфикк", "харфр", "андид", "етхра", "дедол", "тотум",
		"нтратх", "кериам"
	) //the list of syllables we'll combine with itself to get a larger list of syllables
	syllables = list(
		"ша", "мир", "сас", "мах", "хра", "зар", "ток", "лир", "нква", "нап", "олт", "вал",
		"ям", "кха", "фел", "дет", "фве", "мах", "эрл", "атх", "иро", "етх", "гал", "муд",
		"гиб", "бар", "теа", "фуу", "джин", "кла", "ату", "кал", "лиг",
		"йока", "драк", "лосо", "арта", "вейх", "инес", "тотх", "фара", "амар", "няг", "эске", "ретх", "дедо", "бтох", "никт", "нетх", "абис",
		"канас", "гарис", "улофт", "тарат", "хари", "тхнор", "рекка", "рагга", "рфикк", "харфр", "андид", "етхра", "дедол", "тотум",
		"вербот", "плегх", "нтратх", "бархах", "паснар", "кериам", "усинар", "саврэ", "амутан", "таннин", "ремиум", "барада",
		"форбичи"
	) //the base syllables, which include a few rare ones that won't appear in the mixed syllables
	icon_state = "narsie"
	default_priority = 10

/datum/language/narsie/New()
	for(var/syllable in base_syllables) //we only do this once, since there's only ever a single one of each language datum.
		for(var/target_syllable in base_syllables)
			if(syllable != target_syllable) //don't combine with yourself
				if(length(syllable) + length(target_syllable) > 8) //if the resulting syllable would be very long, don't put anything between it
					syllables += "[syllable][target_syllable]"
				else if(prob(80)) //we'll be minutely different each round.
					syllables += "[syllable]'[target_syllable]"
				else if(prob(25)) //5% chance of - instead of '
					syllables += "[syllable]-[target_syllable]"
				else //15% chance of no ' or - at all
					syllables += "[syllable][target_syllable]"
	..()
