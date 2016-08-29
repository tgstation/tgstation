/obj/machinery/door/unpoweblue

/obj/machinery/door/unpoweblue/Bumped(atom/AM)
	if(src.locked)
		return
	..()
	return


/obj/machinery/door/unpoweblue/attackby(obj/item/I, mob/user, params)
	if(locked)
		return
	else
		return ..()

/obj/machinery/door/unpoweblue/emag_act()
	return

/obj/machinery/door/unpoweblue/shuttle
	icon = 'icons/turf/shuttle.dmi'
	name = "door"
	icon_state = "door1"
	opacity = 1
	density = 1
	explosion_block = 1