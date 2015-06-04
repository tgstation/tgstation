//Augmented Eyesight: Gives you thermal and night vision - bye bye, flashlights. Also, high DNA cost because of how powerful it is.
//Possible todo: make a custom message for directing a penlight/flashlight at the eyes - not sure what would display though.

/obj/effect/proc_holder/changeling/augmented_eyesight
	name = "Augmented Eyesight"
	desc = "Creates heat receptors in our eyes and dramatically increases light sensing ability."
	helptext = "Grants us night vision and thermal vision. It may be toggled on or off. We will become more vulnerable to flash-based devices while active."
	chemical_cost = 0
	dna_cost = 2 //Would be 1 without thermal vision
	var/active = 0 //Whether or not vision is enhanced

/obj/effect/proc_holder/changeling/augmented_eyesight/sting_action(var/mob/user)
	active = !active
	if(active)
		user << "<span class='notice'>We feel a minute twitch in our eyes, and darkness creeps away.</span>"
		user.weakeyes = 1
		user.sight |= SEE_MOBS
		user.permanent_sight_flags |= SEE_MOBS
		user.see_in_dark = 8
		user.see_invisible = SEE_INVISIBLE_MINIMUM
	else
		user << "<span class='notice'>Our vision dulls. Shadows gather.</span>"
		user.weakeyes = 0
		user.sight -= SEE_MOBS
		user.permanent_sight_flags -= SEE_MOBS
		user.see_in_dark = 0
		user.see_invisible = SEE_INVISIBLE_LIVING
	return 1
