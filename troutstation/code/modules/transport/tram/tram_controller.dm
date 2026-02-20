/obj/machinery/transport/tram_controller/tiss
	configured_transport_id = TISS_LINE_1

/obj/machinery/transport/tram_controller/tiss/find_controller()
	for(var/datum/transport_controller/linear/tram/tram as anything in SStransport.transports_by_type[TRANSPORT_TYPE_TRAM])
		if(tram.specific_transport_id == configured_transport_id)
			controller_datum = tram
			break

	if(!controller_datum)
		return

	controller_datum.notify_controller(src)
	RegisterSignal(SStransport, COMSIG_TRANSPORT_UPDATED, PROC_REF(sync_controller))
