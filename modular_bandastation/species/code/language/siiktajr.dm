// MARK: Tajaran language
/datum/language/siiktajr
	name = "Сик'таир"
	desc = "Основной разговорный язык таяр."
	key = "8"
	flags = TONGUELESS_SPEECH
	space_chance = 50
	syllables = list("рр","ррр","тайр","кир","радж","кии","мир","кра","ахк","нал","вах","кхаз","джри","ран","дарр", \
		"ми","джри","дин","манк","рхе","зар","ррхаз","кал","чар","ич","тхаа","дра","джурл","мах","сану","дра","ии'р", \
		"ка","ааси","фар","ва","бак","ара","кара","зар","сам","мак","храр","нджа","рир","хан","джун","дар","рик","ках", \
		"хал","кет","джурл","мах","тул","крещ","азу","рах")
	always_use_default_namelist = TRUE
	icon = 'icons/bandastation/mob/species/tajaran/lang.dmi'
	icon_state = "taj_face"
	default_priority = 90

/datum/language/siiktajr/default_name(gender)
	if(gender == MALE)
		return "[pick(GLOB.first_names_male_tajaran)][random_name_spacer][pick(GLOB.last_names_tajaran)]"
	return "[pick(GLOB.first_names_female_tajaran)][random_name_spacer][pick(GLOB.last_names_tajaran)]"

/datum/language_holder/tajaran
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/siiktajr = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/siiktajr = list(LANGUAGE_ATOM),
	)
