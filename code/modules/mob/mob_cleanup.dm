//Methods that need to be cleaned.
/* INFORMATION
Put (mob/proc)s here that are in dire need of a code cleanup.
*/

/mob/proc/has_disease(var/datum/disease/virus)
	for(var/datum/disease/D in viruses)
		if(D.IsSame(virus))
			return 1
	return 0

// This proc has some procs that should be extracted from it. I believe we can develop some helper procs from it - Rockdtben
/mob/proc/contract_disease(var/datum/disease/virus, var/skip_this = 0, var/force_species_check=1)
//	world << "Contract_disease called by [src] with virus [virus]"
	if(stat >=2)
		return
	if(istype(virus, /datum/disease/advance))
		var/datum/disease/advance/A = virus
		if(A.GetDiseaseID() in resistances)
			return
	else
		if(src.resistances.Find(virus.type))
			return


	if(has_disease(virus))
		return


	if(force_species_check)
		var/fail = 1
		for(var/name in virus.affected_species)
			var/mob_type = text2path("/mob/living/carbon/[lowertext(name)]")
			if(mob_type && istype(src, mob_type))
				fail = 0
				break
		if(fail) return

	if(skip_this == 1)
		//if(src.virus)				< -- this used to replace the current disease. Not anymore!
			//src.virus.cure(0)

		var/datum/disease/v = new virus.type(D = virus)
		src.viruses += v
		v.affected_mob = src
		v.strain_data = v.strain_data.Copy()
		v.holder = src
		if(v.can_carry && prob(5))
			v.carrier = 1
		return

	//if(src.virus) //
		//return //


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
	if(prob(15/virus.permeability_mod)) return //the power of immunity compels this disease! but then you forgot resistances

	var/obj/item/clothing/Cl = null
	var/passed = 1

	//chances to target this zone
	var/head_ch
	var/body_ch
	var/hands_ch
	var/feet_ch

	switch(virus.spread_type)
		if(CONTACT_HANDS)
			head_ch = 0
			body_ch = 0
			hands_ch = 100
			feet_ch = 0
		if(CONTACT_FEET)
			head_ch = 0
			body_ch = 0
			hands_ch = 0
			feet_ch = 100
		else
			head_ch = 100
			body_ch = 100
			hands_ch = 25
			feet_ch = 25


	var/target_zone = pick(head_ch;1,body_ch;2,hands_ch;3,feet_ch;4)//1 - head, 2 - body, 3 - hands, 4- feet

	if(istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src

		switch(target_zone)
			if(1)
				if(isobj(H.head) && !istype(H.head, /obj/item/weapon/paper))
					Cl = H.head
					passed = prob(Cl.permeability_coefficient*100*virus.permeability_mod)
//					world << "Head pass [passed]"
				if(passed && isobj(H.wear_mask))
					Cl = H.wear_mask
					passed = prob(Cl.permeability_coefficient*100*virus.permeability_mod)
//					world << "Mask pass [passed]"
			if(2)//arms and legs included
				if(isobj(H.wear_suit))
					Cl = H.wear_suit
					passed = prob(Cl.permeability_coefficient*100*virus.permeability_mod)
//					world << "Suit pass [passed]"
				if(passed && isobj(slot_w_uniform))
					Cl = slot_w_uniform
					passed = prob(Cl.permeability_coefficient*100*virus.permeability_mod)
//					world << "Uniform pass [passed]"
			if(3)
				if(isobj(H.wear_suit) && H.wear_suit.body_parts_covered&HANDS)
					Cl = H.wear_suit
					passed = prob(Cl.permeability_coefficient*100*virus.permeability_mod)
//					world << "Suit pass [passed]"

				if(passed && isobj(H.gloves))
					Cl = H.gloves
					passed = prob(Cl.permeability_coefficient*100*virus.permeability_mod)
//					world << "Gloves pass [passed]"
			if(4)
				if(isobj(H.wear_suit) && H.wear_suit.body_parts_covered&FEET)
					Cl = H.wear_suit
					passed = prob(Cl.permeability_coefficient*100*virus.permeability_mod)
//					world << "Suit pass [passed]"

				if(passed && isobj(H.shoes))
					Cl = H.shoes
					passed = prob(Cl.permeability_coefficient*100*virus.permeability_mod)
//					world << "Shoes pass [passed]"
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
				if(M.wear_mask && isobj(M.wear_mask))
					Cl = M.wear_mask
					passed = prob(Cl.permeability_coefficient*100+virus.permeability_mod)
					//world << "Mask pass [passed]"

	if(passed && virus.spread_type == AIRBORNE && internals)
		passed = (prob(50*virus.permeability_mod))

	if(passed)
		//world << "Infection in the mob [src]. YAY"


/*
	var/score = 0
	if(istype(src, /mob/living/carbon/human))
		if(src:gloves) score += 5
		if(istype(src:wear_suit, /obj/item/clothing/suit/space)) score += 10
		if(istype(src:wear_suit, /obj/item/clothing/suit/bio_suit)) score += 10
		if(istype(src:head, /obj/item/clothing/head/helmet/space)) score += 5
		if(istype(src:head, /obj/item/clothing/head/bio_hood)) score += 5
	if(wear_mask)
		score += 5
		if((istype(src:wear_mask, /obj/item/clothing/mask) || istype(src:wear_mask, /obj/item/clothing/mask/surgical)) && !internal)
			score += 5
		if(internal)
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
		var/datum/disease/v = new virus.type
		src.viruses += v
		v.affected_mob = src
		v.strain_data = v.strain_data.Copy()
		v.holder = src
		if(v.can_carry && prob(5))
			v.carrier = 1
		return
	return
