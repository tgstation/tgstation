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
	SStransport.hello(src)
	find_tram()

	var/datum/transport_controller/linear/tram/icts_controller = module_ref?.resolve()
	if(icts_controller)
		RegisterSignal(SStransport, COMSIG_TRANSPORT_ACTIVE, PROC_REF(update_tram_display))

/**
 * Finds the tram from the console
 *
 * Locates tram parts in the lift global list after everything is done.
 */
/obj/machinery/computer/icts_controls/proc/find_tram()
	for(var/datum/transport_controller/linear/transport as anything in SStransport.transports_by_type[TRANSPORT_TYPE_TRAM])
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
	data["broken"] = (tram_controller ? FALSE : TRUE) || (tram_controller?.paired_cabinet ? FALSE : TRUE)
	var/obj/effect/landmark/icts/nav_beacon/tram/platform/current_loc = tram_controller?.idle_platform
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
	for(var/obj/effect/landmark/icts/nav_beacon/tram/platform/destination as anything in SStransport.nav_beacons[specific_transport_id])
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
			var/obj/effect/landmark/icts/nav_beacon/tram/platform/destination_platform
			for (var/obj/effect/landmark/icts/nav_beacon/tram/platform/destination as anything in SStransport.nav_beacons[specific_transport_id])
				if(destination.platform_code == params["destination"])
					destination_platform = destination
					break

			if (!destination_platform)
				return FALSE

			SEND_SIGNAL(src, COMSIG_TRANSPORT_REQUEST, specific_transport_id, destination_platform.platform_code)
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

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/icts_controls, 32)
