
/mob/proc/HasDisease(datum/disease/D)
	for(var/datum/disease/DD in viruses)
		if(D.IsSame(DD))
			return 1
	return 0


/mob/proc/CanContractDisease(datum/disease/D)
	if(stat == DEAD)
		return 0

	if(D.GetDiseaseID() in resistances)
		return 0

	if(HasDisease(D))
		return 0

	if(!(type in D.viable_mobtypes))
		return 0

	return 1


/mob/proc/ContractDisease(datum/disease/D)
	if(!CanContractDisease(D))
		return 0
	AddDisease(D)


/mob/proc/AddDisease(datum/disease/D)
	for(var/datum/disease/advance/P in viruses)
		if(istype(D, /datum/disease/advance))
			var/datum/disease/advance/DD = D
			if (P.totalResistance() < DD.totalTransmittable()) //Overwrite virus if the attacker's Transmission is lower than the defender's Resistance. This does not grant immunity to the lost virus.
				P.remove_virus()

	if (!viruses.len) //Only add the new virus if it defeated the existing one
		var/datum/disease/DD = new D.type(1, D, 0)
		viruses += DD
		DD.affected_mob = src
		DD.holder = src

		//Copy properties over. This is so edited diseases persist.
		var/list/skipped = list("affected_mob","holder","carrier","stage","type","parent_type","vars","transformed")
		for(var/V in DD.vars)
			if(V in skipped)
				continue
			if(islist(DD.vars[V]))
				var/list/L = D.vars[V]
				DD.vars[V] = L.Copy()
			else
				DD.vars[V] = D.vars[V]

		DD.affected_mob.med_hud_set_status()


/mob/living/carbon/ContractDisease(datum/disease/D)
	if(!CanContractDisease(D))
		return 0

	var/obj/item/clothing/Cl = null
	var/passed = 1

	var/head_ch = 100
	var/body_ch = 100
	var/hands_ch = 25
	var/feet_ch = 25

	if(D.spread_flags & CONTACT_HANDS)
		head_ch = 0
		body_ch = 0
		hands_ch = 100
		feet_ch = 0
	if(D.spread_flags & CONTACT_FEET)
		head_ch = 0
		body_ch = 0
		hands_ch = 0
		feet_ch = 100

	if(prob(15/D.permeability_mod))
		return

	if(satiety>0 && prob(satiety/10)) // positive satiety makes it harder to contract the disease.
		return

	var/target_zone = pick(head_ch;1,body_ch;2,hands_ch;3,feet_ch;4)

	if(ishuman(src))
		var/mob/living/carbon/human/H = src

		switch(target_zone)
			if(1)
				if(isobj(H.head) && !istype(H.head, /obj/item/weapon/paper))
					Cl = H.head
					passed = prob((Cl.permeability_coefficient*100) - 1)
				if(passed && isobj(H.wear_mask))
					Cl = H.wear_mask
					passed = prob((Cl.permeability_coefficient*100) - 1)
				if(passed && isobj(H.wear_neck))
					Cl = H.wear_neck
					passed = prob((Cl.permeability_coefficient*100) - 1)
			if(2)
				if(isobj(H.wear_suit))
					Cl = H.wear_suit
					passed = prob((Cl.permeability_coefficient*100) - 1)
				if(passed && isobj(slot_w_uniform))
					Cl = slot_w_uniform
					passed = prob((Cl.permeability_coefficient*100) - 1)
			if(3)
				if(isobj(H.wear_suit) && H.wear_suit.body_parts_covered&HANDS)
					Cl = H.wear_suit
					passed = prob((Cl.permeability_coefficient*100) - 1)

				if(passed && isobj(H.gloves))
					Cl = H.gloves
					passed = prob((Cl.permeability_coefficient*100) - 1)
			if(4)
				if(isobj(H.wear_suit) && H.wear_suit.body_parts_covered&FEET)
					Cl = H.wear_suit
					passed = prob((Cl.permeability_coefficient*100) - 1)

				if(passed && isobj(H.shoes))
					Cl = H.shoes
					passed = prob((Cl.permeability_coefficient*100) - 1)

	else if(ismonkey(src))
		var/mob/living/carbon/monkey/M = src
		switch(target_zone)
			if(1)
				if(M.wear_mask && isobj(M.wear_mask))
					Cl = M.wear_mask
					passed = prob((Cl.permeability_coefficient*100) - 1)

	if(!passed && (D.spread_flags & AIRBORNE) && !internal)
		passed = (prob((50*D.permeability_mod) - 1))

	if(passed)
		AddDisease(D)


//Same as ContractDisease, except never overidden clothes checks
/mob/proc/ForceContractDisease(datum/disease/D)
	if(!CanContractDisease(D))
		return 0
	AddDisease(D)


/mob/living/carbon/human/CanContractDisease(datum/disease/D)
	if(dna && (VIRUSIMMUNE in dna.species.species_traits))
		return 0
	return ..()