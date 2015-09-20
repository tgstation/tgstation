/obj/machinery/door/poddoor/curtains
	gender = PLURAL
	name = "curtains"
	desc = "Thick fabric curtains that open mechanically."
	icon = 'icons/obj/doors/curtains.dmi'
	layer = 3.1

/obj/machinery/door/poddoor/curtains/preopen
	icon_state = "curtains"
	density = 0
	opacity = 0


//shutters look like ass with things on top of them.

/obj/machinery/door/poddoor/curtains/New()
	..()
	layer = 3.1	//to handle /obj/machinery/door/New() resetting the layer.


/obj/machinery/door/poddoor/curtains/open(ignorepower = 0)
	..()
	layer = 3.1


/obj/machinery/door/poddoor/curtains/close(ignorepower = 0)
	..()
	layer = 3.1