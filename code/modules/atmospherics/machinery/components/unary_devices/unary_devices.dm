/obj/machinery/atmospherics/components/unary
	icon = 'icons/obj/atmospherics/components/unary_devices.dmi'
	dir = SOUTH
	initialize_directions = SOUTH
	device_type = UNARY
	pipe_flags = PIPING_ONE_PER_TURF
	construction_type = /obj/item/pipe/directional
	var/uid
	var/static/gl_uid = 1

/obj/machinery/atmospherics/components/unary/SetInitDirections()
	initialize_directions = dir

/obj/machinery/atmospherics/components/unary/on_construction()
	..()
	update_icon()

/obj/machinery/atmospherics/components/unary/proc/assign_uid_vents()
	uid = num2text(gl_uid++)
	return uid

/**
 * Assign a name to unary devices
 *
 * Creates a randomly generated tag for a unary devices based on the passed in name prefix
 * appending a 5 character random tag to the end.
 * This makes the devices show up seperatly in air alarms and have a unique name on mouse over.
 * args:
 * * proper_name (string) The prefix for the name
 * Returns (string) The generated name
 */
/obj/machinery/atmospherics/components/unary/proc/assign_random_name(proper_name)
	var/new_name = proper_name
	for(var/i = 1 to 5)
		switch(rand(1,3))
			if(1)
				new_name += ascii2text(rand(65, 90)) // A - Z
			if(2)
				new_name += ascii2text(rand(97,122)) // a - z
			if(3)
				new_name += ascii2text(rand(48, 57)) // 0 - 9
	return new_name
