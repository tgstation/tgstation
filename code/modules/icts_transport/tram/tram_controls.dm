/obj/machinery/computer/icts_controls
	name = "tram controls"
	desc = "An interface for the tram that lets you tell the tram where to go and hopefully it makes it there. I'm here to describe the controls to you, not to inspire confidence."
	icon_state = "tram_controls"
	base_icon_state = "tram_"
	icon_screen = "tram_Central Wing_idle"
	icon_keyboard = null
	layer = SIGN_LAYER
	density = FALSE
	circuit = /obj/item/circuitboard/computer/icts_controls
	flags_1 = NODECONSTRUCT_1 | SUPERMATTER_IGNORES_1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	light_color = COLOR_BLUE_LIGHT
	light_range = 0 //we dont want to spam SSlighting with source updates every movement

	///Weakref to the tram piece we control
	var/datum/weakref/module_ref

	var/specific_transport_id = TRAMSTATION_LINE_1

/obj/machinery/computer/icts_controls/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/icts_controls/LateInitialize()
	. = ..()
	SSicts_transport.hello(src)
	find_tram()

	var/datum/transport_controller/linear/tram/icts_controller = module_ref?.resolve()
	if(icts_controller)
		RegisterSignal(SSicts_transport, COMSIG_ICTS_TRANSPORT_ACTIVE, PROC_REF(update_tram_display))

/**
 * Finds the tram from the console
 *
 * Locates tram parts in the lift global list after everything is done.
 */
/obj/machinery/computer/icts_controls/proc/find_tram()
	for(var/datum/transport_controller/linear/transport as anything in SSicts_transport.transports_by_type[ICTS_TYPE_TRAM])
		if(transport.specific_transport_id == specific_transport_id)
			module_ref = WEAKREF(transport)

/obj/machinery/computer/icts_controls/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/obj/machinery/computer/icts_controls/ui_status(mob/user,/datum/tgui/ui)
	var/datum/transport_controller/linear/tram/tram = module_ref?.resolve()

	if(tram?.controller_active)
		return UI_CLOSE
	if(!in_range(user, src) && !isobserver(user))
		return UI_CLOSE
	return ..()

/obj/machinery/computer/icts_controls/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TramControl", name)
		ui.open()

/obj/machinery/computer/icts_controls/ui_data(mob/user)
	var/datum/transport_controller/linear/tram/tram_controller = module_ref?.resolve()
	var/list/data = list()
	data["moving"] = tram_controller?.controller_active
	data["broken"] = tram_controller ? FALSE : TRUE
	var/obj/effect/landmark/icts/nav_beacon/tram/current_loc = tram_controller?.idle_platform
	if(current_loc)
		data["tram_location"] = current_loc.name
	return data

/obj/machinery/computer/icts_controls/ui_static_data(mob/user)
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
/obj/machinery/computer/icts_controls/proc/get_destinations()
	. = list()
	for(var/obj/effect/landmark/icts/nav_beacon/tram/destination as anything in SSicts_transport.nav_beacons[specific_transport_id])
		var/list/this_destination = list()
		this_destination["name"] = destination.name
		this_destination["dest_icons"] = destination.tgui_icons
		this_destination["id"] = destination.platform_code
		. += list(this_destination)

/obj/machinery/computer/icts_controls/ui_act(action, params)
	. = ..()
	if (.)
		return

	switch (action)
		if ("send")
			var/obj/effect/landmark/icts/nav_beacon/tram/destination_platform
			for (var/obj/effect/landmark/icts/nav_beacon/tram/destination as anything in SSicts_transport.nav_beacons[specific_transport_id])
				if(destination.platform_code == params["destination"])
					destination_platform = destination
					break

			if (!destination_platform)
				return FALSE

			SEND_SIGNAL(src, COMSIG_ICTS_REQUEST, specific_transport_id, destination_platform.platform_code)
			update_appearance()

/obj/machinery/computer/icts_controls/proc/update_tram_display(obj/effect/landmark/icts/nav_beacon/tram/idle_platform, controller_active)
	SIGNAL_HANDLER
	var/datum/transport_controller/linear/tram/icts_controller = module_ref?.resolve()
	if(icts_controller.controller_active)
		icon_screen = "[base_icon_state][icts_controller.destination_platform.name]_active"
	else
		icon_screen = "[base_icon_state][icts_controller.destination_platform.name]_idle"
	update_appearance(UPDATE_ICON)
	return PROCESS_KILL

/obj/machinery/computer/icts_controls/power_change() // Change tram operating status on power loss/recovery
	. = ..()
	var/datum/transport_controller/linear/tram/icts_controller = module_ref?.resolve()
	update_operating()
	if(icts_controller)
		for(var/obj/machinery/icts/crossing_signal/xing as anything in SSicts_transport.crossing_signals)
			xing.set_signal_state(XING_STATE_MALF, TRUE)
		if(is_operational)
			for(var/obj/machinery/icts/destination_sign/desto as anything in SSicts_transport.displays)
				desto.icon_state = "[desto.base_icon_state][DESTINATION_OFF]"
				desto.update_appearance()
		else
			//icts_controller.set_status_code(EMERGENCY_STOP, TRUE)
			for(var/obj/machinery/icts/destination_sign/desto as anything in SSicts_transport.displays)
				desto.icon_state = "[desto.base_icon_state][DESTINATION_NOT_IN_SERVICE]"
				desto.update_appearance()

/obj/machinery/computer/icts_controls/proc/update_operating() // Pass the operating status from the controls to the transport_controller
	var/datum/transport_controller/linear/tram/icts_controller = module_ref?.resolve()
	if(icts_controller)
		if(machine_stat & NOPOWER)
			icts_controller.controller_operational = FALSE
		else
			icts_controller.controller_operational = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/icts_controls, 32)
