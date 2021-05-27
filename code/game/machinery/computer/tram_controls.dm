/obj/machinery/computer/tram_controls
	name = "tram controls"
	desc = "An interface for the tram that lets you tell the tram where to go and hopefully it makes it there. I'm here to describe the controls to you, not to inspire confidence."
	icon_screen = "tram"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/circuitboard/computer/tram_controls
	flags_1 = NODECONSTRUCT_1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	var/obj/structure/industrial_lift/tram/tram_part
	light_color = LIGHT_COLOR_GREEN

/obj/machinery/computer/tram_controls/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/tram_controls))

/obj/machinery/computer/tram_controls/LateInitialize()
	. = ..()
	//find the tram, late so the tram is all... set up so when this is called? i'm seriously stupid and 90% of what i do consists of barely educated guessing :)
	find_tram()

/**
 * Finds the tram from the console
 *
 * Locates tram parts in the lift global list after everything is done.
 */
/obj/machinery/computer/tram_controls/proc/find_tram()
	var/obj/structure/industrial_lift/tram/central/tram_loc = locate() in GLOB.lifts
	tram_part = tram_loc //possibly setting to something null, that's fine, but
	tram_part.find_our_location()

/obj/machinery/computer/tram_controls/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/obj/machinery/computer/tram_controls/ui_status(mob/user,/datum/tgui/ui)
	if(tram_part.travelling)
		return UI_CLOSE
	if(!in_range(user, src) && !isobserver(user))
		return UI_CLOSE
	return ..()

/obj/machinery/computer/tram_controls/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TramControl", name)
		ui.open()

/obj/machinery/computer/tram_controls/ui_data(mob/user)
	var/list/data = list()
	data["moving"] = tram_part.travelling
	data["broken"] = tram_part ? FALSE : TRUE
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
	for(var/obj/effect/landmark/tram/destination in GLOB.landmarks_list)
		var/list/this_destination = list()
		this_destination["here"] = destination == tram_part.from_where
		this_destination["name"] = destination.name
		this_destination["dest_icons"] = destination.tgui_icons
		this_destination["id"] = destination.destination_id
		. += list(this_destination)

/obj/machinery/computer/tram_controls/ui_act(action, params)
	. = ..()
	if (.)
		return

	switch (action)
		if ("send")
			try_send_tram(params["destination"])

/// Attempts to sends the tram to the given destination
/obj/machinery/computer/tram_controls/proc/try_send_tram(destination_name)
	if(tram_part.travelling)
		return
	var/obj/effect/landmark/tram/to_where
	for(var/obj/effect/landmark/tram/destination in GLOB.landmarks_list)
		if(destination.name == destination_name)
			to_where = destination
	if(!to_where)
		CRASH("Controls couldn't find the destination \"[destination_name]\"!")
	if(tram_part.controls_locked || tram_part.travelling) // someone else started
		return
	tram_part.tram_travel(tram_part.from_where, to_where)
	update_static_data(usr) //show new location of tram

/obj/item/circuit_component/tram_controls
	display_name = "Tram Controls"

	/// The destination to go
	var/datum/port/input/new_destination

	/// The trigger to send the tram
	var/datum/port/input/trigger_move

	/// The tram controls computer (/obj/machinery/computer/tram_controls)
	var/datum/weakref/computer

/obj/item/circuit_component/tram_controls/Initialize()
	. = ..()

	computer = WEAKREF(get(src, /obj/machinery/computer/tram_controls))

	new_destination = add_input_port("Destination", PORT_TYPE_STRING, FALSE)
	trigger_move = add_input_port("Send Tram", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/tram_controls/input_received(datum/port/input/port)
	. = ..()
	if (.)
		return

	if (!COMPONENT_TRIGGERED_BY(trigger_move, port))
		return

	var/obj/machinery/computer/tram_controls/tram_controls = computer.resolve()
	if (!tram_controls)
		return

	tram_controls.try_send_tram(new_destination.input_value)
