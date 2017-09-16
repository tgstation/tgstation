// transit tube construction

// normal transit tubes
/obj/structure/c_transit_tube
	name = "unattached transit tube"
	icon = 'icons/obj/atmospherics/pipes/transit_tube.dmi'
	icon_state = "straight"
	density = FALSE
	layer = LOW_ITEM_LAYER //same as the built tube
	anchored = FALSE
	var/flipped = 0
	var/build_type = /obj/structure/transit_tube
	var/flipped_build_type
	var/base_icon

/obj/structure/c_transit_tube/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Alt-click to rotate it clockwise.</span>")

/obj/structure/c_transit_tube/proc/tube_rotate()
	setDir(turn(dir, -90))

/obj/structure/c_transit_tube/proc/tube_flip()
	if(flipped_build_type)
		flipped = !flipped
		var/cur_flip = initial(flipped) ? !flipped : flipped
		if(cur_flip)
			build_type = flipped_build_type
		else
			build_type = initial(build_type)
		icon_state = "[base_icon][flipped]"
	else
		setDir(turn(dir, 180))

// disposals-style flip and rotate verbs
/obj/structure/c_transit_tube/verb/rotate()
	set name = "Rotate Tube"
	set category = "Object"
	set src in view(1)

	if(usr.incapacitated())
		return

	tube_rotate()

/obj/structure/c_transit_tube/AltClick(mob/user)
	..()
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!in_range(src, user))
		return
	tube_rotate()

/obj/structure/c_transit_tube/verb/flip()
	set name = "Flip"
	set category = "Object"
	set src in view(1)

	if(usr.incapacitated())
		return
	tube_flip()


/obj/structure/c_transit_tube/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/wrench))
		to_chat(user, "<span class='notice'>You start attaching the [name]...</span>")
		add_fingerprint(user)
		playsound(src.loc, I.usesound, 50, 1)
		if(do_after(user, 40*I.toolspeed, target = src))
			if(QDELETED(src))
				return
			to_chat(user, "<span class='notice'>You attach the [name].</span>")
			var/obj/structure/transit_tube/R = new build_type(loc, dir)
			transfer_fingerprints_to(R)
			qdel(src)
	else
		return ..()

// transit tube station
/obj/structure/c_transit_tube/station
	name = "unattached through station"
	icon_state = "closed_station0"
	build_type = /obj/structure/transit_tube/station
	flipped_build_type = /obj/structure/transit_tube/station/flipped
	base_icon = "closed_station"

/obj/structure/c_transit_tube/station/flipped
	icon_state = "closed_station1"
	flipped = 1
	build_type = /obj/structure/transit_tube/station/flipped
	flipped_build_type = /obj/structure/transit_tube/station


// reverser station, used for the terminus
/obj/structure/c_transit_tube/station/reverse
	name = "unattached terminus station"
	icon_state = "closed_terminus0"
	build_type = /obj/structure/transit_tube/station/reverse
	flipped_build_type = /obj/structure/transit_tube/station/reverse/flipped
	base_icon = "closed_terminus"

/obj/structure/c_transit_tube/station/reverse/flipped
	icon_state = "closed_terminus1"
	flipped = 1
	build_type = /obj/structure/transit_tube/station/reverse/flipped
	flipped_build_type = /obj/structure/transit_tube/station/reverse


/obj/structure/c_transit_tube/crossing
	icon_state = "crossing"
	build_type = /obj/structure/transit_tube/crossing


/obj/structure/c_transit_tube/diagonal
	icon_state = "diagonal"
	build_type = /obj/structure/transit_tube/diagonal

/obj/structure/c_transit_tube/diagonal/crossing
	icon_state = "diagonal_crossing"
	build_type = /obj/structure/transit_tube/diagonal/crossing


/obj/structure/c_transit_tube/curved
	icon_state = "curved0"
	build_type = /obj/structure/transit_tube/curved
	flipped_build_type = /obj/structure/transit_tube/curved/flipped
	base_icon = "curved"

/obj/structure/c_transit_tube/curved/flipped
	icon_state = "curved1"
	build_type = /obj/structure/transit_tube/curved/flipped
	flipped_build_type = /obj/structure/transit_tube/curved
	flipped = 1


/obj/structure/c_transit_tube/junction
	icon_state = "junction0"
	build_type = /obj/structure/transit_tube/junction
	flipped_build_type = /obj/structure/transit_tube/junction/flipped
	base_icon = "junction"


/obj/structure/c_transit_tube/junction/flipped
	icon_state = "junction1"
	flipped = 1
	build_type = /obj/structure/transit_tube/junction/flipped
	flipped_build_type = /obj/structure/transit_tube/junction


//transit tube pod
//see station.dm for the logic
/obj/structure/c_transit_tube_pod
	name = "unattached transit tube pod"
	icon = 'icons/obj/atmospherics/pipes/transit_tube.dmi'
	icon_state = "pod"
	anchored = FALSE
	density = FALSE
