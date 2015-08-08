// transit tube construction

// normal transit tubes
/obj/structure/c_transit_tube
	name = "unattached transit tube"
	icon = 'icons/obj/atmospherics/pipes/transit_tube.dmi'
	icon_state = "E-W" //icon_state decides which tube will be built
	density = 0
	layer = 3.1 //same as the built tube
	anchored = 0.0

//wrapper for turn that changes the transit tube formatted icon_state instead of the dir
/obj/structure/c_transit_tube/proc/tube_turn(angle)
	var/list/badtubes = list("W-E", "W-E-Pass", "S-N", "S-N-Pass", "SW-NE", "SE-NW")
	var/list/split_text = text2list(icon_state, "-")
	for(var/i=1; i<=split_text.len; i++)
		var/curdir = text2dir_extended(split_text[i]) //0 if not a valid direction (e.g. Pass, Block)
		if(curdir)
			split_text[i] = dir2text_short(turn(curdir, angle))
	var/newdir = list2text(split_text, "-")
	if(badtubes.Find(newdir))
		split_text.Swap(1,2)
		newdir = list2text(split_text, "-")
	icon_state = newdir

/obj/structure/c_transit_tube/proc/tube_flip()
	var/list/split_text = text2list(icon_state, "-")
	//skip straight pipes
	if(length(split_text[2]) < 2)
		return
	//for junctions, just swap the diagonals with each other
	if(split_text.len == 3 && split_text[3] != "Pass")
		split_text.Swap(2,3)
	//for curves, swap the diagonal direction that is not in the same axis as the cardinal direction
	else
		if(split_text[1] == "N" || split_text[1] == "S")
			split_text[2] = copytext(split_text[2],1,2) + ((copytext(split_text[2],2,3) == "E") ? "W" : "E")
		else
			split_text[2] = ((copytext(split_text[2],1,2) == "N") ? "S" : "N") + copytext(split_text[2],2,3)
	icon_state = list2text(split_text, "-")

// disposals-style flip and rotate verbs
/obj/structure/c_transit_tube/verb/rotate()
	set name = "Rotate Tube CW"
	set category = "Object"
	set src in view(1)

	if(!usr.canUseTopic(src))
		return

	tube_turn(-90)

/obj/structure/c_transit_tube/verb/rotate_ccw()
	set name = "Rotate Tube CCW"
	set category = "Object"
	set src in view(1)

	if(!usr.canUseTopic(src))
		return

	tube_turn(90)

/obj/structure/c_transit_tube/verb/flip()
	set name = "Flip"
	set category = "Object"
	set src in view(1)

	if(!usr.canUseTopic(src))
		return

	tube_flip()

/obj/structure/c_transit_tube/proc/buildtube()
	var/obj/structure/transit_tube/R = new/obj/structure/transit_tube(src.loc)
	R.icon_state = src.icon_state
	R.init_dirs()
	R.generate_automatic_corners(R.tube_dirs)
	return R

/obj/structure/c_transit_tube/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wrench))
		user << "<span class='notice'>You start attaching the [name]...</span>"
		src.add_fingerprint(user)
		if(do_after(user, 40, target = src))
			if(!src) return
			user << "<span class='notice'>You attach the [name].</span>"
			var/obj/structure/transit_tube/R = src.buildtube()
			src.transfer_fingerprints_to(R)
			qdel(src)
			return

// transit tube station
/obj/structure/c_transit_tube/station
	name = "unattached through station"
	icon = 'icons/obj/atmospherics/pipes/transit_tube_station.dmi'
	icon_state = "closed"

/obj/structure/c_transit_tube/station/tube_turn(var/angle)
	src.dir = turn(src.dir, angle)

/obj/structure/c_transit_tube/station/tube_flip()
	src.tube_turn(180)

/obj/structure/c_transit_tube/station/buildtube()
	var/obj/structure/transit_tube/station/R = new/obj/structure/transit_tube/station(src.loc)
	R.dir = src.dir
	R.init_dirs()
	return R

// reverser station, used for the terminus
/obj/structure/c_transit_tube/station/reverse
	name = "unattached terminus station"

/obj/structure/c_transit_tube/station/reverse/buildtube()
	var/obj/structure/transit_tube/station/reverse/R = new/obj/structure/transit_tube/station/reverse(src.loc)
	R.dir = src.dir
	R.init_dirs()
	return R

// block, used after the terminus of a transit tube station, decorative only
// code-wise they're normal tubes but they're ~speshul~ because they care about the dir instead of the icon_state
// in that sense they're the same as stations and can reuse their flip and rotate verbs
/obj/structure/c_transit_tube/station/block
	name = "unattached tube blocker"
	icon = 'icons/obj/atmospherics/pipes/transit_tube.dmi'
	icon_state = "Block"

/obj/structure/c_transit_tube/station/block/buildtube()
	var/obj/structure/transit_tube/R = new/obj/structure/transit_tube(src.loc)
	R.icon_state = src.icon_state
	R.dir = src.dir
	R.init_dirs()
	return R

//transit tube pod
//see station.dm for the logic
/obj/structure/c_transit_tube_pod
	name = "unattached transit tube pod"
	icon = 'icons/obj/atmospherics/pipes/transit_tube_pod.dmi'
	icon_state = "pod"
	anchored = 0.0
	density = 0
