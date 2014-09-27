/datum/organ
	var/name = "organ"
	var/mob/living/carbon/human/owner = null
	var/status = 0
	var/vital //Lose a vital limb, die immediately.

	var/list/datum/autopsy_data/autopsy_data = list()
	var/list/trace_chemicals = list() // traces of chemicals in the organ,
									  // links chemical IDs to number of ticks for which they'll stay in the blood

	var/germ_level = 0		// INTERNAL germs inside the organ, this is BAD if it's greater than INFECTION_LEVEL_ONE

	proc/process()
		return 0

	proc/receive_chem(chemical as obj)
		return 0

/datum/organ/proc/get_icon(var/icon/race_icon, var/icon/deform_icon)
	return icon('icons/mob/human.dmi',"blank")

//Germs
/datum/organ/proc/handle_antibiotics()
	var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")

	if (!germ_level || antibiotics < 5)
		return

	if (germ_level < INFECTION_LEVEL_ONE)
		germ_level = 0	//cure instantly
	else if (germ_level < INFECTION_LEVEL_TWO)
		germ_level -= 6	//at germ_level == 500, this should cure the infection in a minute
	else
		germ_level -= 2 //at germ_level == 1000, this will cure the infection in 5 minutes

//Handles chem traces
/mob/living/carbon/human/proc/handle_trace_chems()
	//New are added for reagents to random organs.
	for(var/datum/reagent/A in reagents.reagent_list)
		var/datum/organ/O = pick(organs)
		O.trace_chemicals[A.name] = 100

//Adds autopsy data for used_weapon.
/datum/organ/proc/add_autopsy_data(var/used_weapon, var/damage)
	var/datum/autopsy_data/W = autopsy_data[used_weapon]
	if(!W)
		W = new()
		W.weapon = used_weapon
		autopsy_data[used_weapon] = W

	W.hits += 1
	W.damage += damage
	W.time_inflicted = world.time

/mob/living/carbon/human/var/list/organs = list()
/mob/living/carbon/human/var/list/organs_by_name = list() // map organ names to organs
/mob/living/carbon/human/var/list/internal_organs_by_name = list() // so internal organs have less ickiness too

// Takes care of organ related updates, such as broken and missing limbs
/mob/living/carbon/human/proc/handle_organs()

	number_wounds = 0
	var/leg_tally = 2
	var/force_process = 0
	var/damage_this_tick = getBruteLoss() + getFireLoss() + getToxLoss()
	if(damage_this_tick > last_dam)
		force_process = 1
	last_dam = damage_this_tick
	if(force_process)
		bad_external_organs.Cut()
		for(var/datum/organ/external/Ex in organs)
			bad_external_organs += Ex

	//processing internal organs is pretty cheap, do that first.
	for(var/datum/organ/internal/I in internal_organs)
		I.process()

	// Also handles some internal organ processing when the organs are missing completely.
	// Only handles missing liver and kidneys for now.
    // This is a bit harsh, but really if you're missing an entire bodily organ you're in deep shit.
	if(species.has_organ["liver"])
		var/datum/organ/internal/liver = internal_organs_by_name["liver"]
		if(!liver || liver.status & ORGAN_CUT_AWAY)
			reagents.add_reagent("toxin", rand(1,3))

	if(species.has_organ["kidneys"])
		var/datum/organ/internal/kidney = internal_organs_by_name["kidneys"]
		if(!kidney || kidney.status & ORGAN_CUT_AWAY)
			reagents.add_reagent("toxin", rand(1,3))

	if(!force_process && !bad_external_organs.len)
		return

	for(var/datum/organ/external/E in bad_external_organs)
		if(!E)
			continue
		if(!E.need_process())
			bad_external_organs -= E
			continue
		else
			E.process()
			number_wounds += E.number_wounds

			//Robotic limb malfunctions
			var/malfunction = 0
			if (E.status & ORGAN_ROBOT && prob(E.brute_dam + E.burn_dam))
				malfunction = 1

			//Broken limbs hurt too
			var/broken = 0
			if(E.status & ORGAN_BROKEN && !(E.status & ORGAN_SPLINTED) )
				broken = 1

			//Moving around with fractured ribs won't do you any good
			if (broken && E.internal_organs && prob(15))
				if (!lying && world.timeofday - l_move_time < 15)
					var/datum/organ/internal/I = pick(E.internal_organs)
					custom_pain("You feel broken bones moving in your [E.display_name]!", 1)
					I.take_damage(rand(3,5))

			//Special effects for limbs.
			if(E.name in list("l_hand","l_arm","r_hand","r_arm") && (broken||malfunction))
				var/obj/item/c_hand		//Getting what's in this hand
				if(E.name == "l_hand" || E.name == "l_arm")
					c_hand = l_hand
				if(E.name == "r_hand" || E.name == "r_arm")
					c_hand = r_hand

				if (c_hand)
					u_equip(c_hand)

					if(broken)
						emote("me", 1, "[(species && species.flags & NO_PAIN) ? "" : "screams in pain and"] drops what they were holding in their [E.display_name?"[E.display_name]":"[E]"]!")
					if(malfunction)
						emote("me", 1, "drops what they were holding, their [E.display_name?"[E.display_name]":"[E]"] malfunctioning!")
						var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
						spark_system.set_up(5, 0, src)
						spark_system.attach(src)
						spark_system.start()
						spawn(10)
							del(spark_system)

			else if(E.name in list("l_leg","l_foot","r_leg","r_foot") && !lying)
				if (!E.is_usable() || malfunction || (broken && !(E.status & ORGAN_SPLINTED)))
					leg_tally--			// let it fail even if just foot&leg

	// standing is poor
	if(leg_tally <= 0 && !paralysis && !(lying || resting) && prob(5))
		if(species && species.flags & NO_PAIN)
			emote("scream")
		emote("collapse")
		paralysis = 10
	
	//Check arms and legs for existence
	can_stand = 2 //can stand on both legs
	var/datum/organ/external/E = organs_by_name["l_foot"]
	if(E.status & ORGAN_DESTROYED)
		can_stand--

	E = organs_by_name["r_foot"]
	if(E.status & ORGAN_DESTROYED)
		canstand--

	legispeg_r=E.status & ORGAN_PEG


	// We CAN stand if we're on a peg.
	E = get_organ("l_foot")
	if(E.status & ORGAN_DESTROYED && !(E.status & ORGAN_SPLINTED) && !legispeg_l)
		canstand_l = 0
	E = get_organ("r_foot")
	if(E.status & ORGAN_DESTROYED && !(E.status & ORGAN_SPLINTED) && !legispeg_r)
		canstand_r = 0
	E = get_organ("l_arm")
	if(E.status & ORGAN_DESTROYED && !(E.status & ORGAN_SPLINTED))
		hasarm_l = 0
	E = get_organ("r_arm")
	if(E.status & ORGAN_DESTROYED && !(E.status & ORGAN_SPLINTED))
		hasarm_r = 0

	// Can stand if have at least one full leg (with leg and foot parts present, or an entire pegleg)
	// Has limbs to move around if at least one arm or leg is at least partially there
	can_stand = canstand_l||canstand_r
	has_limbs = hasleg_l||hasleg_r||hasarm_l||hasarm_r
