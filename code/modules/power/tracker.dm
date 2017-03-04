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
	use_power = 0
	obj_integrity = 250
	max_integrity = 250
	integrity_failure = 50

	var/id = 0
	var/sun_angle = 0		// sun angle as set by sun datum
	var/obj/machinery/power/solar_control/control = null

/obj/machinery/power/tracker/New(var/turf/loc, var/obj/item/solar_assembly/S)
	..(loc)
	Make(S)
	connect_to_network()

/obj/machinery/power/tracker/Destroy()
	unset_control() //remove from control computer
	return ..()

//set the control of the tracker to a given computer if closer than SOLAR_MAX_DIST
/obj/machinery/power/tracker/proc/set_control(obj/machinery/power/solar_control/SC)
	if(!SC || (get_dist(src, SC) > SOLAR_MAX_DIST))
		return 0
	control = SC
	SC.connected_tracker = src
	return 1

//set the control of the tracker to null and removes it from the previous control computer if needed
/obj/machinery/power/tracker/proc/unset_control()
	if(control)
		control.connected_tracker = null
	control = null

/obj/machinery/power/tracker/proc/Make(obj/item/solar_assembly/S)
	if(!S)
		S = new /obj/item/solar_assembly(src)
		S.glass_type = /obj/item/stack/sheet/glass
		S.tracker = 1
		S.anchored = 1
	S.loc = src
	update_icon()

//updates the tracker icon and the facing angle for the control computer
/obj/machinery/power/tracker/proc/set_angle(angle)
	sun_angle = angle

	//set icon dir to show sun illumination
	setDir(turn(NORTH, -angle - 22.5)	)// 22.5 deg bias ensures, e.g. 67.5-112.5 is EAST

	if(powernet && (powernet == control.powernet)) //update if we're still in the same powernet
		control.currentdir = angle

/obj/machinery/power/tracker/attackby(obj/item/weapon/W, mob/user, params)

	if(istype(W, /obj/item/weapon/crowbar))
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		user.visible_message("[user] begins to take the glass off the solar tracker.", "<span class='notice'>You begin to take the glass off the solar tracker...</span>")
		if(do_after(user, 50*W.toolspeed, target = src))
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			user.visible_message("[user] takes the glass off the tracker.", "<span class='notice'>You take the glass off the tracker.</span>")
			deconstruct(TRUE)
	else
		return ..()

/obj/machinery/power/tracker/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(flags & NODECONSTRUCT))
		playsound(loc, 'sound/effects/Glassbr3.ogg', 100, 1)
		stat |= BROKEN
		unset_control()

/obj/machinery/power/solar/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(disassembled)
			var/obj/item/solar_assembly/S = locate() in src
			if(S)
				S.forceMove(loc)
				S.give_glass(stat & BROKEN)
		else
			playsound(src, "shatter", 70, 1)
			new /obj/item/weapon/shard(src.loc)
			new /obj/item/weapon/shard(src.loc)
	qdel(src)

// Tracker Electronic

/obj/item/weapon/electronics/tracker
	name = "tracker electronics"