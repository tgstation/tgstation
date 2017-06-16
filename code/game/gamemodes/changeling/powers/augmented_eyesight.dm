//Augmented Eyesight: Gives you thermal and night vision - bye bye, flashlights. Also, high DNA cost because of how powerful it is.
//Possible todo: make a custom message for directing a penlight/flashlight at the eyes - not sure what would display though.

/obj/effect/proc_holder/changeling/augmented_eyesight
	name = "Augmented Eyesight"
	desc = "Creates heat receptors in our eyes and dramatically increases light sensing ability, or protects your vision from flashes."
	helptext = "Grants us thermal vision or flash protection. We will become a lot more vulnerable to flash-based devices while thermal vision is active."
	chemical_cost = 0
	dna_cost = 2 //Would be 1 without thermal vision
	active = 0 //Whether or not vision is enhanced

/obj/effect/proc_holder/changeling/augmented_eyesight/sting_action(mob/living/carbon/human/user)
	if(!istype(user))
		return
	var/obj/item/organ/eyes/E = user.getorganslot("eye_sight")
	if(E)
		if(E.flash_protect)
			E.sight_flags |= SEE_MOBS
			E.flash_protect = -1
			to_chat(user, "We adjust our eyes to sense prey through walls.")
		else
			E.sight_flags -= SEE_MOBS
			E.flash_protect = 2
			to_chat(user, "We adjust our eyes to protect them from bright lights.")
		user.update_sight()
	else
		to_chat(user, "We can't adjust our eyes if we don't have any!")



	return 1


/obj/effect/proc_holder/changeling/augmented_eyesight/on_refund(mob/user)
	var/obj/item/organ/eyes/E = user.getorganslot("eye_sight")
	if(E)
		E.sight_flags -= SEE_MOBS