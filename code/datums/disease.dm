#define SPECIAL 0
#define CONTACT_GENERAL 1
#define CONTACT_HANDS 2
#define CONTACT_FEET 3
#define AIRBORNE 4

/*

IMPORTANT NOTE: Please delete the diseases by using cure() proc or del() instruction.
Diseases are referenced in a global list, so simply setting mob or obj vars
to null does not delete the object itself. Thank you.

*/


/datum/disease
	var/name = "No disease"
	var/stage = 1 //all diseases start at stage 1
	var/max_stages = 0.0
	var/cure = null
	var/cure_id = null// reagent.id or list containing them
	var/cure_list = null // allows for multiple possible cure combinations
	var/cure_chance = 8//chance for the cure to do its job
	var/spread = null //spread type description
	var/spread_type = AIRBORNE
	var/contagious_period = 0//the disease stage when it can be spread
	var/list/affected_species = list()
	var/mob/living/carbon/affected_mob = null //the mob which is affected by disease.
	var/holder = null //the atom containing the disease (mob or obj)
	var/carrier = 0.0 //there will be a small chance that the person will be a carrier
	var/curable = 1 //can this disease be cured? (By itself...)
	var/list/strain_data = list() //This is passed on to infectees
	var/stage_prob = 5		// probability of advancing to next stage, default 5% per check
	var/agent = "some microbes"//name of the disease agent
	var/permeability_mod = 1//permeability modifier coefficient.
	var/desc = null//description. Leave it null and this disease won't show in med records.
	var/severity = null//severity descr
	var/longevity = 250//time in "ticks" the virus stays in inanimate object (blood stains, corpses, etc). In syringes, bottles and beakers it stays infinitely.

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
	else if(stage <= 1 && ((prob(1) && curable) || (cure_present && prob(cure_chance))))
//		world << "Cured as stage act"
		cure()
		return
	return

/datum/disease/proc/has_cure()//check if affected_mob has required reagents.
	if(!cure_id) return 0
	var/result = 1
	if(cure_list == list(cure_id))
		if(istype(cure_id, /list))
			for(var/C_id in cure_id)
				if(!affected_mob.reagents.has_reagent(C_id))
					result = 0
		else if(!affected_mob.reagents.has_reagent(cure_id))
			result = 0
	else
		for(var/C_list in cure_list)
			if(istype(C_list, /list))
				for(var/C_id in cure_id)
					if(!affected_mob.reagents.has_reagent(C_id))
						result = 0
			else if(!affected_mob.reagents.has_reagent(C_list))
				result = 0

	return result


/mob/proc/contract_disease(var/datum/disease/virus, var/skip_this = 0, var/force_species_check=1)
//	world << "Contract_disease called by [src] with virus [virus]"
	if(stat >=2) return


	if(force_species_check)
		var/fail = 1
		for(var/name in virus.affected_species)
			var/mob_type = text2path("/mob/living/carbon/[lowertext(name)]")
			if(mob_type && istype(src, mob_type))
				fail = 0
				break
		if(fail) return

	if(skip_this == 1)//be wary, it replaces the current disease...
		if(src.virus)
			src.virus.cure(0)
		src.virus = new virus.type
		src.virus.affected_mob = src
		src.virus.strain_data = virus.strain_data.Copy()
		src.virus.holder = src
		if(prob(5))
			src.virus.carrier = 1
		return

	if(src.virus)
		return

	if(virus.type in resistances)
		if(prob(99.9)) return
		resistances.Remove(virus.type)//the resistance is futile


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
	if(prob(15/virus.permeability_mod)) return //the power of immunity compels this disease!

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
				if(isobj(H.head))
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
				if(passed && isobj(H.slot_w_uniform))
					Cl = H.slot_w_uniform
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
//		world << "Infection in the mob [src]. YAY"


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
		src.virus = new virus.type
		src.virus.strain_data = virus.strain_data.Copy()
		src.virus.affected_mob = src
		src.virus.holder = src
		if(prob(5))
			src.virus.carrier = 1
		return
	return


/datum/disease/proc/spread(var/source=null)
	//world << "Disease [src] proc spread was called from holder [source]"
	if(spread_type == SPECIAL)//does not spread
		return

	if(stage < contagious_period) //the disease is not contagious at this stage
		return

	if(!source)//no holder specified
		if(affected_mob)//no mob affected holder
			source = affected_mob
		else //no source and no mob affected. Rogue disease. Break
			return


	var/check_range = AIRBORNE//defaults to airborne - range 4
	if(spread_type != AIRBORNE)
		check_range = 0

	for(var/mob/living/carbon/M in oviewers(check_range, source))
		M.contract_disease(src)

	return


/datum/disease/proc/process()
	if(!holder) return
	if(prob(40))
		spread(holder)
	if(holder == affected_mob)
		if(affected_mob.stat < 2) //he's alive
			stage_act()
		else //he's dead.
			if(spread_type!=SPECIAL)
				spread_type = CONTACT_GENERAL
			affected_mob = null
	if(!affected_mob) //the virus is in inanimate obj
//		world << "[src] longevity = [longevity]"
		if(--longevity<=0)
			cure(0)
	return

/datum/disease/proc/cure(var/resistance=1)//if resistance = 0, the mob won't develop resistance to disease
	if(resistance && affected_mob && !(type in affected_mob.resistances))
//		world << "Setting res to [src]"
		var/saved_type = "[type]"//copy the value, not create the reference to it, so when the object is deleted, the value remains.
		affected_mob.resistances += text2path(saved_type)
	if(istype(src, /datum/disease/alien_embryo))//Get rid of the flag.
		affected_mob.alien_egg_flag = 0
//	world << "Removing [src]"
	spawn(0)
		del(src)
	return


/datum/disease/New(var/process=1)//process = 1 - adding the object to global list. List is processed by master controller.
	cure_list = list(cure_id) // to add more cures, add more vars to this list in the actual disease's New()
	if(process)					 // Viruses in list are considered active.
		active_diseases += src

/*
/datum/disease/Del()
	active_diseases.Remove(src)
*/
