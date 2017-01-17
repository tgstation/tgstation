/obj/item/organ/brain
	name = "brain"
	desc = "A piece of juicy meat found in a person's head."
	icon_state = "brain"
	throw_speed = 3
	throw_range = 5
	layer = ABOVE_MOB_LAYER
	zone = "head"
	slot = "brain"
	vital = 1
	origin_tech = "biotech=5"
	attack_verb = list("attacked", "slapped", "whacked")
	var/mob/living/brain/brainmob = null
	var/damaged_brain = 0 //whether the brain organ is damaged.

/obj/item/organ/brain/Insert(mob/living/carbon/C, special = 0)
	..()
	name = "brain"
	if(brainmob)
		if(C.key)
			C.ghostize()

		if(brainmob.mind)
			brainmob.mind.transfer_to(C)
		else
			C.key = brainmob.key

		qdel(brainmob)

	//Update the body's icon so it doesnt appear debrained anymore
	C.update_hair()

/obj/item/organ/brain/Remove(mob/living/carbon/C, special = 0)
	..()
	if(!special)
		if(C.has_brain_worms())
			var/mob/living/simple_animal/borer/B = C.has_brain_worms()
			B.leave_victim() //Should remove borer if the brain is removed - RR
		transfer_identity(C)
	C.update_hair()

/obj/item/organ/brain/prepare_eat()
	return // Too important to eat.

/obj/item/organ/brain/proc/transfer_identity(mob/living/L)
	name = "[L.name]'s brain"
	brainmob = new(src)
	brainmob.name = L.real_name
	brainmob.real_name = L.real_name
	brainmob.timeofhostdeath = L.timeofdeath
	if(L.has_dna())
		var/mob/living/carbon/C = L
		if(!brainmob.stored_dna)
			brainmob.stored_dna = new /datum/dna/stored(brainmob)
		C.dna.copy_dna(brainmob.stored_dna)
	if(L.mind && L.mind.current && (L.mind.current.stat == DEAD))
		L.mind.transfer_to(brainmob)
	brainmob << "<span class='notice'>You feel slightly disoriented. That's normal when you're just a brain.</span>"

/obj/item/organ/brain/attackby(obj/item/O, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(brainmob)
		O.attack(brainmob, user) //Oh noooeeeee

/obj/item/organ/brain/examine(mob/user)
	..()

	if(brainmob)
		if(brainmob.client)
			if(brainmob.health <= HEALTH_THRESHOLD_DEAD)
				user << "It's lifeless and severely damaged."
			else
				user << "You can feel the small spark of life still left in this one."
		else
			user << "This one seems particularly lifeless. Perhaps it will regain some of its luster later."
	else
		user << "This one is completely devoid of life."

/obj/item/organ/brain/attack(mob/living/carbon/C, mob/user)
	if(!istype(C))
		return ..()

	add_fingerprint(user)

	if(user.zone_selected != "head")
		return ..()

	if((C.head && (C.head.flags_cover & HEADCOVERSEYES)) || (C.wear_mask && (C.wear_mask.flags_cover & MASKCOVERSEYES)) || (C.glasses && (C.glasses.flags & GLASSESCOVERSEYES)))
		user << "<span class='warning'>You're going to need to remove their head cover first!</span>"
		return

//since these people will be dead M != usr

	if(!C.getorgan(/obj/item/organ/brain))
		if(!C.get_bodypart("head"))
			return
		user.drop_item()
		var/msg = "[C] has [src] inserted into [C.p_their()] head by [user]."
		if(C == user)
			msg = "[user] inserts [src] into [user.p_their()] head!"

		C.visible_message("<span class='danger'>[msg]</span>",
						"<span class='userdanger'>[msg]</span>")

		if(C != user)
			C << "<span class='notice'>[user] inserts [src] into your head.</span>"
			user << "<span class='notice'>You insert [src] into [C]'s head.</span>"
		else
			user << "<span class='notice'>You insert [src] into your head.</span>"	//LOL

		Insert(C)
	else
		..()

/obj/item/organ/brain/Destroy() //copypasted from MMIs.
	if(brainmob)
		qdel(brainmob)
		brainmob = null
	return ..()

/obj/item/organ/brain/alien
	name = "alien brain"
	desc = "We barely understand the brains of terrestial animals. Who knows what we may find in the brain of such an advanced species?"
	icon_state = "brain-x"
	origin_tech = "biotech=6"
