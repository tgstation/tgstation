/mob/living/silicon/proc/show_laws() //Redefined in ai/laws.dm and robot/laws.dm
	return

/mob/living/silicon/proc/laws_sanity_check()
	if (!laws)
		make_laws()

/mob/living/silicon/proc/set_zeroth_law(var/law, var/law_borg)
	src.laws_sanity_check()
	src.laws.set_zeroth_law(law, law_borg)

/mob/living/silicon/proc/add_inherent_law(var/law)
	laws_sanity_check()
	laws.add_inherent_law(law)

/mob/living/silicon/proc/clear_inherent_laws()
	laws_sanity_check()
	laws.clear_inherent_laws()

/mob/living/silicon/proc/add_supplied_law(var/number, var/law)
	laws_sanity_check()
	laws.add_supplied_law(number, law)

/mob/living/silicon/proc/clear_supplied_laws()
	laws_sanity_check()
	laws.clear_supplied_laws()

/mob/living/silicon/proc/add_ion_law(var/law)
	laws_sanity_check()
	laws.add_ion_law(law)

/mob/living/silicon/proc/clear_ion_laws()
	laws_sanity_check()
	laws.clear_ion_laws()

/mob/living/silicon/proc/make_laws()
	switch(config.default_laws)
		if(0)	laws = new /datum/ai_laws/default/asimov()
		if(1)	laws = new /datum/ai_laws/custom()
		if(2)
			var/datum/ai_laws/lawtype = pick(typesof(/datum/ai_laws/default) - /datum/ai_laws/default)
			laws = new lawtype()
