
/turf
	var/z_open = FALSE //are we see the Z below us through this turf? (true/false)


/turf/open/open_z
 	icon = null
 	icon_state = ""
 	desc = ""
 	name = "zopen"
 	invisibility = 101 //Not real!!
 	z_open = TRUE


/turf/open/open_z/Entered(atom/movable/AM, atom/oloc)
	..()
	var/turf/T = GetBelowConnectedTurf(src)
	if(AtomCanFallThrough(AM) && T)
		AM.forceMove(T)


/turf/open/open_z/proc/AtomCanFallThrough(atom/movable/AM)
	. = FALSE
	if(AM.CanFallThroughZ())
		. = TRUE
	if(locate(/obj/structure/lattice/catwalk) in src)
		. = FALSE


/turf/open/open_z/CreateZShadow() //just no
  	return
