/*
	A vacuum that pulls in movable objects around it
*/

/obj/structure/infection/vacuum
	name = "infection vacuum"
	desc = "A large mass with a pulsing void in the center."
	icon = 'icons/mob/infection/infection.dmi'
	icon_state = "vacuum"
	max_integrity = 100
	health_regen = 3
	point_return = 10
	build_time = 100
	upgrade_subtype = /datum/infection_upgrade/vacuum
	// the range to pull objects from
	var/suck_range = 7

/obj/structure/infection/vacuum/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/infection/vacuum/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/structure/infection/vacuum/CanPass(atom/movable/mover, turf/target)
	return TRUE

/obj/structure/infection/vacuum/Life()
	update_icon()
	playsound(src.loc, 'sound/effects/podwoosh.ogg', 10, 1, pressure_affected = FALSE)
	for(var/atom/movable/M in orange(7, src))
		if(isliving(M))
			var/mob/living/L = M
			if(ROLE_INFECTION in L.faction)
				continue
		if(!M.anchored && !M.pulledby)
			M.experience_pressure_difference(MOVE_FORCE_STRONG, get_dir(M, src))
	for(var/atom/A in get_turf(src)) // eating time
		if(isliving(A))
			var/mob/living/L = A
			if(ROLE_INFECTION in L.faction)
				continue
			if(L.stat == DEAD) // left for core to grab
				continue
			L.adjustBruteLoss(15)
			to_chat(L, "<span class='danger'>You feel a terrible pain as you slam into the vacuum!</span>")
			playsound(src.loc, 'sound/effects/splat.ogg', 100, 1, pressure_affected = FALSE)
		else
			A.blob_act()


