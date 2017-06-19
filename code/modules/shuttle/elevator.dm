/obj/docking_port/mobile/elevator
	name = "elevator"
	id = "elevator"
	dwidth = 3
	width = 7
	height = 7
	knockdown = FALSE

/obj/docking_port/mobile/elevator/request(obj/docking_port/stationary/S) //No transit, no ignition, just a simple up/down platform
	dock(S, TRUE)