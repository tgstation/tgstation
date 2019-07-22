/obj/structure/infection/door
	name = "infection barrier"
	desc = "A thin mesh barrier preventing entry of non infectious creatures."
	icon = 'icons/mob/infection/infection.dmi'
	icon_state = "door"
	max_integrity = 150
	brute_resist = 0.5
	fire_resist = 0.25
	explosion_block = 3
	point_return = 0
	build_time = 100
	atmosblock = TRUE

/obj/structure/infection/door/evolve_menu(var/mob/camera/commander/C)
	return

/obj/structure/infection/door/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSBLOB))
		return TRUE
	if(mover.pulledby && isliving(mover.pulledby)) // pulled through by other infection creatures
		var/mob/living/L = mover.pulledby
		if(L.pass_flags & PASSBLOB)
			return TRUE
	return FALSE
