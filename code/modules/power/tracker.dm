//Solar tracker

//Machine that tracks the sun and reports it's direction to the solar controllers
//As long as this is working, solar panels on same powernet will track automatically

/obj/machinery/power/tracker
	name = "solar tracker"
	desc = "A solar directional tracker."
	icon = 'icons/obj/power.dmi'
	icon_state = "tracker"
	anchored = 1
	density = 1
	directwired = 1
	use_power = 0

	var/sun_angle = 0		// sun angle as set by sun datum

/obj/machinery/power/tracker/New(var/turf/loc, var/obj/item/solar_assembly/S)
	..(loc)
	if(!S)
		S = new /obj/item/solar_assembly(src)
		S.glass_type = /obj/item/stack/sheet/glass
		S.tracker = 1
		S.anchored = 1
	S.loc = src
	connect_to_network()

/obj/machinery/power/tracker/disconnect_from_network()
	..()
	solars_list.Remove(src)

/obj/machinery/power/tracker/connect_to_network()
	..()
	solars_list.Add(src)

// called by datum/sun/calc_position() as sun's angle changes
/obj/machinery/power/tracker/proc/set_angle(var/angle)
	sun_angle = angle

	//set icon dir to show sun illumination
	dir = turn(NORTH, -angle - 22.5)	// 22.5 deg bias ensures, e.g. 67.5-112.5 is EAST

	// find all solar controls and update them
	// currently, just update all controllers in world
	// ***TODO: better communication system using network
	if(powernet)
		for(var/obj/machinery/power/solar_control/C in powernet.nodes)
			if(powernet.nodes[C])
				if(get_dist(C, src) < SOLAR_MAX_DIST)
					C.tracker_update(angle)


/obj/machinery/power/tracker/attackby(var/obj/item/weapon/W, var/mob/user)

	if(istype(W, /obj/item/weapon/crowbar))
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		if(do_after(user, 50))
			var/obj/item/solar_assembly/S = locate() in src
			if(S)
				S.loc = src.loc
				S.give_glass()
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			user.visible_message("<span class='notice'>[user] takes the glass off the tracker.</span>")
			qdel(src)
		return
	..()

// Tracker Electronic

/obj/item/weapon/tracker_electronics

	name = "tracker electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	w_class = 2.0