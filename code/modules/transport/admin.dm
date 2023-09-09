// Helper tool to try and fix broken trams
/datum/admins/proc/reset_tram()
	set name = "Reset Tram"
	set category = "Debug"
	var/static/list/debug_tram_list = list(
	TRAMSTATION_LINE_1,
	BIRDSHOT_LINE_1,
	BIRDSHOT_LINE_2,
	HILBERT_LINE_1,
	)

	if(!check_rights(R_DEBUG))
		return

	var/datum/transport_controller/linear/tram/broken_controller
	var/selected_transport_id = tgui_input_list(usr, "Which tram?", "Off the rails", debug_tram_list)
	var/reset_type = tgui_input_list(usr, "How hard of a reset?", "How bad is it screwed up", list("Controller", "Full", "Delete Datum", "Cancel"))

	if(isnull(reset_type))
		return

	for(var/datum/transport_controller/linear/tram/transport as anything in SStransport.transports_by_type[TRANSPORT_TYPE_TRAM])
		if(transport.specific_transport_id == selected_transport_id)
			broken_controller = transport
			break

	if(isnull(broken_controller))
		to_chat(usr, span_warning("Couldn't find a transport controller datum with ID [selected_transport_id]!"))
		return

	switch(reset_type)
		if("Controller")
			broken_controller.reset_position()
			message_admins("[key_name_admin(usr)] performed a controller reset of tram ID [selected_transport_id].")

		if("Full")
			broken_controller.reset_lift_contents()
			broken_controller.reset_position()
			message_admins("[key_name_admin(usr)] performed a controller and contents reset of tram ID [selected_transport_id].")

		if("Delete Datum")
			var/obj/machinery/transport/tram_controller/tram_cabinet = broken_controller.paired_cabinet
			if(!isnull(tram_cabinet))
				tram_cabinet.controller_datum = null
				tram_cabinet.update_appearance()

			broken_controller.cycle_doors(CYCLE_OPEN, BYPASS_DOOR_CHECKS)
			broken_controller.estop()
			qdel(broken_controller)
			message_admins("[key_name_admin(usr)] performed a datum delete of tram ID [selected_transport_id].")
