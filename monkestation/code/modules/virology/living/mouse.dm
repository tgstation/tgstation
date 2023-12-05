/mob/living/basic/mouse
	var/disease_chance = 5
	///list of diseases the rat has
	var/list/diseases = list()

/mob/living/basic/mouse/diseased/Initialize(mapload, tame, new_body_color)
	. = ..()
	if(prob(disease_chance))
		var/virus_choice = pick(subtypesof(/datum/disease/advanced))
		var/list/anti = list(
			ANTIGEN_BLOOD	= 2,
			ANTIGEN_COMMON	= 2,
			ANTIGEN_RARE	= 1,
			ANTIGEN_ALIEN	= 0,
		)
		var/list/bad = list(
			EFFECT_DANGER_HELPFUL	= 1,
			EFFECT_DANGER_FLAVOR	= 2,
			EFFECT_DANGER_ANNOYING	= 2,
			EFFECT_DANGER_HINDRANCE	= 2,
			EFFECT_DANGER_HARMFUL	= 2,
			EFFECT_DANGER_DEADLY	= 0,
		)
		var/datum/disease/advanced/disease = new virus_choice
		disease.makerandom(list(50,90),list(10,100),anti,bad,src)

