/datum/language/buzzwords
	name = "Buzzwords"
	desc = "Общий язык для всех насекомых, создаваемый ритмичным взмахом крыльев."
	key = "z"
	space_chance = 0
	sentence_chance = 0
	between_word_sentence_chance = 5
	between_word_space_chance = 0
	additional_syllable_low = 0
	additional_syllable_high = 0
	syllables = list(
		"бзз","ззз","з","бз","бззз","зззз", "бзззз", "б", "зз", "ззззз"
	)
	icon_state = "buzz"
	default_priority = 90
	always_use_default_namelist = TRUE // Otherwise we get Bzzbzbz Zzzbzbz.
