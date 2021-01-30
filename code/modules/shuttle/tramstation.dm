/obj/machinery/computer/shuttle/tramstation
	name = "transit tram shuttle console"
	desc = "Used to call and send the transit shuttle."
	circuit = /obj/item/circuitboard/computer/mining_shuttle
	shuttleId = "tramstation_tram"
	possible_destinations = "tramstation_left;tramstation_center;tramstation_right"
	no_destination_swap = TRUE

/obj/docking_port/mobile/elevator/tram
	name = "tramstation tram dock"
	id = "tramstation_tram"
	dwidth = 3
	width = 7
	height = 7
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
