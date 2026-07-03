//Spinwarder - The common tongue of the various lands of the former Third Soviet Union, and the official language of the Spinward Stellar Coalition

/datum/language/spinwarder
	name = "Spinwarder"
	desc = "Официальный язык Звёздной Коалиции Спинвард, унаследованный от Третьего Советского Союза."
	key = "s"
	space_chance = 20
	sentence_chance = 0
	between_word_sentence_chance = 10
	between_word_space_chance = 75
	additional_syllable_low = 0
	additional_syllable_high = 0
	flags = TONGUELESS_SPEECH
	syllables = list(
		"в", "од", "ной", "нед", "еле", "дн", "ей", "да", "ны", "ет", "мес", "ят",
		"че", "бу", "пол", "е", "ели", "ный", "се", "год", "я", "дом", "аш", "зав",
		"взы", "вч", "ход", "ной", "ин", "сек", "пять", "вос", "дес", "спл", "каз", "ден",
		"без", "ноц", "вай", "вст", "ся", "оста", "ча", "сте", "дит", "мас", "но", "оч",
		"испо", "ют", "ет", "жен", "раб", "по", "пря", "впер", "заг", "ните", "мне", "уж",
		"смет", "ёт", "шут", "кой", "тов", "мак", "я", "воск", "дале", "кий", "ци",
		"нок",  "хор",  "кра",  "сив",  "акт",  "утё",  "прек",  "леб",  "дя",  "труд",
	)
	special_characters = list("'")
	icon_state = "spinwarder"
	default_priority = 90
