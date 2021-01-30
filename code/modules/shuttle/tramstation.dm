/obj/machinery/computer/shuttle/tramstation
	name = "transit tram shuttle console"
	desc = "Used to call and send the transit shuttle."
	shuttleId = "tram"
	possible_destinations = "tram_left;tram_center;tram_right"
	no_destination_swap = TRUE

/obj/docking_port/mobile/elevator/tram
	name = "tramstation tram dock"
	id = "tram"
	dwidth = 5
	dheight = 5
	width = 11
	height = 5
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
