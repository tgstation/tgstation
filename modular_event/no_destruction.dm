/obj/structure/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	resistance_flags |= INDESTRUCTIBLE
	flags_1 |= NODECONSTRUCT_1

/obj/machinery/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	resistance_flags |= INDESTRUCTIBLE
	flags_1 |= NODECONSTRUCT_1
