/datum/disease
	var/name = "No disease"
	var/stage = 1 //all diseases start at stage 1
	var/max_stages = 0.0
	var/cure = null
	var/spread = null
	var/list/affected_species = list()
	var/mob/affected_mob = null
	var/carrier = 0.0 //there will be a small chance that the person will be a carrier
	var/curable = 1 //can this disease be cured? (By itself...)
	var/list/strain_data = list() //This is passed on to infectees
	var/stage_prob = 5		// probability of advancing to next stage, default 5% per check
	var/agent = "some microbes"//name of the disease agent

/datum/disease/proc/stage_act()
	if(carrier)
		return
	if(stage > max_stages)
		stage = max_stages
	if(prob(stage_prob) && stage != max_stages)
		stage++
	else if(prob(1) && stage != 1)
		stage--
	else if(prob(1) && stage == 1 && affected_mob.virus.curable)
		affected_mob.resistances += affected_mob.virus.type
		affected_mob.virus = null
		return
	return

/mob/proc/contract_disease(var/datum/disease/virus, var/skip_this = 0)

	var/index = src.resistances.Find(virus.type)
	if(index)
		if(prob(99)) return
		src.resistances[index] = null//the resistance is futile

	//For alien egg and stuff
	if(skip_this == 1)
		src.virus = virus
		src.virus.affected_mob = src
		if(prob(5))
			src.virus.carrier = 1
		return

	var/score
	if(istype(src, /mob/living/carbon/human))
		if(src:gloves)
			score += 5
		if(istype(src:wear_suit, /obj/item/clothing/suit/space)) score += 10
		if(istype(src:wear_suit, /obj/item/clothing/suit/bio_suit)) score += 10
		if(istype(src:head, /obj/item/clothing/head/helmet/space)) score += 5
		if(istype(src:head, /obj/item/clothing/head/bio_hood)) score += 5
	if(src.wear_mask)
		score += 5
		if((istype(src:wear_mask, /obj/item/clothing/mask) || istype(src:wear_mask, /obj/item/clothing/mask/surgical)) && !src.internal)
			score += 5
		if(src.internal)
			score += 5
	if(score > 20)
		return
	else if(score == 20 && prob(95))
		return
	else if(score == 15 && prob(75))
		return
	else if(score == 10 && prob(55))
		return
	else if(score == 5 && prob(35))
		return
	else if(prob(15))
		return
	else
		src.virus = virus
		src.virus.affected_mob = src
		if(prob(5))
			src.virus.carrier = 1
		return
	return

