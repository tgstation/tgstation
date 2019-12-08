/obj/item/implant/mindshield/implant(mob/living/target, mob/user, silent = FALSE)
	if(..())
		if(!target.mind)
			return TRUE
		if(target.mind.has_antag_datum(/datum/antagonist/gang/boss))
			if(!silent)
				target.visible_message("<span class='warning'>[target] seems to resist the implant!</span>", "<span class='warning'>You feel something interfering with your mental conditioning, but you resist it!</span>")
			removed(target, 1)
			qdel(src)
			return FALSE
		target.mind.remove_antag_datum(/datum/antagonist/gang)
		if(!silent)
			to_chat(target, "<span class='notice'>You feel a sense of peace and security. You are now protected from brainwashing.</span>")
		return TRUE
	return FALSE
