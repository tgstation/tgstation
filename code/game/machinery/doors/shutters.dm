/obj/machinery/door/poddoor/shutters
	gender = PLURAL
	name = "shutters"
	desc = "Heavy duty metal shutters that opens mechanically."
	icon = 'icons/obj/doors/shutters.dmi'
	layer = DOOR_CLOSED_LAYER

/obj/machinery/door/poddoor/shutters/preopen
	icon_state = "open"
	density = 0
	opacity = 0


//shutters look like ass with things on top of them.

/obj/machinery/door/poddoor/shutters/New()
	..()
	layer = DOOR_CLOSED_LAYER


/obj/machinery/door/poddoor/shutters/open(ignorepower = 0)
	..()
	layer = DOOR_OPEN_LAYER


/obj/machinery/door/poddoor/shutters/close(ignorepower = 0)
	..()
	layer = DOOR_CLOSED_LAYER