/obj/item/body_egg
	name = "generic egg"
	desc = "All slimy and yuck."
	icon = 'icons/mob/alien.dmi'
	icon_state = "larva0_dead"
	var/mob/living/affected_mob

/obj/item/body_egg/New()
	if(istype(loc, /mob/living))
		affected_mob = loc
		affected_mob.status_flags |= XENO_HOST
		SSobj.processing |= src
		if(istype(affected_mob,/mob/living/carbon))
			var/mob/living/carbon/H = affected_mob
			H.med_hud_set_status()
		spawn(0)
			AddInfectionImages(affected_mob)
	else
		qdel(src)

/obj/item/body_egg/Destroy()
	if(affected_mob)
		affected_mob.status_flags &= ~(XENO_HOST)
		if(istype(affected_mob,/mob/living/carbon))
			var/mob/living/carbon/H = affected_mob
			H.med_hud_set_status()
		spawn(0)
			RemoveInfectionImages(affected_mob)
	..()

/obj/item/body_egg/process()
	if(!affected_mob)	return
	if(loc != affected_mob)
		affected_mob.status_flags &= ~(XENO_HOST)
		SSobj.processing.Remove(src)
		if(istype(affected_mob,/mob/living/carbon))
			var/mob/living/carbon/H = affected_mob
			H.med_hud_set_status()
		spawn(0)
			RemoveInfectionImages(affected_mob)
			affected_mob = null
		return

	egg_process()

/obj/item/body_egg/proc/egg_process()
	return

/obj/item/body_egg/proc/RefreshInfectionImage()
	RemoveInfectionImages()
	AddInfectionImages()

/obj/item/body_egg/proc/AddInfectionImages()
	return

/obj/item/body_egg/proc/RemoveInfectionImages()
	return