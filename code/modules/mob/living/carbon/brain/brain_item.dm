/obj/item/organ/brain
	name = "brain"
	desc = "A piece of juicy meat found in a person's head."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "brain"
	force = 1.0
	w_class = 2.0
	throwforce = 0
	throw_speed = 3
	throw_range = 5
	origin_tech = "biotech=3"
	attack_verb = list("attacked", "slapped", "whacked")
	var/mob/living/carbon/brain/brainmob = null


/obj/item/organ/brain/New()
	..()
	//Shifting the brain "mob" over to the brain object so it's easier to keep track of. --NEO
	spawn(5)
		if(brainmob && brainmob.client)
			brainmob.client.screen.len = null //clear the hud


/obj/item/organ/brain/proc/transfer_identity(mob/living/carbon/H)
	name = "[H]'s brain"
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.dna = H.dna
	brainmob.timeofhostdeath = H.timeofdeath
	if(H.mind)
		H.mind.transfer_to(brainmob)
	brainmob << "<span class='notice'>You feel slightly disoriented. That's normal when you're just a brain.</span>"


/obj/item/organ/brain/examine(mob/user)
	..()
	if(brainmob && brainmob.client)
		user << "You can feel the small spark of life still left in this one."
	else
		user << "This one seems particularly lifeless. Perhaps it will regain some of its luster later."


/obj/item/organ/brain/attack(mob/living/carbon/M, mob/user)
	if(!istype(M))
		return ..()

	add_fingerprint(user)

	if(user.zone_sel.selecting != "head")
		return ..()

	var/mob/living/carbon/human/H = M
	if(istype(M, /mob/living/carbon/human) && ((H.head && H.head.flags_cover & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags_cover & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
		user << "<span class='warning'>You're going to need to remove their head cover first!</span>"
		return

//since these people will be dead M != usr

	if(!M.getorgan(/obj/item/organ/brain))
		user.drop_item()
		for(var/mob/O in viewers(M, null))
			if(O == (user || M))
				continue
			if(M == user)
				O << "[user] inserts [src] into \his head!"
			else
				O << "[M] has [src] inserted into \his head by [user]."

		if(M != user)
			M << "<span class='notice'>[user] inserts [src] into your head.</span>"
			user << "<span class='notice'>You insert [src] into [M]'s head.</span>"
		else
			user << "<span class='notice'>You insert [src] into your head.</span>"	//LOL

		//this might actually be outdated since barring badminnery, a debrain'd body will have any client sucked out to the brain's internal mob. Leaving it anyway to be safe. --NEO
		if(M.key)
			M.ghostize()

		if(brainmob.mind)
			brainmob.mind.transfer_to(M)
		else
			M.key = brainmob.key

		qdel(brainmob)

		M.internal_organs += src
		loc = null

		//Update the body's icon so it doesnt appear debrained anymore
		if(ishuman(M))
			H.update_hair(0)

	else
		..()

/obj/item/organ/brain/alien
	name = "alien brain"
	desc = "We barely understand the brains of terrestial animals. Who knows what we may find in the brain of such an advanced species?"
	icon_state = "brain-alien"
	origin_tech = "biotech=7"

/obj/item/organ/brain/Destroy() //copypasted from MMIs.
	if(brainmob)
		qdel(brainmob)
		brainmob = null
	..()
