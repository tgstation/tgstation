/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//obj/effect/proc_holder/spell/targeted/touch/expelblood
/obj/effect/proc_holder/spell/bloodsucker/expelblood
	name = "Expel Blood"
	desc = "Secrete some of your blood as an addictive, healing goo. Enough of it can turn living victims into your willing slaves, and (at a high enough Rank) feeding it to corpses turns mortals to Bloodsuckers."
	bloodcost = 10
	amToggleable = TRUE
	amTargetted = TRUE
	targetmessage_ON =  "<span class='notice'>You open your wrist. Choose what, or whom, will receive your blood.</span>"
	targetmessage_OFF = "<span class='notice'>The wound on your wrist heals instantly.</span>"
	//charge_max = 10
	action_icon_state = "power_bleed"				// State for that image inside icon


// TARGET VALID? //	// USE THIS TO DETERMINE IF TARGET IS VALID //
/obj/effect/proc_holder/spell/bloodsucker/expelblood/can_target(atom/A)//mob/living/target)
	if (!..())
		return 0

	var/atom/target = A
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = usr.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)

	// REMEMBER: We return 1 if we want to go on to the "Cast" portion. That means targetting turf should NOT continue.

	// Out of Range
	if (!(target in range(1, get_turf(usr))))
		return 0
	// Target Self
	if(target == usr)
		to_chat(usr, "<span class='notice'>You cannot target yourself.</span>")
		return 0
	// Target Type: Carbon
	if (iscarbon(target))
		var/mob/living/carbon/M = target
		// Target Mouth Covered
		if (M.is_mouth_covered()) // if(!canconsume(M, usr))
			to_chat(usr, "<span class='notice'>[target] has [M.p_their()] mouth covered.</span>")
			return 0
		// Message
		M.visible_message("<span class='notice'>[usr] places their wrist to [M]'s mouth.</span>", \
						  "<span class='userdanger'>[usr] puts their bloodied wrist to your mouth!</span>")
		// Timer...
		var/drink_time = (M.stat > CONSCIOUS || usr.pulling == M && usr.grab_state >= GRAB_AGGRESSIVE) ? 30 : 60
		if(!do_mob(usr, M, drink_time)) // Slower if they are awake and not being grabbed.
			to_chat(usr, "<span class='notice'>The transfer was interrupted!</span>")
			return 0
		// Success Message
		to_chat(usr, "<span class='notice'>[M] consumes some blood from your veins.</span>")
		if (!M.stat)
			to_chat(M, "<span class='notice'>You consume some blood from the veins of [usr].</span>")
		playsound(M.loc,'sound/items/drink.ogg', rand(30,40), 1)
		return 1

	// Target Type: Living (but NOT Carbon)
	else if (isliving(target))
		to_chat(usr, "<span class='notice'>[target] cannot take your blood.</span>")
		return 0

	// Target Type: Coffin
	else if (istype(target, /obj/structure/closet/coffin))
		// Timer...
		if(!do_mob(usr, target, 30))
			return 0
		if (bloodsuckerdatum.coffin)
			if (target == bloodsuckerdatum.coffin)
				to_chat(usr, "<span class='notice'>This [target] is already bound to you.</span>")
			else
				to_chat(usr, "<span class='notice'>You have already claimed a coffin as your own.</span>")
			cancel_spell(usr)
			return 0
		usr.visible_message("<span class='notice'>[usr] smears ichorous blood along the inside of the [target].</span>", \
				  "<span class='notice'>You smear ichorous blood along the inside of the [target], marking it as yours.</span>")
		var/obj/structure/closet/coffin/targetCoffin = target
		if (targetCoffin.ClaimCoffin(usr))
			pay_blood_cost()
			bloodsuckerdatum.coffin = targetCoffin
			playsound(usr.loc,'sound/effects/splat.ogg', rand(30,40), 1)	//return 0
			usr.playsound_local(null, 'sound/effects/singlebeat.ogg', 30, 1) // Play THIS sound for user only. The "null" is where turf would go if a location was needed. Null puts it right in their head.
		cancel_spell(usr)
		return 0

	// Target Type: Container
	else if (istype(target, /obj/item/reagent_containers))
		if (target.reagents.maximum_volume - target.reagents.total_volume > 0) // Only tell them they succeeded if there is space for blood.
			to_chat(usr, "<span class='notice'>You expel some blood into the [target].</span>")
		return 1

	// Target Type: Floor
	else if (isturf(target))
		// Timer...
		if(!do_mob(usr, target, 30))
			//to_chat(usr, "<span class='notice'>The desecration was interrupted!</span>")
			return 0
		// Create Splat
		var/obj/effect/decal/cleanable/blood/vampblood/b = new /obj/effect/decal/cleanable/blood/vampblood(target, usr.mind, bloodcost)
		b.MatchToCreator(usr) // Set Creator, DNA, and Diseases
		// Subtract Blood, Play Sound.
		pay_blood_cost()
		playsound(b.loc,'sound/effects/splat.ogg', rand(30,40), 1)	//return 0
		to_chat(usr, "<span class='notice'>You desecrate the [get_area(target)].</span>")
		cancel_spell(usr)
		return 0
	//Target Type: Item, etc. (FAIL)
	else
		return 0

// APPLY EFFECT //	// USE THIS FOR THE SPELL EFFECT //
/obj/effect/proc_holder/spell/bloodsucker/expelblood/cast(list/targets, mob/living/user = usr)
	..() // DEFAULT

	var/atom/target = targets[1]
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)

		// BLOOD TRANSFER //
	var/maxTransfer = min(bloodcost, user.blood_volume)
	//to_chat(user, "<span class='notice'>DEBUG: Expel Blood - [target]</span>")
	//to_chat(user, "<span class='notice'>DEBUG: Expel Blood - [target.reagents]</span>")
	maxTransfer = min(maxTransfer, target.reagents.maximum_volume - target.reagents.total_volume)
	if (maxTransfer == 0)
		to_chat(user, "<span class='notice'>That container is full.</span>")
		return 1
	// Deduct from Bloodsucker...

	// Spend Blood
	pay_blood_cost(cost=maxTransfer)

		// Get Vamp's Blood Data //

	// Create Temporary Reagent Container and Fill It
	var/datum/reagents/tempreagents = new(999) // 999 Max Cap.  																// NOTE: Why are we creating a NEW reagents container and not just transferring from the Vamp's reagents? Because we don't want
	tempreagents.add_reagent("vampblood", maxTransfer, user.get_blood_data(user.get_blood_id()), user.bodytemperature)	// reaction() to react with EVERYTHING in the Vamp's stomach. So we create a tidy little container, share it, and destroy it.
	// Give Blood To, and Apply Effects against target's contained reagents
	tempreagents.reaction(target, INGEST)//  , 1) // The 1 means transfer all contents.
	tempreagents.trans_to(target, tempreagents.total_volume)
	// Kill Temporary Reagent Container
	qdel(tempreagents)

	// Create a Vassal or Bloodsucker?
	if (iscarbon(target))
		var/mob/living/carbon/C = target

		// Create Bloodsucker?
		bloodsuckerdatum.attempt_turn_bloodsucker(C)
		// Create Vassal? (if not Bloodsucker now)
		bloodsuckerdatum.attempt_turn_vassal(C)

	//cancel_spell(user)  	// TESTING: (This is if we WANT to end the spell here after successful use)
							// 			If we return 0 (below), this spell ends but you click your target anyhow. We need to return 1, but end spell here anyway.
	return 1


