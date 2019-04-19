

// TRAIT_DEATHCOMA -  Activate this when you're in your coffin to simulate sleep/death.


// Coffins...
//	-heal all wounds, and quickly.
//	-restore limbs & organs
//

// Without Coffins...
//	-
//	-limbs stay lost



// To put to sleep:  use 		owner.current.fakedeath("bloodsucker") but change name to "bloodsucker_coffin" so you continue to stay fakedeath despite healing in the main thread!


/datum/antagonist/bloodsucker/proc/ClaimCoffin(obj/structure/closet/crate/claimed) // NOTE: This can be any "closet" that you are resting AND inside of.
	// ALREADY CLAIMED
	if (claimed.resident)
		if (claimed.resident == owner.current)
			to_chat(owner, "This is your [src].")
		else
			to_chat(owner, "This [src] has already been claimed by another.")
		return FALSE

	// Bloodsucker Learns new Recipes!
	owner.teach_crafting_recipe(/datum/crafting_recipe/bloodsucker/vassalrack)

	// This is my Lair
	coffin = claimed
	lair = get_area(claimed)
	// DONE
	to_chat(owner, "<span class='userdanger'>You have claimed the [claimed] as your place of immortal rest! Your lair is now the [lair].</span>")
	to_chat(owner, "<span class='danger'>You have learned new construction recipes to improve your lair.</span>")

	RunLair() // Start
	return TRUE


/datum/antagonist/bloodsucker/proc/RunLair()
	set waitfor = FALSE // Don't make on_gain() wait for this function to finish. This lets this code run on the side.

	while (!AmFinalDeath() && coffin && lair)

		// Coffin Moved SOMEHOW?
		if (lair != get_area(coffin))
			lair = get_area(coffin)
			break

		// WAit 10 Sec and Repeat
		sleep(100)
	// Done (somehow)
	lair = null



// crate.dm
/obj/structure/closet/crate
	var/mob/living/resident	// This lets bloodsuckers claim any "closet" as a Coffin, so long as they could get into it and close it. This locks it in place, too.

/obj/structure/closet/crate/coffin
	var/pryLidTimer = 250
	can_weld_shut = FALSE
	breakout_time = 300


/obj/structure/closet/crate/coffin/blackcoffin // closet.dmi, closets.dm, and job_closets.dm
	name = "Black Coffin"
	desc = "For those departed who are not so dear."
	icon_state = "coffin"
	icon = 'icons/Fulpicons/fulpobjects.dmi'
	can_weld_shut = FALSE
	resistance_flags = 0			// Start off with no bonuses.
	open_sound = 'sound/Fulpsounds/coffin_open.ogg'//'sound/machines/door_open.ogg'
	close_sound = 'sound/Fulpsounds/coffin_close.ogg'//'sound/machines/door_close.ogg'
	breakout_time = 600
	pryLidTimer = 600
	resistance_flags = NONE



//////////////////////////////////////////////

/obj/structure/closet/crate/proc/ClaimCoffin(mob/living/claimant) // NOTE: This can be any "closet" that you are resting AND inside of.
	// Bloodsucker Claim
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = claimant.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	if (bloodsuckerdatum)
		// Vamp Successfuly Claims Me?
		if (bloodsuckerdatum.ClaimCoffin(src))
			resident = claimant
			anchored = 1					// No moving this


/obj/structure/closet/crate/coffin/Destroy()
	if (resident)
		to_chat(resident, "<span class='danger'><span class='italics'>You sense that your [src], your sacred place of rest, has been destroyed! You will need to seek another...</span></span>")
		resident = null // Remove resident. Because this object isnt removed from the game immediately (GC?) we need to give them a way to see they don't have a home anymore.
		// Vamp Un-Claim
		var/datum/antagonist/bloodsucker/bloodsuckerdatum = resident.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
		if (bloodsuckerdatum && bloodsuckerdatum.coffin == src)
			bloodsuckerdatum.coffin = null
			bloodsuckerdatum.lair = null
	return ..()


/obj/structure/closet/crate/coffin/can_open(mob/living/user)
	// You cannot lock in/out a coffin's owner. SORRY.
	if (locked)
		if(user == resident)
			if (welded)
				welded = FALSE
				update_icon()
			//to_chat(user, "<span class='notice'>You flip a secret latch and unlock the [src].</span>") // Don't bother. We know it's unlocked.
			locked = FALSE
			return 1
		else
			playsound(get_turf(src), 'sound/machines/door_locked.ogg', 20, 1)
			to_chat(user, "<span class='notice'>The [src] is locked tight from the inside.</span>")
	return ..()

/obj/structure/closet/crate/coffin/close(mob/living/user)
	if (!..())
		return FALSE
	// Only the User can put themself into Torpor (if you're already in it, you'll start to heal)
	if ((user in src))
		// Bloodsucker Only
		var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
		if (bloodsuckerdatum)
			// Claim?
			if (!bloodsuckerdatum.coffin && !resident)
				switch(alert(user,"Do you wish to claim this as your coffin?",,"Yes", "No"))
					if("Yes")
						ClaimCoffin(user)
			// Lock
			if (user == resident)
				if (!broken)
					locked = TRUE
					to_chat(user, "<span class='notice'>You flip a secret latch and lock yourself inside the [src].</span>")
				else
					to_chat(resident, "<span class='notice'>The secret latch to lock the [src] from the inside is broken. You set it back into place...</span>")
					if (do_mob(resident, src, 50))//sleep(10)
						to_chat(resident, "<span class='notice'>You fix the mechanism.</span>")
						broken = FALSE
						locked = TRUE
			// Heal
			to_chat(bloodsuckerdatum.owner.current, "<span class='danger'>TEST COFFIN: [bloodsuckerdatum.HandleHealing(0.1)]</span>")
			if (bloodsuckerdatum.HandleHealing(0)) // Healing Mult 0 <--- We only want to check if healing is valid!
				to_chat(bloodsuckerdatum.owner.current, "<span class='danger'>You enter the horrible slumber of deathless Torpor. You will heal until you are renewed.</span>")
				bloodsuckerdatum.Torpor_Begin()
	return TRUE

/obj/structure/closet/crate/coffin/attackby(obj/item/W, mob/user, params)
	// You cannot weld or deconstruct an owned coffin. STILL NOT SORRY.
	if (resident != null && user != resident) // Owner can destroy their own coffin.
		if(opened)
			if(istype(W, cutting_tool))
				to_chat(user, "<span class='notice'>This is a much more complex mechanical structure than you thought. You don't know where to begin cutting the [src].</span>")
				return
	if(locked && istype(W, /obj/item/crowbar))
		var/pry_time = pryLidTimer * W.toolspeed // Pry speed must be affected by the speed of the tool.
		user.visible_message("<span class='notice'>[user] tries to pry the lid off of the [src] with the [W].</span>", \
							  "<span class='notice'>You begin prying the lid off of the [src] with the [W]. This should take about [DisplayTimeText(pry_time)].</span>")
		if (!do_mob(user,src,pry_time))
			return
		bust_open()
		user.visible_message("<span class='notice'>[user] snaps the door of the [src] wide open.</span>", \
							  "<span class='notice'>The door of the [src] snaps open.</span>")
		return
	..()











// Look up recipes.dm OR pneumaticCannon.dm
/datum/crafting_recipe/bloodsucker/blackcoffin
	name = "Black Coffin"
	result = /obj/structure/closet/crate/coffin/blackcoffin
	tools = list(/obj/item/weldingtool,
				 /obj/item/screwdriver)
	reqs = list(/obj/item/stack/sheet/cloth = 4,
				/obj/item/stack/sheet/mineral/wood = 5,
				/obj/item/stack/sheet/metal = 2)
				///obj/item/stack/packageWrap = 8,
				///obj/item/pipe = 2)
	time = 150
	category = CAT_STRUCTURE
	always_availible = TRUE
