/datum/disease
	var/name = "No disease"
	var/stage = 1 //all diseases start at stage 1
	var/max_stages = 0.0
	var/cure = null
	var/cure_id = null// reagent.id or list containing them
	var/cure_chance = 8//chance for the cure to do its job
	var/spread = null
	var/list/affected_species = list()
	var/mob/affected_mob = null
	var/carrier = 0.0 //there will be a small chance that the person will be a carrier
	var/curable = 1 //can this disease be cured? (By itself...)
	var/list/strain_data = list() //This is passed on to infectees
	var/stage_prob = 5		// probability of advancing to next stage, default 5% per check
	var/agent = "some microbes"//name of the disease agent
	var/permeability_mod = 0//permeability modifier. Positive gives better chance, negative - worse.

/datum/disease/proc/stage_act()

	var/cure_present = has_cure()
	//world << "[cure_present]"

	if(carrier&&!cure_present)
		//world << "[affected_mob] is carrier"
		return

	spread = (cure_present?"Remissive":initial(spread))

	if(stage > max_stages)
		stage = max_stages
	if(prob(stage_prob) && stage != max_stages && !cure_present) //now the disease shouldn't get back up to stage 4 in no time
		stage++
	if(stage != 1 && (prob(1) || (cure_present && prob(cure_chance))))
		stage--
	else if(stage == 1 && ((prob(1) && affected_mob.virus.curable) || (cure_present && prob(cure_chance))))
		affected_mob.resistances += affected_mob.virus.type
		affected_mob.virus = null
		return
	return

/datum/disease/proc/has_cure()
	if(!cure_id) return 0
	var/result = 1
	if(istype(cure_id, /list))
		for(var/C_id in cure_id)
			if(!affected_mob.reagents.has_reagent(C_id))
				result = 0
	else if(!affected_mob.reagents.has_reagent(cure_id))
		result = 0
	return result


/mob/proc/contract_disease(var/datum/disease/virus, var/skip_this = 0)

	if(src.resistances.Find(virus.type))
		if(prob(99)) return
		src.resistances.Remove(virus.type)//the resistance is futile

	//For alien egg and stuff
	if(skip_this == 1)
		src.virus = virus
		src.virus.affected_mob = src
		if(prob(5))
			src.virus.carrier = 1
		return
/*
	var/list/clothing_areas	= list()
	var/list/covers = list(UPPER_TORSO,LOWER_TORSO,LEGS,FEET,ARMS,HANDS)
	for(var/Covers in covers)
		clothing_areas[Covers] = list()

	for(var/obj/item/clothing/Clothing in src)
		if(Clothing)
			for(var/Covers in covers)
				if(Clothing&Covers)
					clothing_areas[Covers] += Clothing

*/
	if(prob(15)) return

	var/obj/item/clothing/Cl = null
	var/passed = 1
	var/target_zone = pick(1,2,50;3,50;4)//1 - head, 2 - body, 3 - hands, 4- feet

	if(istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src

		switch(target_zone)
			if(1)
				if(H.head)
					Cl = H.head
					passed = prob(Cl.permeability_coefficient*100+virus.permeability_mod)
					//world << "Head pass [passed]"
				if(passed && H.wear_mask)
					Cl = H.wear_mask
					passed = prob(Cl.permeability_coefficient*100+virus.permeability_mod)
					//world << "Mask pass [passed]"
			if(2)//arms and legs included
				if(H.wear_suit)
					Cl = H.wear_suit
					passed = prob(Cl.permeability_coefficient*100+virus.permeability_mod)
					//world << "Suit pass [passed]"
				if(passed && H.slot_w_uniform)
					Cl = H.slot_w_uniform
					passed = prob(Cl.permeability_coefficient*100+virus.permeability_mod)
					//world << "Uniform pass [passed]"
			if(3)
				if(H.wear_suit && H.wear_suit.body_parts_covered&HANDS)
					Cl = H.wear_suit
					passed = prob(Cl.permeability_coefficient*100+virus.permeability_mod)

				if(passed && H.gloves)
					Cl = H.gloves
					passed = prob(Cl.permeability_coefficient*100+virus.permeability_mod)
					//world << "Gloves pass [passed]"
			if(4)
				if(H.wear_suit && H.wear_suit.body_parts_covered&FEET)
					Cl = H.wear_suit
					passed = prob(Cl.permeability_coefficient*100+virus.permeability_mod)

				if(passed && H.shoes)
					Cl = H.shoes
					passed = prob(Cl.permeability_coefficient*100+virus.permeability_mod)
					//world << "Shoes pass [passed]"
			else
				src << "Something strange's going on, something's wrong."

			/*if("feet")
				if(H.shoes && istype(H.shoes, /obj/item/clothing/))
					Cl = H.shoes
					passed = prob(Cl.permeability_coefficient*100)
					//
					world << "Shoes pass [passed]"
			*/		//
	else if(istype(src, /mob/living/carbon/monkey))
		var/mob/living/carbon/monkey/M = src
		switch(target_zone)
			if(1)
				if(M.wear_mask)
					Cl = M.wear_mask
					passed = prob(Cl.permeability_coefficient*100+virus.permeability_mod)
					//world << "Mask pass [passed]"

	if(passed && virus.spread=="Airborne" && src.internals)
		passed = prob(60)

	if(passed)
//		world << "Infection in the mob [src]. YAY"


/*
	var/score = 0
	if(istype(src, /mob/living/carbon/human))
		if(src:gloves) score += 5
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
	else if(score >= 15 && prob(75))
		return
	else if(score >= 10 && prob(55))
		return
	else if(score >= 5 && prob(35))
		return
	else if(prob(15))
		return
	else*/
		src.virus = virus
		src.virus.affected_mob = src
		if(prob(5))
			src.virus.carrier = 1
		return
	return
