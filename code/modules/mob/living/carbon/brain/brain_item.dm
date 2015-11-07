/obj/item/organ/internal/brain
	name = "brain"
	hardpoint = "brain"
	desc = "A piece of juicy meat found in a person's head."
	icon_state = "brain"
	throw_speed = 3
	throw_range = 5
	layer = 4.1
	zone = "head"
	slot = "brain"
	vital = 1
	origin_tech = "biotech=4"
	attack_verb = list("attacked", "slapped", "whacked")
	var/mob/living/carbon/brain/brainmob = null

/obj/item/organ/internal/brain/Insert(mob/living/carbon/M, special = 0)
	if(..())
		name = "brain"
		if(brainmob)
			if(M.key)
				M.ghostize()

			if(brainmob.mind)
				brainmob.mind.transfer_to(M)
			else
				M.key = brainmob.key

			qdel(brainmob)

			//Update the body's icon so it doesnt appear debrained anymore
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.update_hair(0)
		return 1
	return 0

/obj/item/organ/internal/brain/Remove(special = 0)
	..()
	if(!special)
		transfer_identity()
	if(owner && ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.update_hair(0)

/obj/item/organ/internal/brain/prepare_eat()
	return // Too important to eat.

/obj/item/organ/internal/brain/New()
	..()
	//Shifting the brain "mob" over to the brain object so it's easier to keep track of. --NEO
	spawn(5)
		if(brainmob && brainmob.client)
			brainmob.client.screen.len = null //clear the hud


/**
  * Transfers a person from their original mob to a brainmob inside of this brain.
  * Relies on the organ's owner now, so please call this BEFORE the brain is removed from a mob or the owner var will be set to null.
 **/
/obj/item/organ/internal/brain/proc/transfer_identity()
	if(!owner)
		return
	name = "[owner]'s brain"
	brainmob = new(src)
	brainmob.name = owner.real_name
	brainmob.real_name = owner.real_name
	brainmob.dna = owner.dna
	brainmob.timeofhostdeath = owner.timeofdeath
	if(owner.mind)
		owner.mind.transfer_to(brainmob)
	if(organdatum && organdatum.parent) //If the organdatum is not null, this brain is a suborgan. We check for the parent just in case.
		brainmob << "<span class='notice'>You feel slightly disoriented. That's normal when you're just \a [organdatum.parent]."
	else
		brainmob << "<span class='notice'>You feel slightly disoriented. That's normal when you're just a brain.</span>"


/obj/item/organ/internal/brain/examine(mob/user)
	..()
	if(brainmob && brainmob.client)
		user << "You can feel the small spark of life still left in this one."
	else
		user << "This one seems particularly lifeless. Perhaps it will regain some of its luster later."


/obj/item/organ/internal/brain/attack(mob/living/carbon/M, mob/user)
	if(!istype(M))
		return ..()

	add_fingerprint(user)

	if(user.zone_sel.selecting != "head")
		return ..()

	var/mob/living/carbon/human/H = M
	if(istype(M, /mob/living/carbon/human) && get_location_accessible(H, "head"))
		user << "<span class='warning'>You're going to need to remove their head cover first!</span>"
		return

//since these people will be dead M != usr

	var/B = null
	if(M.organsystem)
		var/datum/organ/C = M.getorgan("brain")
		B = C.organitem
	else
		B = M.getorgan(/obj/item/organ/internal/brain)
	if(!B)
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

		Insert(M)
	else
		..()

/obj/item/organ/internal/brain/Destroy() //copypasted from MMIs.
	if(brainmob)
		brainmob.ghostize()
		qdel(brainmob)
		brainmob = null
	..()

/obj/item/organ/internal/brain/alien
	name = "alien brain"
	desc = "We barely understand the brains of terrestial animals. Who knows what we may find in the brain of such an advanced species?"
	icon_state = "brain-alien"
	origin_tech = "biotech=7"