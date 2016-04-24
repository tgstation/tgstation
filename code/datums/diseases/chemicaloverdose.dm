/datum/disease/chemicaloverdose/histamine_od
	name = "Histamine Overdose"
	max_stages = 2
	spread_text = "Special"
	spread_flags = SPECIAL
	cure_text = "Diphenhyramine"
	cures = list("diphenhydramine")
	agent = "Concentrated Histamine."
	viable_mobtypes = list(/mob/living/carbon/human,/mob/living/carbon/monkey)
	desc = "If left untreated severe oxygen deprivation, flesh damage, eye damage, and organ damage will occur."
	severity = BIOHAZARD
	disease_flags = CURABLE
	spread_flags = NON_CONTAGIOUS

/datum/disease/chemicaloverdose/histamine_od/stage_act()
	..()
	switch(stage)
		if(2)
			affected_mob.adjustOxyLoss(7)
			affected_mob.adjustBruteLoss(7)
			affected_mob.adjustToxLoss(7)
	return

/datum/disease/chemicaloverdose/mindbreaker_od
	name = "Mindbreaker Overdose"
	max_stages = 3
	spread_text = "Special"
	spread_flags = SPECIAL
	cure_text = "Synaptizine"
	cures = list("Synaptizine")
	agent = "Concentrated Mindbreaker."
	viable_mobtypes = list(/mob/living/carbon/human,/mob/living/carbon/monkey)
	desc = "If left untreated, constant hallucinations and loss of brain function will occur."
	severity = BIOHAZARD
	disease_flags = CURABLE
	spread_flags = NON_CONTAGIOUS

/datum/disease/chemicaloverdose/mindbreaker_od/stage_act()
	..()
	switch(stage)
		if(3)
			if(prob(15))
				affected_mob.adjustBrainLoss(2)
				affected_mob.hallucination += 10
	return