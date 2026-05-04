/obj/item/implant/freedom
	name = "freedom implant"
	desc = "Use this to escape from those evil Red Shirts."
	icon_state = "freedom"
	implant_color = "r"
	uses = FREEDOM_IMPLANT_CHARGES

	implant_info = "Activated manually. \
		Unlocks bindings on arms and legs when activated, but not larger ones e.g. straightjackets."

	implant_lore = "The CSMD Freedom Beacon is a hybrid signal transmitter and specialized nanite manufactory \
		designed to defeat handcuffs, legcuffs, and other equivalent arm and leg bindings by both transmitting \
		unlock signals for electrical cuff lock systems and, in the event of failure, generating thin nanite tendrils \
		to nondestructively unsecure relevant bindings. Unfortunately, this only works for bindings on the arms and legs; \
		larger restraints, such as straightjackets are too complex for the nanites to deal with."

/obj/item/implant/freedom/implant(mob/living/target, mob/user, silent, force)
	. = ..()
	if(!.)
		return FALSE
	if(!iscarbon(target)) //This is pretty much useless for anyone else since they can't be cuffed
		balloon_alert(user, "that would be a waste!")
		return FALSE
	return TRUE

/obj/item/implant/freedom/activate()
	. = ..()
	var/mob/living/carbon/carbon_imp_in = imp_in
	if(!can_trigger(carbon_imp_in))
		balloon_alert(carbon_imp_in, "no restraints!")
		return

	uses--

	carbon_imp_in.uncuff()
	var/obj/item/clothing/shoes/shoes = carbon_imp_in.shoes
	if(istype(shoes) && shoes.tied == SHOES_KNOTTED)
		shoes.adjust_laces(SHOES_TIED, carbon_imp_in)

	if(!uses)
		addtimer(CALLBACK(carbon_imp_in, TYPE_PROC_REF(/atom, balloon_alert), carbon_imp_in, "implant degraded!"), 1 SECONDS)
		qdel(src)

/obj/item/implant/freedom/proc/can_trigger(mob/living/carbon/implanted_in)
	if(implanted_in.handcuffed || implanted_in.legcuffed)
		return TRUE

	var/obj/item/clothing/shoes/shoes = implanted_in.shoes
	if(istype(shoes) && shoes.tied == SHOES_KNOTTED)
		return TRUE

	return FALSE


/obj/item/implanter/freedom
	name = "implanter (freedom)"
	imp_type = /obj/item/implant/freedom

/obj/item/implantcase/freedom
	name = "implant case - 'Freedom'"
	desc = "A glass case containing a freedom implant."
	imp_type = /obj/item/implant/freedom
