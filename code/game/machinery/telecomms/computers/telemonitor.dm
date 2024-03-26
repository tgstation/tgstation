/*
	Telecomms monitor tracks the overall trafficing of a telecommunications network
	and displays a heirarchy of linked machines.
*/

#define MAIN_VIEW 0
#define MACHINE_VIEW 1
#define MAX_NETWORK_ID_LENGTH 15

/obj/machinery/computer/telecomms/monitor
	name = "telecommunications monitoring console"
	icon_screen = "comm_monitor"
	desc = "Monitors the details of the telecommunications network it's synced with."

	/// Current screen the user is viewing
	var/screen = MAIN_VIEW
	/// The machines located by the computer
	var/list/machinelist = list()
	/// the currently selected machine
	var/obj/machinery/telecomms/SelectedMachine
	/// The network to probe
	var/network = "NULL"
	/// Error message to show
	var/error_message = ""
	circuit = /obj/item/circuitboard/computer/comm_monitor

/obj/machinery/computer/telecomms/monitor/ui_data(mob/user)
	var/list/data = list(
		"screen" = screen,
		"network" = network,
		"error_message" = error_message,
	)

	switch(screen)
	  	// --- Main Menu ---
		if(MAIN_VIEW)
			var/list/found_machinery = list()
			for(var/obj/machinery/telecomms/telecomms in machinelist)
				found_machinery += list(list("ref" = REF(telecomms), "name" = telecomms.name, "id" = telecomms.id))
			data["machinery"] = found_machinery
	  	// --- Viewing Machine ---
		if(MACHINE_VIEW)
			// Send selected machinery data
			var/list/machine_out = list()
			machine_out["name"] = SelectedMachine.name
			// Get the linked machinery
			var/list/linked_machinery = list()
			for(var/obj/machinery/telecomms/T in SelectedMachine.links)
				linked_machinery += list(list("ref" = REF(T.id), "name" = T.name, "id" = T.id))
			machine_out["linked_machinery"] = linked_machinery
			data["machine"] = machine_out
	return data

/obj/machinery/computer/telecomms/monitor/ui_act(action, params)
	. = ..()
	if(.)
		return .

	error_message = ""

	switch(action)
		// Scan for a network
		if("probe_network")
			var/new_network = params["network_id"]

			if(length(new_network) > MAX_NETWORK_ID_LENGTH)
				error_message = "OPERATION FAILED: NETWORK ID TOO LONG."
				return TRUE

			if(machinelist.len > 0)
				error_message = "OPERATION FAILED: CANNOT PROBE WHEN BUFFER FULL."
				return TRUE

			network = new_network

			for(var/obj/machinery/telecomms/T in urange(25, src))
				if(T.network == network)
					machinelist.Add(T)
			if(machinelist.len == 0)
				error_message = "OPERATION FAILED: UNABLE TO LOCATE NETWORK ENTITIES IN  [network]."
				return TRUE
			error_message = "[machinelist.len] ENTITIES LOCATED & BUFFERED";
			return TRUE
		if("flush_buffer")
			machinelist = list()
			network = ""
			return TRUE
		if("view_machine")
			for(var/obj/machinery/telecomms/T in machinelist)
				if(T.id == params["id"])
					SelectedMachine = T
			if(!SelectedMachine)
				error_message = "OPERATION FAILED: UNABLE TO LOCATE MACHINERY."
			screen = MACHINE_VIEW
			return TRUE
		if("return_home")
			SelectedMachine = null
			screen = MAIN_VIEW
			return TRUE
	return TRUE

/obj/machinery/computer/telecomms/monitor/attackby()
	. = ..()
	updateUsrDialog()

/obj/machinery/computer/telecomms/monitor/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "TelecommsMonitor", name)
		ui.open()

#undef MAIN_VIEW
#undef MACHINE_VIEW
#undef MAX_NETWORK_ID_LENGTH
