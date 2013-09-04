//Returns 1 if mob can be infected, 0 otherwise. Checks his clothing.
proc/get_infection_chance(var/mob/living/carbon/M)
	var/score = 0
	if (!istype(M))
		return 0
	if(istype(M, /mob/living/carbon/human))
		if(M:gloves)
			score += 5
		if(istype(M:wear_suit, /obj/item/clothing/suit/space)) score += 10
		if(istype(M:wear_suit, /obj/item/clothing/suit/bio_suit)) score += 10
		if(istype(M:head, /obj/item/clothing/head/helmet/space)) score += 5
		if(istype(M:head, /obj/item/clothing/head/bio_hood)) score += 5
	if(M.wear_mask)
		score += 5
		if(istype(M:wear_mask, /obj/item/clothing/mask/surgical) && !M.internal)
			score += 10
		if(M.internal)
			score += 10

	if(score >= 30)
		return 0
	else if(score == 25 && prob(99))
		return 0
	else if(score == 20 && prob(95))
		return 0
	else if(score == 15 && prob(75))
		return 0
	else if(score == 10 && prob(55))
		return 0
	else if(score == 5 && prob(35))
		return 0
	return 1

//Checks if table-passing table can reach target (5 tile radius)
proc/airborne_can_reach(turf/source, turf/target)
	var/obj/dummy = new(source)
	dummy.flags = FPRINT | TABLEPASS
	dummy.pass_flags = PASSTABLE

	for(var/i=0, i<5, i++) if(!step_towards(dummy, target)) break

	var/rval = (dummy.loc in range(1,target))
	del dummy
	return rval

//Attemptes to infect mob M with virus. Set forced to 1 to ignore protective clothnig
/proc/infect_virus2(var/mob/living/carbon/M,var/datum/disease2/disease/disease,var/forced = 0)
	if(!istype(disease))
		return
	if(!istype(M))
		return
	if ("[disease.uniqueID]" in M.virus2)
		return
	// if one of the antibodies in the mob's body matches one of the disease's antigens, don't infect
	if(M.antibodies & disease.antigen != 0)
		return

	if(prob(disease.infectionchance) || forced)
		// certain clothes can prevent an infection
		if(!forced && !get_infection_chance(M))
			return

		var/datum/disease2/disease/D = disease.getcopy()
		D.minormutate()
		M.virus2["[D.uniqueID]"] = D

//Infects mob M with random lesser disease, if he doesn't have one
/proc/infect_mob_random_lesser(var/mob/living/carbon/M)
	var/datum/disease2/disease/D = new /datum/disease2/disease
	D.makerandom()
	D.infectionchance = 1
	M.virus2["[D.uniqueID]"] = D

//Infects mob M with random greated disease, if he doesn't have one
/proc/infect_mob_random_greater(var/mob/living/carbon/M)
	var/datum/disease2/disease/D = new /datum/disease2/disease
	D.makerandom(1)
	M.virus2["[D.uniqueID]"] = D

//Fancy prob() function.
/proc/dprob(var/p)
	return(prob(sqrt(p)) && prob(sqrt(p)))
