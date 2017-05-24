
//where for art thou duncathan

/obj/machinery/atmospherics/pipe/simple/multiz
	icon = 'icons/obj/atmospherics/pipes/multiz.dmi'
	var/basestate

/obj/machinery/atmospherics/pipe/simple/multiz/update_icon()
	icon_state = "[basestate][invisibility ? "-f" : "" ]"


/obj/machinery/atmospherics/pipe/simple/multiz/up
	initialize_directions = SOUTH|UP
	basestate = "up"

/obj/machinery/atmospherics/pipe/simple/multiz/up/SetInitDirections()
	initialize_directions = dir|UP


/obj/machinery/atmospherics/pipe/simple/multiz/down
	initialize_directions = SOUTH|DOWN
	basestate = "down"

/obj/machinery/atmospherics/pipe/simple/multiz/down/SetInitDirections()
	initialize_directions = dir|DOWN

