/**
 * ### Quantum Console
 * Links to the quantum computer. Allows the user to access the quantum computer's functions.
 */
/obj/machinery/computer/quantum_console
	name = "quantum console"

	circuit = /obj/item/circuitboard/computer/quantum_console
	icon_keyboard = "security_key"
	icon_screen = "teleport"
	req_access = list(ACCESS_MINING)
	/// The server this console is connected to.
	var/datum/weakref/server_ref

/obj/machinery/computer/quantum_console/Initialize(mapload, obj/item/circuitboard/circuit)
	. = ..()
	desc = "Even in the distant year [CURRENT_STATION_YEAR], Nanostrasen is still using REST APIs. How grim."

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/quantum_console/LateInitialize()
	. = ..()
	if(isnull(server_ref))
		find_server()

/obj/machinery/computer/quantum_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()

	if(isnull(server_ref))
		find_server()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "QuantumConsole")
		ui.open()

/obj/machinery/computer/quantum_console/ui_data()
	var/list/data = list()

	var/obj/machinery/quantum_server/server = find_server()
	if(isnull(server))
		data["connected"] = FALSE
		return data

	data["connected"] = TRUE
	data["generated_domain"] = server.get_current_domain_name()
	data["occupants"] = length(server.occupant_mind_refs)
	data["points"] = server.points
	data["randomized"] = server.domain_randomized
	data["ready"] = server.get_ready_status()
	data["scanner_tier"] = server.scanner_tier

	return data

/obj/machinery/computer/quantum_console/ui_static_data(mob/user)
	var/list/data = list()

	var/obj/machinery/quantum_server/server = find_server()
	if(isnull(server))
		return data

	data["available_domains"] = server.get_available_domains()
	data["avatars"] = server.get_avatar_data()

	return data

/obj/machinery/computer/quantum_console/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return TRUE

	var/obj/machinery/quantum_server/server = find_server()
	if(isnull(server))
		return FALSE

	switch(action)
		if("check_completion")
			if(!server.check_completion(usr))
				return TRUE
			if(!server.generate_loot(usr))
				return TRUE
			server.stop_domain(usr)
			return TRUE
		if("random_domain")
			var/map_id = server.get_random_domain_id()
			if(!map_id)
				return TRUE

			server.fresh_start(usr, map_id)
		if("refresh")
			ui.send_full_update()
			return TRUE
		if("set_domain")
			var/map_id
			for(var/map_template/virtual_domain/domain in subtypesof(/datum/map_template/virtual_domain))
				if(!domain.testing_only && domain.id == params["id"])
					map_id = domain.id
					break
			if(isnull(map_id))
				return TRUE

			server.fresh_start(usr, map_id)
			return TRUE
		if("stop_domain")
			server.stop_domain(usr)
			return TRUE

	return FALSE

/// Attempts to find a quantum server.
/obj/machinery/computer/quantum_console/proc/find_server()
	var/obj/machinery/quantum_server/server = server_ref?.resolve()
	if(server)
		return server

	for(var/direction in GLOB.cardinals)
		var/obj/machinery/quantum_server/nearby_server = locate(/obj/machinery/quantum_server, get_step(src, direction))
		if(nearby_server)
			server_ref = WEAKREF(nearby_server)
			nearby_server.console_ref = WEAKREF(src)
			return nearby_server

	return FALSE
