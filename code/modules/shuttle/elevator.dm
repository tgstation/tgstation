/obj/docking_port/mobile/elevator
	name = "elevator"
	shuttle_id = "elevator"
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)

/obj/docking_port/mobile/elevator/request(obj/docking_port/stationary/S) //No transit, no ignition, just a simple up/down platform
	initiate_docking(S, force=TRUE)
