/obj/item/brain/examine() // -- TLE
	set src in oview(12)
	if (!( usr ))
		return
	usr << "This is \icon[src] \an [name]."

	if(brainmob)//if thar be a brain inside... the brain.
		usr << "You can feel the small spark of life still left in this one."
	else
		usr << "This one seems particularly lifeless. Perhaps it will regain some of its luster later. Probably not."

/obj/item/brain/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M, /mob))
		return

	add_fingerprint(user)

	if(!(user.zone_sel.selecting == ("head")) || !istype(M, /mob/living/carbon/human))
		return ..()

	if(	!(locate(/obj/machinery/optable, M.loc) && M.resting) && ( !(locate(/obj/structure/table/, M.loc) && M.lying) && prob(50) ) )
		return ..()

	var/mob/living/carbon/human/H = M
	if(istype(M, /mob/living/carbon/human) && ((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
		// you can't stab someone in the eyes wearing a mask!
		user << "\blue You're going to need to remove their head cover first."
		return

//since these people will be dead M != usr

	if(M:brain_op_stage == 4.0)
		for(var/mob/O in viewers(M, null))
			if(O == (user || M))
				continue
			if(M == user)
				O.show_message(text("\red [user] inserts [src] into his head!"), 1)
			else
				O.show_message(text("\red [M] has [src] inserted into his head by [user]."), 1)

		if(M != user)
			M << "\red [user] inserts [src] into your head!"
			user << "\red You insert [src] into [M]'s head!"
		else
			user << "\red You insert [src] into your head!"

		//this might actually be outdated since barring badminnery, a debrain'd body will have any client sucked out to the brain's internal mob. Leaving it anyway to be safe. --NEO
		if(M.key)//Revised. /N
			M.ghostize()

		if(brainmob.mind)
			brainmob.mind.transfer_to(M)
		else
			M.key = brainmob.key

		M:brain_op_stage = 3.0

		del(src)
	else
		..()
	return