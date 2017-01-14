/obj/item/organ/body_egg
	name = "body egg"
	desc = "All slimy and yuck."
	icon_state = "innards"
	origin_tech = "biotech=5"
	zone = "chest"
	slot = "parasite_egg"

/obj/item/organ/body_egg/on_find(mob/living/finder)
	..()
	finder << "<span class='warning'>You found an unknown alien organism in [owner]'s [zone]!</span>"

/obj/item/organ/body_egg/New(loc)
	if(iscarbon(loc))
		src.Insert(loc)
	return ..()

/obj/item/organ/body_egg/Insert(var/mob/living/carbon/M, special = 0)
	..()
	owner.status_flags |= XENO_HOST
	START_PROCESSING(SSobj, src)
	owner.med_hud_set_status()
	addtimer(CALLBACK(src, .proc/AddInfectionImages, owner), 0)

/obj/item/organ/body_egg/Remove(var/mob/living/carbon/M, special = 0)
	STOP_PROCESSING(SSobj, src)
	if(owner)
		owner.status_flags &= ~(XENO_HOST)
		owner.med_hud_set_status()
		addtimer(CALLBACK(src, .proc/RemoveInfectionImages, owner), 0)
	..()

/obj/item/organ/body_egg/process()
	if(!owner)
		return
	if(!(src in owner.internal_organs))
		Remove(owner)
		return
	egg_process()

/obj/item/organ/body_egg/proc/egg_process()
	return

/obj/item/organ/body_egg/proc/RefreshInfectionImage()
	RemoveInfectionImages()
	AddInfectionImages()

/obj/item/organ/body_egg/proc/AddInfectionImages()
	return

/obj/item/organ/body_egg/proc/RemoveInfectionImages()
	return
