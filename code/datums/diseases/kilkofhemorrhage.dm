/datum/disease/kilkofhemorrhage
	name = "Kilkof Hemorrhagic fever"
	max_stages = 21
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Spaceacillin, Morphine, and Saline Glucose solution"
	cures = list("spaceacillin", "morphine", "salglu_solution")
	agent = "Kilkof Unomegavirales"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 75//three reagents to cure. this is only balance
	desc = "A deadly slow acting, deadly virus. Incubates in victims, before afflicting them with debilitating symptoms over a long time, finally resulting in death."
	severity = DANGEROUS

/datum/disease/kilkofhemorrhage/stage_act()
	..()

	switch(stage)
		if(1, 2, 3, 4, 5)

		if(6, 7, 8, 9, 10)

		if(11, 12, 13, 14, 15)

		if(16, 17, 18, 19, 20)

		if(21)

	return

