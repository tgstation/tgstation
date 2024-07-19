/obj/machinery
	/// If TRUE, then this will be affected by things such as the "Bot Language Matrix Malfunction" station trait.
	var/can_language_malfunction = TRUE

/obj/machinery/randomize_language_if_on_station()
	if(can_language_malfunction)
		return ..()
