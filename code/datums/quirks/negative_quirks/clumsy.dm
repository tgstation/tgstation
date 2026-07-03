/datum/quirk/clumsy
	name = "Clumsy"
	desc = "Вы неуклюжий, глупый чувак. Вы большой и всеми любимый недотепа! Надеюсь, вы не собирались использовать свои руки для чего-либо, требующего хоть малейшей ловкости рук."
	icon = FA_ICON_FACE_DIZZY
	value = -8
	mob_trait = TRAIT_CLUMSY
	gain_text = span_danger("Вы чувствуете, как ваш IQ опускается, словно ваш мозг становится жидким.")
	lose_text = span_notice("Вы чувствуете, что ваш IQ вырос как минимум до среднего уровня.")
	medical_record_text = "Пациент демонстрирует крайние трудности со способностью передвижения в сочетании с неспособностью к критическому мышлению."
	medical_symptom_text = "Exhibits poor coordination and frequent accidents, along with difficulty in problem-solving and decision-making tasks."
	quirk_flags = QUIRK_TRAUMALIKE
