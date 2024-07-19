/obj/machinery/announcement_system
	can_language_malfunction = FALSE

/obj/machinery/announcement_system/Initialize(mapload)
	. = ..()
	radio.lossless = TRUE
	radio.subspace_transmission = FALSE
