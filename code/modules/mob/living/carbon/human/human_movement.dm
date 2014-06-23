/mob/living/carbon/human/movement_delay()
	var/tally = 0

	if(species && species.flags & IS_SLOW)
		tally = 7

	if (istype(loc, /turf/space)) return -1 // It's hard to be slowed down in space by... anything

	//(VG EDIT disabling for now) handle_embedded_objects() //Moving with objects stuck in you can cause bad times.

	if(reagents.has_reagent("hyperzine"))
		if(dna.mutantrace == "slime")
			tally *= 2
		else
			return -1

	if(reagents.has_reagent("nuka_cola")) return -1

	if((M_RUN in mutations)) return -1

	if (istype(loc, /turf/space)) return -1 // It's hard to be slowed down in space by... anything

	var/health_deficiency = (100 - health - halloss)
	if(health_deficiency >= 40) tally += (health_deficiency / 25)

	var/hungry = (500 - nutrition)/5 // So overeat would be 100 and default level would be 80
	if (hungry >= 70) tally += hungry/50

	if(wear_suit)
		tally += wear_suit.slowdown

	if(shoes)
		tally += shoes.slowdown

	if(reagents.has_reagent("frostoil") && dna.mutantrace == "slime")
		tally *= 5

	for(var/organ_name in list("l_foot","r_foot","l_leg","r_leg"))
		var/datum/organ/external/E = get_organ(organ_name)
		if(!E || (E.status & ORGAN_DESTROYED))
			tally += 4
		if(E.status & ORGAN_SPLINTED)
			tally += 0.5
		else if(E.status & ORGAN_BROKEN)
			tally += 1.5

	if(shock_stage >= 50) tally += 3

	if(M_FAT in src.mutations)
		tally += 1.5
	if(dna.mutantrace == "slime")
		if (bodytemperature >= 330.23) // 135 F
			return -1	// slimes become supercharged at high temperatures
		if (bodytemperature < 183.222)
			tally += (283.222 - bodytemperature) / 10 * 1.75
	else if (bodytemperature < 283.222)

		tally += (283.222 - bodytemperature) / 10 * 1.75

	if(M_RUN in mutations)
		tally = 0

	return (tally+config.human_delay)

/mob/living/carbon/human/Process_Spacemove(var/check_drift = 0)
	//Can we act
	if(restrained())	return 0

	//Do we have a working jetpack
	if(istype(back, /obj/item/weapon/tank/jetpack))
		var/obj/item/weapon/tank/jetpack/J = back
		if(((!check_drift) || (check_drift && J.stabilization_on)) && (!lying) && (J.allow_thrust(0.01, src)))
			inertia_dir = 0
			return 1
//		if(!check_drift && J.allow_thrust(0.01, src))
//			return 1

	//If no working jetpack then use the other checks
	if(..())	return 1
	return 0


/mob/living/carbon/human/Process_Spaceslipping(var/prob_slip = 5)
	//If knocked out we might just hit it and stop.  This makes it possible to get dead bodies and such.
	if(stat)
		prob_slip = 0 // Changing this to zero to make it line up with the comment, and also, make more sense.

	//Do we have magboots or such on if so no slip
	if(istype(shoes, /obj/item/clothing/shoes/magboots) && (shoes.flags & NOSLIP))
		prob_slip = 0

	//Check hands and mod slip
	if(!l_hand)	prob_slip -= 2
	else if(l_hand.w_class <= 2)	prob_slip -= 1
	if (!r_hand)	prob_slip -= 2
	else if(r_hand.w_class <= 2)	prob_slip -= 1

	prob_slip = round(prob_slip)
	return(prob_slip)
