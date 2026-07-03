/datum/language/qurvolious
	name = "Курволиус"
	desc = "Государственный язык Королевской Области Кербаллак, Курволиус,\
		обладает богатым и мелодичным звучанием, которое течёт, как вода.\
		Некоторые слоги этого языка непостижимы для нечленов расы Скрелл."
	key = "9"
	syllables = list(

	)
	icon = 'icons/bandastation/mob/species/skrell/lang.dmi'
	icon_state = "skrell_face"
	default_priority = 90
	syllables = list(
		"кур","квр","кэр","кр","кар","крр","курр","кэрр","карр","шук",
		"хук","шюк","хюк","сузк","кил","квил","кэл","киль","куум","квум",
		"квом","кюум","шукм","хукм","шюкм","хюкм","вол","вёл","вул","валь",
		"шрим","хрим","крим","жрим","зау","заоу","зэу","заоо","куу","кьюю",
		"квуу","кюу","кикс","кш","квикс","кюкс","ку","кью","коу","квоу",
		"зикс","зекс","зюкс","зэш"
	)

/datum/language_holder/skrell
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/qurvolious = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/qurvolious = list(LANGUAGE_ATOM),
	)
