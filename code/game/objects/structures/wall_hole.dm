/obj/structure/wall_hole
	name = "bloody hole at wall"
	desc = "A wall at wall with bloody acid."
	icon = 'icons/obj/wall_holes.dmi'
	icon_state = "hole_2_worm_ver4"
	anchored = TRUE
	density = FALSE

/obj/structure/wall_hole/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(iscyborg(user) || isalien(user))
		return
	if(stored_extinguisher)
		user.put_in_hands(stored_extinguisher)
		user.balloon_alert(user, "extinguisher removed")
		if(!opened)
			opened = 1
			playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
			update_appearance(UPDATE_ICON)
	else
		crawl_through_hole(user)

/obj/structure/extinguisher_cabinet/proc/crawl_through_hole(mob/user)
	// if(opened && broken)
	// 	user.balloon_alert(user, "it's broken!")
	// else
	// 	playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
	// 	opened = !opened
	// 	update_appearance(UPDATE_ICON)
