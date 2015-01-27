/obj/machinery/power/solar/tracker
	name = "solar tracker"
	desc = "A solar directional tracker."
	icon_state = "tracker"

	var/sun_angle = 0 // sun angle as set by sun datum

/obj/machinery/power/solar/tracker/New(loc, obj/machinery/power/solar_assembly/S)
	..(loc)

	if(!S)
		S = new(src)
		S.glass_type = /obj/item/stack/sheet/rglass
		S.tracker = 1
		S.anchored = 1

	S.loc = src

// called by datum/sun/calc_position() as sun's angle changes
/obj/machinery/power/solar/tracker/proc/set_angle(angle)
	sun_angle = angle

	//Set icon dir to show sun illumination
	dir = turn(NORTH, -angle - 22.5)	//22.5 deg bias ensures, e.g. 67.5-112.5 is EAST

	//Check we can draw power
	if(stat & NOPOWER)
		return

	//Find all solar controls and update them
	//Currently, just update all controllers in world
	// ***TODO: better communication system using network
	for(var/obj/machinery/power/solar/control/C in getPowernetNodes())
		if(get_dist(C, src) < SOLAR_MAX_DIST)
			C.tracker_update(angle)

/obj/machinery/power/solar/tracker/attackby(var/obj/item/weapon/W, var/mob/user)
	if(iscrowbar(W))
		playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
		if(do_after(user, 50))
			var/obj/machinery/power/solar_assembly/S = locate() in src
			if(S)
				S.loc = src.loc
				S.give_glass()
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
			user.visible_message("<span class='notice'>[user] takes the glass off the tracker.</span>")
			qdel(src)
		return
	..()

// make sure we can draw power from the powernet
/obj/machinery/power/solar/tracker/process()
	var/avail = surplus()

	if(avail > 500)
		add_load(500)
		stat &= ~NOPOWER
	else
		stat |= NOPOWER

// tracker Electronic
/obj/item/weapon/tracker_electronics
	name = "tracker electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	w_class = 2.0
