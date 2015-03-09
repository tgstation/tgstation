/obj/machinery/power/solar/panel/fake/New(loc) //This most likely shouldn't exist, but sure
	..(loc)
	disconnect_from_network()

/obj/machinery/power/solar/panel/fake/process()
	return PROCESS_KILL
