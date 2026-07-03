// The language of the podpeople. Yes, it's a shameless ripoff of elvish.
/datum/language/sylvan
	name = "Sylvan"
	desc = "Сложный древний язык, на котором говорят разумные растения."
	key = "h"
	space_chance = 10
	sentence_chance = 0
	between_word_sentence_chance = 10
	between_word_space_chance = 50
	additional_syllable_low = 1
	additional_syllable_high = 2
	syllables = list(
		"фии", "сии", "рии", "рел", "маа", "ала", "сан", "тол", "ток", "диа", "эрес",
		"фал", "тис", "бис", "кел", "арас", "лоск", "раса", "эоб", "хил", "танл", "аэре",
		"фер", "бал", "пии", "дала", "бан", "фоу", "доа", "ции", "уис", "мел", "уэкс",
		"инкас", "инт", "элк", "энт", "авс", "кип", "нас", "вил", "дженс", "дила", "фа",
		"ла", "ре", "до", "джи", "аэ", "со", "ке", "се", "на", "мо", "ха", "ю"
	)
	icon_state = "plant"
	default_priority = 90
	default_name_syllable_min = 2
	default_name_syllable_max = 3
