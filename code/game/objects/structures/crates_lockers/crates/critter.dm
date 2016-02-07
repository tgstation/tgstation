/obj/structure/closet/crate/critter
	name = "critter crate"
	desc = "A crate designed for safe transport of animals. Only openable from the the outside."
	icon_state = "crittercrate"
	allow_mobs = TRUE
	breakout_time = 1

/obj/structure/closet/crate/critter/update_icon()
	overlays.Cut()
	if(opened)
		overlays += "crittercrate_door_open"
	else
		overlays += "crittercrate_door"
		if(manifest)
			overlays += "manifest"

/obj/structure/closet/crate/critter/attack_hand(mob/user)
	if(user in src)
		user << "<span class='notice'>It won't budge!</span>"
	else
		..()
