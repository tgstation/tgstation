/obj/machinery/atmospherics/components/unary
	icon = 'icons/obj/atmospherics/components/unary_devices.dmi'
	dir = SOUTH
	initialize_directions = SOUTH
	device_type = UNARY
	pipe_flags = PIPING_ONE_PER_TURF
	construction_type = /obj/item/pipe/directional
	///Unique id of the device
	var/uid
	///Increases to prevent duplicated Ids
	var/static/gl_uid = 1

/obj/machinery/atmospherics/components/unary/set_init_directions()
	initialize_directions = dir

/obj/machinery/atmospherics/components/unary/on_construction()
	..()
	update_appearance()

/obj/machinery/atmospherics/components/unary/proc/assign_uid_vents()
	uid = num2text(gl_uid++)
	return uid
