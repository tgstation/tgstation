//Augmented Eyesight: Gives you X-ray vision or protection from flashes. Also, high DNA cost because of how powerful it is.
//Possible todo: make a custom message for directing a penlight/flashlight at the eyes - not sure what would display though.

/obj/effect/proc_holder/changeling/augmented_eyesight
	name = "Augmented Eyesight"
	desc = "Creates heat receptors in our eyes and dramatically increases light sensing ability, or protects your vision from flashes."
	helptext = "Grants us thermal vision or flash protection. We will become a lot more vulnerable to flash-based devices while thermal vision is active."
	chemical_cost = 0
	dna_cost = 2 //Would be 1 without thermal vision
	active = FALSE

/obj/effect/proc_holder/changeling/augmented_eyesight/on_purchase(mob/user) //The ability starts inactive, so we should be protected from flashes.
	var/obj/item/organ/eyes/E = user.getorganslot(ORGAN_SLOT_EYES)
	if (E)
		E.flash_protect = 2 //Adjust the user's eyes' flash protection
		to_chat(user, "We adjust our eyes to protect them from bright lights.")
	else
		to_chat(user, "We can't adjust our eyes if we don't have any!")

/obj/effect/proc_holder/changeling/augmented_eyesight/sting_action(mob/living/carbon/human/user)
	if(!istype(user))
		return
	var/obj/item/organ/eyes/E = user.getorganslot(ORGAN_SLOT_EYES)
	if(E)
		if(!active)
			E.sight_flags |= SEE_MOBS | SEE_OBJS | SEE_TURFS //Add sight flags to the user's eyes
			E.flash_protect = -1 //Adjust the user's eyes' flash protection
			to_chat(user, "We adjust our eyes to sense prey through walls.")
			active = TRUE //Defined in code/modules/spells/spell.dm
		else
			E.sight_flags ^= SEE_MOBS | SEE_OBJS | SEE_TURFS //Remove sight flags from the user's eyes
			E.flash_protect = 2 //Adjust the user's eyes' flash protection
			to_chat(user, "We adjust our eyes to protect them from bright lights.")
			active = FALSE
		user.update_sight()
	else
		to_chat(user, "We can't adjust our eyes if we don't have any!")



	return 1


/obj/effect/proc_holder/changeling/augmented_eyesight/on_refund(mob/user) //Get rid of X-ray vision and flash protection when the user refunds this ability
	var/obj/item/organ/eyes/E = user.getorganslot(ORGAN_SLOT_EYES)
	if(E)
		if (active)
			E.sight_flags ^= SEE_MOBS | SEE_OBJS | SEE_TURFS
		else
			E.flash_protect = 0
		user.update_sight()