/obj/structure/bodycontainer/morgue/update_icon()	//hippie start, re-add cloning
	..()
	for(var/mob/living/M in compiled)
		var/mob/living/mob_occupant = get_mob_or_brainmob(M)
		if(mob_occupant.client && !mob_occupant.suiciding && !(HAS_TRAIT(mob_occupant, TRAIT_BADDNA)) && !mob_occupant.hellbound_type)
			icon_state = "morgue4" // clonable
