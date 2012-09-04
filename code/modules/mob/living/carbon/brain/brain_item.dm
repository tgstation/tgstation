/obj/item/brain
	name = "brain"
	desc = "A piece of juicy meat found in a persons head."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "brain2"
	flags = TABLEPASS
	force = 1.0
	w_class = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	origin_tech = "biotech=3"
	attack_verb = list("attacked", "slapped", "whacked")

	var/mob/living/carbon/brain/brainmob = null

	New()
		..()
		//Shifting the brain "mob" over to the brain object so it's easier to keep track of. --NEO
		//WASSSSSUUUPPPP /N
		spawn(5)
			if(brainmob && brainmob.client)
				brainmob.client.screen.len = null //clear the hud

	proc
		transfer_identity(var/mob/living/carbon/human/H)
			name = "[H]'s brain"
			brainmob = new(src)
			brainmob.name = H.real_name
			brainmob.real_name = H.real_name
			brainmob.dna = H.dna
			brainmob.timeofhostdeath = H.timeofdeath
			if(H.mind)
				H.mind.transfer_to(brainmob)
			brainmob << "\blue You might feel slightly disoriented. That's normal when your brain gets cut out."
			return

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