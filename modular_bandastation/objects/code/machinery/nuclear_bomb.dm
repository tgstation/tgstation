/obj/machinery/nuclearbomb/Initialize(mapload)
	. = ..()
	r_code = random_nukecode() // Gives every nuke a unique code by default instead of "ADMIN"
