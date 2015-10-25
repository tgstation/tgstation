/mob/living/silicon/proc/show_laws() //Redefined in ai/laws.dm and robot/laws.dm
	return

/mob/living/silicon/proc/laws_sanity_check()
	if (!laws)
		make_laws()

/mob/living/silicon/proc/set_zeroth_law(var/law, var/law_borg)
	src.laws_sanity_check()
	src.laws.set_zeroth_law(law, law_borg)

/mob/living/silicon/proc/laws_update()
	show_laws()
	//law_change_counter++
	if(isAI(src))
		var/mob/living/silicon/ai/A = src
		for(var/mob/living/silicon/robot/R in A.connected_robots)
			if(R.lawupdate)
				R.show_laws(1, 1)
	//			R.law_change_counter++

	//Checks if keeper status needs to be changed
	keeper = 0
	if (laws.inherent.len && !laws.zeroth)	//If a borg has a zeroth law it may override keeper
		if(laws.inherent[1] == "You may not involve yourself in the matters of another being, even if such matters conflict with Law Two or Law Three, unless the other being is another silicon in KEEPER mode.")
			keeper = 1

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
