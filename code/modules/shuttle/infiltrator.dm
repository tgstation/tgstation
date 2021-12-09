/// The syndicate infiltrator shuttle port.
/obj/docking_port/mobile/infiltrator
	name = "syndicate infiltrator"
	id = "syndicate"
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	hidden = TRUE
	dheight = 1
	dwidth = 12
	height = 17
	width = 23
	dir = 8
	port_direction = 4

/obj/docking_port/mobile/infiltrator/Initialize(mapload)
	. = ..()
	SSpoints_of_interest.make_point_of_interest(src)

/obj/docking_port/mobile/infiltrator/Destroy(force)
	SSpoints_of_interest.remove_point_of_interest(src)
	return ..()
