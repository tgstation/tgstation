/obj/machinery/dampener
	name = "explosion dampener"
	desc = "When active, it shields an area from explosive blasts."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "fountain"
	density = TRUE
	opacity = FALSE
	anchored = TRUE
	pressure_resistance = 2*ONE_ATMOSPHERE
	max_integrity = 100
	obj_integrity = 100

	var/active = FALSE
	var/list/turf/protected_turfs = list()
	var/radius = 5

/obj/machinery/dampener/update_icon()
	if(active)
		icon_state = "fountain-blue"
	else
		icon_state = "fountain"

/obj/machinery/dampener/New()
	..()
	dampener_list |= src
	if(active)
		assign_zone()
		protect_turfs()
		update_icon()

/obj/machinery/dampener/Destroy()
	turn_off()
	dampener_list -= src
	. = ..()

/obj/machinery/dampener/proc/assign_zone()
	var/list/turf/already_protected = list()
	for(var/d in dampener_list)
		var/obj/machinery/dampener/D = d
		already_protected |= D.protected_turfs

	protected_turfs.Cut()

	var/turf/current = get_turf(src)

	for(var/t in RANGE_TURFS(radius, current))
		if(t in already_protected)
			continue
		protected_turfs |= t


/obj/machinery/dampener/proc/protect_turfs()
	for(var/t in protected_turfs)
		var/turf/T = t
		T.flags |= EXPLOSION_PROOF

/obj/machinery/dampener/proc/unprotect_turfs()
	for(var/t in protected_turfs)
		var/turf/T = t
		T.flags &= ~EXPLOSION_PROOF

/obj/machinery/dampener/Moved(atom/OldLoc, Dir)
	. = ..()
	if(active)
		unprotect_turfs()
		assign_zone()
		protect_turfs()

// If onShuttleMove() ever starts calling Move() or Moved(), remove this
/obj/machinery/dampener/onShuttleMove()
	. = ..()
	if(!.)
		return
	if(active)
		unprotect_turfs()
		assign_zone()
		protect_turfs()

/obj/machinery/dampener/process()
	if(active)
		protect_turfs()

/obj/machinery/dampener/proc/turn_on()
	active = TRUE
	assign_zone()
	protect_turfs()
	update_icon()

/obj/machinery/dampener/proc/turn_off()
	active = FALSE
	unprotect_turfs()
	protected_turfs.Cut()
	update_icon()

/obj/machinery/dampener/fountain
	name = "fountain of shielding"
	desc = "He drove out the man, and at the east of the garden of \
		Eden he placed the cherubim and a flaming sword that turned \
		every way to guard the way to the tree of life."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
