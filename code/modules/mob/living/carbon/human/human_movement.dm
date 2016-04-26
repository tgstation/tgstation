/mob/living/carbon/human/movement_delay()
	if(istype(loc, /turf/space)) return -1 // It's hard to be slowed down in space by... anything

	if(flying) return -1

	if(istype(loc,/turf/simulated/floor))
		var/turf/simulated/floor/T = loc
		if(T.material=="phazon")
			return -1 // Phazon floors make us go fast

	var/tally = 0
	if(species && species.move_speed_mod)
		tally += species.move_speed_mod

	if(dna.mutantrace == "slime")
		if (bodytemperature >= 330.23) // 135 F
			return -1	// slimes become supercharged at high temperatures
		if (bodytemperature < 183.222)
			tally += (283.222 - bodytemperature) / 10 * 1.75
	else if (undergoing_hypothermia())
		tally += 2*undergoing_hypothermia()

	//(/vg/ EDIT disabling for now) handle_embedded_objects() //Moving with objects stuck in you can cause bad times.

	if(reagents.has_reagent("nuka_cola")) tally -= 10

	if((M_RUN in mutations)) tally -= 10

	var/health_deficiency = (100 - health - halloss)
	if(health_deficiency >= 40) tally += (health_deficiency / 25)

	var/hungry = (500 - nutrition)/5 // So overeat would be 100 and default level would be 80
	if (hungry >= 70) tally += hungry/50

	if(wear_suit)
		tally += wear_suit.slowdown

	if(shoes)
		tally += shoes.slowdown

	if(l_hand && (l_hand.flags & SLOWDOWN_WHEN_CARRIED))
		tally += l_hand.slowdown

	if(r_hand && (r_hand.flags & SLOWDOWN_WHEN_CARRIED))
		tally += r_hand.slowdown

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

	var/skate_bonus = 0
	var/disease_slow = 0
	for(var/obj/item/weapon/bomberman/dispenser in src)
		disease_slow = max(disease_slow, dispenser.slow)
		skate_bonus = max(skate_bonus, dispenser.speed_bonus)//if the player is carrying multiple BBD for some reason, he'll benefit from the speed bonus of the most upgraded one
	tally = tally - skate_bonus + (6 * disease_slow)

	if(reagents.has_reagent("hyperzine"))
		if(dna.mutantrace == "slime")
			tally *= 2
		else
			tally -= 10

	if(reagents.has_reagent("frostoil") && dna.mutantrace == "slime")
		tally *= 5

	return max((tally+config.human_delay), -1) //cap at -1 as the 'fastest'

/mob/living/carbon/human/Process_Spacemove(var/check_drift = 0)
	//Can we act
	if(restrained())	return 0

	//Are we flying?
	if(flying)
		inertia_dir = 0
		return 1

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
	if(CheckSlip() < 0)
		prob_slip = 0

	//Check hands and mod slip
	if(!l_hand)	prob_slip -= 2
	else if(l_hand.w_class <= 2)	prob_slip -= 1
	if (!r_hand)	prob_slip -= 2
	else if(r_hand.w_class <= 2)	prob_slip -= 1

	prob_slip = round(prob_slip)
	return(prob_slip)

/mob/living/carbon/human/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	var/old_z = src.z

	. = ..(NewLoc, Dir, step_x, step_y)

	/*if(status_flags & FAKEDEATH)
		return 0*/

	if(.)
		if (old_z != src.z) crewmonitor.queueUpdate(old_z)
		crewmonitor.queueUpdate(src.z)

		if(shoes && istype(shoes, /obj/item/clothing/shoes))
			var/obj/item/clothing/shoes/S = shoes
			S.step_action()

		if(wear_suit && istype(wear_suit, /obj/item/clothing/suit))
			var/obj/item/clothing/suit/SU = wear_suit
			SU.step_action()

		for(var/obj/item/weapon/bomberman/dispenser in src)
			if(dispenser.spam_bomb)
				dispenser.attack_self(src)

		var/obj/item/weapon/rcl/R = get_active_hand()
		if(R && istype(R) && R.active)
			R.trigger(src)

/mob/living/carbon/human/CheckSlip()
	. = ..()
	if(. && shoes && shoes.flags & NOSLIP)
		. = (istype(shoes, /obj/item/clothing/shoes/magboots) ? -1 : 0)
	return .
