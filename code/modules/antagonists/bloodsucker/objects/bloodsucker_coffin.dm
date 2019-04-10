

// TRAIT_DEATHCOMA -  Activate this when you're in your coffin to simulate sleep/death.


// Coffins...
//	-heal all wounds, and quickly.
//	-restore limbs & organs
//

// Without Coffins...
//	-
//	-limbs stay lost



// To put to sleep:  use 		owner.current.fakedeath("bloodsucker") but change name to "bloodsucker_coffin" so you continue to stay fakedeath despite healing in the main thread!




// crate.dm
/obj/structure/closet/crate/
	var/mob/living/resident	// This lets bloodsuckers claim any "closet" as a Coffin, so long as they could get into it and close it. This locks it in place, too.


/obj/structure/closet/crate/coffin/
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


//////////////////////////////////////////////

/obj/structure/closet/crate/proc/ClaimCoffin(mob/living/claimant) // NOTE: This can be any "closet" that you are resting AND inside of.
	if (resident)
		if (claimant == resident)
			to_chat(claimant, "This is your .")
		else
			to_chat(claimant, "This [src] has already been claimed by another.")
		return
	to_chat(claimant, "<span class='danger'>You have claimed the [src] as your coffin!</span>")
	resident = claimant
	anchored = 1					// No moving this


/obj/structure/closet/crate/coffin/Destroy()
	if (resident)
		to_chat(resident, "<span class='danger'><span class='italics'>You sense that your [src], your sacred place of rest, has been destroyed! You will need to seek another...</span></span>")
		resident = null // Remove resident. Because this object isnt removed from the game immediately (GC?) we need to give them a way to see they don't have a home anymore.
	return ..()



/obj/structure/closet/crate/coffin/can_open(mob/living/user)
	// You cannot lock in/out a coffin's owner. SORRY.
	if (locked)
		if(user == resident)
			if (welded)
				welded = FALSE
				update_icon()
			to_chat(user, "<span class='notice'>You flip a secret latch and unlock the [src].</span>")
			locked = FALSE
			return 1
		else
			playsound(get_turf(src), 'sound/machines/door_locked.ogg', 20, 1)
			to_chat(user, "<span class='notice'>The [src] is locked tight from the inside.</span>")
	return ..()

/obj/structure/closet/crate/coffin/close(mob/living/user)
	if (!..())
		return 0
	// Creator inside Coffin? Doesn't matter who closed it! Lock it up if he's awake.
	if (resident)
		if ((resident in src) && resident.stat == CONSCIOUS)
			if (!broken)
				locked = TRUE
				to_chat(resident, "<span class='notice'>You flip a secret latch and lock yourself inside the [src].</span>")
			else
				to_chat(resident, "<span class='notice'>The secret latch to lock the [src] from the inside is broken. You set it back into place...</span>")
				if (do_mob(resident, src, 50))//sleep(10)
					to_chat(resident, "<span class='notice'>You fix the mechanism.</span>")
					broken = FALSE
					locked = TRUE
			// Play Sound: locktoggle.ogg  ?
	return 1


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
/datum/crafting_recipe/blackcoffin
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
	category = CAT_MISC

