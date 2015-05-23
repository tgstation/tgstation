/obj/machinery/door/unpowered
	var/locked = 0


/obj/machinery/door/unpowered/Bumped(atom/AM)
	if(src.locked)	return
	..()
	return


/obj/machinery/door/unpowered/attackby(obj/item/I as obj, mob/user as mob, params)
	if(src.locked)	return
	..()
	return

/obj/machinery/door/unpowered/emag_act()
	return

/obj/machinery/door/unpowered/shuttle
	icon = 'icons/turf/shuttle.dmi'
	name = "door"
	icon_state = "door1"
	opacity = 1
	density = 1