/obj/machinery/atmospherics/components/unary
	icon = 'icons/obj/atmospherics/components/unary_devices.dmi'
	dir = SOUTH
	initialize_directions = SOUTH
	layer = TURF_LAYER+0.1
	device_type = UNARY

/obj/machinery/atmospherics/components/unary/SetInitDirections()
	initialize_directions = dir

/*
Iconnery
*/

/obj/machinery/atmospherics/components/unary/hide(intact)
	update_icon()

	..(intact)
