/obj/item/organ/internal/body_egg
	name = "body egg"
	desc = "All slimy and yuck."
	icon_state = "innards"
	origin_tech = "biotech=5"
	zone = "chest"
	slot = "parasite_egg"

/obj/item/organ/internal/body_egg/on_find(mob/living/finder)
	..()
	finder << "<span class='warning'>You found an unknown alien organism in [owner]'s [zone]!</span>"

/obj/item/organ/internal/body_egg/New(loc)
	if(iscarbon(loc))
		src.Insert(loc)
	return ..()

/obj/item/organ/internal/body_egg/Insert(var/mob/living/carbon/M, special = 0)
	..()
	owner.status_flags |= XENO_HOST
	SSobj.processing |= src
	owner.med_hud_set_status()
	spawn(0)
		AddInfectionImages(owner)

/obj/item/organ/internal/body_egg/Remove(var/mob/living/carbon/M, special = 0)
	SSobj.processing.Remove(src)
	if(owner)
		owner.status_flags &= ~(XENO_HOST)
		owner.med_hud_set_status()
		spawn(0)
			RemoveInfectionImages(owner)
	..()

/obj/item/organ/internal/body_egg/process()
	if(!owner)	return
	if(!(src in owner.internal_organs))
		Remove(owner)
		return
	egg_process()

/obj/item/organ/internal/body_egg/proc/egg_process()
	return

/obj/item/organ/internal/body_egg/proc/RefreshInfectionImage()
	RemoveInfectionImages()
	AddInfectionImages()

/obj/item/organ/internal/body_egg/proc/AddInfectionImages()
	return

/obj/item/organ/internal/body_egg/proc/RemoveInfectionImages()
	return