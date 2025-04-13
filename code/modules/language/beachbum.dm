/datum/language/beachbum
	name = "Beachtongue"
	desc = "An ancient language from the distant Beach Planet. People magically learn to speak it under the influence of space drugs."
	key = "u"
	space_chance = 80
	sentence_chance = 5
	between_word_sentence_chance = 0
	between_word_space_chance = 100
	additional_syllable_low = -2
	additional_syllable_high = -1
	default_priority = 90
	syllables = list(
		"cowabunga", "rad", "radical", "dudes", "bogus", "weeed", "every",
		"dee", "dah", "woah", "surf", "blazed", "high", "heinous", "day",
		"brah", "bro", "blown", "catch", "body", "beach", "oooo", "twenty",
		"shiz", "phiz", "wizz", "pop", "chill", "awesome", "dude", "it",
		"wax", "stoked", "yes", "ding", "way", "no", "wicked", "aaaa",
		"cool", "hoo", "wah", "wee", "man", "maaaaaan", "mate", "wick",
		"oh", "ocean", "up", "out", "rip", "slide", "big", "stomp",
		"weed", "pot", "smoke", "four-twenty", "shove", "wacky", "hah",
		"sick", "slash", "spit", "stoked", "shallow", "gun", "party",
		"heavy", "stellar", "excellent", "triumphant", "babe", "four",
		"tail", "trim", "tube", "wobble", "roll", "gnarly", "epic",
	)
	icon_state = "beach"
	always_use_default_namelist = TRUE

	mutual_understanding = list(
		/datum/language/common = 50,
		/datum/language/uncommon = 33,
	)
