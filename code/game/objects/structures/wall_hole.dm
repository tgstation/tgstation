/obj/structure/wall_hole
	name = "bloody hole at wall"
	desc = "A wall at wall with bloody acid."
	icon = 'icons/obj/wall_holes.dmi'
	icon_state = "hole_worm_ver5_south"
	anchored = TRUE
	density = FALSE

	MAPPING_DIRECTIONAL_HELPERS(/obj/structure/wall_hole, 29)

/obj/structure/wall_hole/directional/north/Initialize(mapload)
	. = ..()
	icon_state = "hole_worm_ver5_south"

/obj/structure/wall_hole/directional/south/Initialize(mapload)
	. = ..()
	icon_state = "hole_worm_ver5_north"

/obj/structure/wall_hole/directional/west/Initialize(mapload)
	. = ..()
	icon_state = "hole_worm_ver5_east"

/obj/structure/wall_hole/directional/east/Initialize(mapload)
	. = ..()
	icon_state = "hole_worm_ver5_west"

/obj/structure/wall_hole/attack_hand(mob/user, list/modifiers)
	. = ..()
	// if(.)
	// 	return
	// if(iscyborg(user) || isalien(user))
	// 	return
	// if(stored_extinguisher)
	// 	user.put_in_hands(stored_extinguisher)
	// 	user.balloon_alert(user, "extinguisher removed")
	// 	if(!opened)
	// 		opened = 1
	// 		playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
	// 		update_appearance(UPDATE_ICON)
	// else
	crawl_through_hole(user)

/obj/structure/wall_hole/proc/crawl_through_hole(mob/user)
	var/mob/living/L = user
	var/hole_iself_turf = get_step(get_turf(L), L.dir)
	var/exit_hole_turf = get_step(hole_iself_turf, L.dir)

	L.forceMove(exit_hole_turf)

	// if(opened && broken)
	// 	user.balloon_alert(user, "it's broken!")
	// else
	// 	playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
	// 	opened = !opened
	// 	update_appearance(UPDATE_ICON)

/obj/item/wallframe/wall_hole
