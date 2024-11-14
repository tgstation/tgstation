/obj/machinery/computer/tram_controls
	name = "tram controls"
	desc = "An interface for the tram that lets you tell the tram where to go and hopefully it makes it there. I'm here to describe the controls to you, not to inspire confidence."
	icon_state = "tram_controls"
	base_icon_state = "tram"
	icon_screen = TRAMSTATION_LINE_1
	icon_keyboard = null
	layer = SIGN_LAYER
	density = FALSE
	max_integrity = 400
	integrity_failure = 0.1
	power_channel = AREA_USAGE_ENVIRON
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.25
	armor_type = /datum/armor/transport_machinery
	circuit = /obj/item/circuitboard/computer/tram_controls
	light_color = COLOR_BLUE_LIGHT
	light_range = 0 //we dont want to spam SSlighting with source updates every movement
	brightness_on = 0
	/// What sign face prefixes we have icons for
	var/static/list/available_faces = list()
	/// The sign face we're displaying
	var/sign_face
	/// Weakref to the tram piece we control
	var/datum/weakref/transport_ref
	/// The ID of the tram we're controlling
	var/specific_transport_id = TRAMSTATION_LINE_1
	/// If the sign is adjusted for split type tram windows
	var/split_mode = FALSE

/obj/machinery/computer/tram_controls/split
	circuit = /obj/item/circuitboard/computer/tram_controls/split
	split_mode = TRUE

/obj/machinery/computer/tram_controls/split/directional/north
	dir = SOUTH
	pixel_x = -8
	pixel_y = 32

/obj/machinery/computer/tram_controls/split/directional/south
	dir = NORTH
	pixel_x = 8
	pixel_y = -32

/obj/machinery/computer/tram_controls/split/directional/east
	dir = WEST
	pixel_x = 32

/obj/machinery/computer/tram_controls/split/directional/west
	dir = EAST
	pixel_x = -32

/obj/machinery/computer/tram_controls/Initialize(mapload)
	. = ..()
	var/obj/item/circuitboard/computer/tram_controls/my_circuit = circuit
	split_mode = my_circuit.split_mode

/obj/machinery/computer/tram_controls/post_machine_initialize()
	. = ..()
	if(!id_tag)
		id_tag = assign_random_name()
	SStransport.hello(src, name, id_tag)
	RegisterSignal(SStransport, COMSIG_TRANSPORT_RESPONSE, PROC_REF(call_response))
	find_tram()

	var/datum/transport_controller/linear/tram/tram = transport_ref?.resolve()
	if(tram)
		RegisterSignal(SStransport, COMSIG_TRANSPORT_ACTIVE, PROC_REF(update_display))

/obj/machinery/computer/tram_controls/update_current_power_usage()
	return // We get power from area rectifiers

/**
 * Finds the tram from the console
 *
 * Locates tram parts in the lift global list after everything is done.
 */
/obj/machinery/computer/tram_controls/proc/find_tram()
	for(var/datum/transport_controller/linear/transport as anything in SStransport.transports_by_type[TRANSPORT_TYPE_TRAM])
		if(transport.specific_transport_id == specific_transport_id)
			transport_ref = WEAKREF(transport)
			return

/obj/machinery/computer/tram_controls/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/obj/machinery/computer/tram_controls/ui_status(mob/user, datum/tgui/ui)
	var/datum/transport_controller/linear/tram/tram = transport_ref?.resolve()

	if(tram?.controller_active)
		return UI_CLOSE
	if(!in_range(user, src) && !isobserver(user))
		return UI_CLOSE
	return ..()

/obj/machinery/computer/tram_controls/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TramControl", name)
		ui.open()

/obj/machinery/computer/tram_controls/ui_data(mob/user)
	var/datum/transport_controller/linear/tram/tram_controller = transport_ref?.resolve()
	var/list/data = list()
	data["moving"] = tram_controller?.controller_active
	data["broken"] = (tram_controller ? FALSE : TRUE) || (tram_controller?.paired_cabinet ? FALSE : TRUE)
	var/obj/effect/landmark/transport/nav_beacon/tram/platform/current_loc = tram_controller?.idle_platform
	if(current_loc)
		data["tram_location"] = current_loc.name
	return data

/obj/machinery/computer/tram_controls/ui_static_data(mob/user)
	var/list/data = list()
	data["destinations"] = get_destinations()
	return data

/**
 * Finds the destinations for the tram console gui
 *
 * Pulls tram landmarks from the landmark gobal list
 * and uses those to show the proper icons and destination
 * names for the tram console gui.
 */
/obj/machinery/computer/tram_controls/proc/get_destinations()
	. = list()
	for(var/obj/effect/landmark/transport/nav_beacon/tram/platform/destination as anything in SStransport.nav_beacons[specific_transport_id])
		var/list/this_destination = list()
		this_destination["name"] = destination.name
		this_destination["dest_icons"] = destination.tgui_icons
		this_destination["id"] = destination.platform_code
		. += list(this_destination)

/obj/machinery/computer/tram_controls/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("send")
			var/obj/effect/landmark/transport/nav_beacon/tram/platform/destination_platform
			for(var/obj/effect/landmark/transport/nav_beacon/tram/platform/destination as anything in SStransport.nav_beacons[specific_transport_id])
				if(destination.platform_code == params["destination"])
					destination_platform = destination
					break

			if(isnull(destination_platform))
				return FALSE

			SStransport.incoming_request(src, specific_transport_id, destination_platform.platform_code)
			update_appearance()

/obj/machinery/computer/tram_controls/proc/update_display(datum/source, datum/transport_controller/linear/tram/controller, controller_active, controller_status, travel_direction, obj/effect/landmark/transport/nav_beacon/tram/platform/destination_platform)
	SIGNAL_HANDLER

	if(machine_stat & (NOPOWER|BROKEN))
		icon_screen = null
		update_appearance()
		return

	if(isnull(controller) || !controller.controller_operational)
		icon_screen = "[base_icon_state]_broken"
		update_appearance()
		return

	if(isnull(destination_platform))
		icon_screen = "[specific_transport_id]"
		update_appearance()
		return

	if(controller.controller_status & EMERGENCY_STOP || controller.controller_status & SYSTEM_FAULT)
		icon_screen = "[base_icon_state]_NIS"
		update_appearance()
		return

	if(controller_active)
		icon_screen = "[base_icon_state]_0[travel_direction]"
		update_appearance()
		return

	icon_screen = ""
	icon_screen += "[controller.specific_transport_id]"
	icon_screen += "[destination_platform.platform_code]"

	update_appearance()

/obj/machinery/computer/tram_controls/on_construction(mob/user)
	. = ..()
	var/obj/item/circuitboard/computer/tram_controls/my_circuit = circuit
	split_mode = my_circuit.split_mode
	if(split_mode)
		switch(dir)
			if(NORTH)
				pixel_x = 8
				pixel_y = -32
			if(SOUTH)
				pixel_x = -8
				pixel_y = 32
			if(EAST)
				pixel_x = -32
				pixel_y = -8
			if(WEST)
				pixel_x = 32
				pixel_y = 8
	else
		switch(dir)
			if(NORTH)
				pixel_y = -32
			if(SOUTH)
				pixel_y = 32
			if(EAST)
				pixel_x = -32
			if(WEST)
				pixel_x = 32

/obj/machinery/computer/tram_controls/update_overlays()
	. = ..()

	if(isnull(icon_screen))
		return

	. += emissive_appearance(icon, icon_screen, src, alpha = src.alpha)

/obj/machinery/computer/tram_controls/power_change()
	..()
	var/datum/transport_controller/linear/tram/tram = transport_ref?.resolve()
	if(isnull(tram))
		icon_screen = "[base_icon_state]_broken"
		update_appearance()
		return

	update_display(src, tram, tram.controller_active, tram.controller_status, tram.travel_direction, tram.destination_platform)

/obj/machinery/computer/tram_controls/proc/call_response(controller, list/relevant, response_code, response_info)
	SIGNAL_HANDLER
	switch(response_code)
		if(REQUEST_SUCCESS)
			say("The next station is: [response_info]")

		if(REQUEST_FAIL)
			if(!LAZYFIND(relevant, src))
				return

			switch(response_info)
				if(NOT_IN_SERVICE)
					say("The tram is not in service. Please contact the nearest engineer.")
				if(INVALID_PLATFORM)
					say("Configuration error. Please contact the nearest engineer.")
				if(INTERNAL_ERROR)
					say("Tram controller error. Please contact the nearest engineer or crew member with telecommunications access to reset the controller.")
				else
					return

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/tram_controls, 32)
