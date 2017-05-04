/datum/disease/babel
	name = "Babel Virus"
	max_stages = 4
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Perfluorodecalin"
	cures = list("perfluorodecalin")
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Causes degeneration of brain speech centers."
	severity = DANGEROUS
	var/common_to_remove = /datum/language/common
	var/old_languages
	var/s3done = FALSE
	var/s4done = FALSE

/datum/disease/babel/stage_act()
	..()
	switch(stage)
		if(3)
			if(!s3done)
				if(affected_mob.has_language(common_to_remove))
					affected_mob.remove_language(common_to_remove)
					old_languages = affected_mob.languages.Copy()
				s3done = TRUE
		if(4)
			if(!s4done)
				affected_mob.remove_all_languages()
				var/all_langs = subtypesof(/datum/language)
				var/random_lang = pick_n_take(all_langs)
				affected_mob.grant_language(random_lang)
				if(prob(25))
					random_lang = pick(all_langs)
					affected_mob.grant_language(random_lang)
				s4done = TRUE

/datum/disease/babel/Destroy()
	if (affected_mob && old_languages)
		for(var/lang in old_languages)
			affected_mob.grant_language(lang)
	return ..()


//Only removes common
/datum/disease/babel/light
	s4done = TRUE