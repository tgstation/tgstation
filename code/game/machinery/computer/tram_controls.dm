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
	return INITIALIZE_HINT_LATELOAD

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
	tram_part = GLOB.central_tram //possibly setting to something null, that's fine

/obj/machinery/computer/tram_controls/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/obj/machinery/computer/tram_controls/ui_status(mob/user,/datum/tgui/ui)
	if(tram_part?.travelling)
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
	data["moving"] = tram_part?.travelling
	data["broken"] = tram_part ? FALSE : TRUE
	var/obj/effect/landmark/tram/current_loc = tram_part?.from_where
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
	for(var/obj/effect/landmark/tram/destination as anything in GLOB.tram_landmarks)
		var/list/this_destination = list()
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
			var/obj/effect/landmark/tram/to_where
			for (var/obj/effect/landmark/tram/destination as anything in GLOB.tram_landmarks)
				if(destination.destination_id == params["destination"])
					to_where = destination
					break

			if (!to_where)
				return FALSE

			return try_send_tram(to_where)

/// Attempts to sends the tram to the given destination
/obj/machinery/computer/tram_controls/proc/try_send_tram(obj/effect/landmark/tram/to_where)
	if(tram_part.travelling)
		return FALSE
	if(tram_part.controls_locked || tram_part.travelling) // someone else started
		return FALSE
	tram_part.tram_travel(to_where)
	return TRUE

/obj/item/circuit_component/tram_controls
	display_name = "Tram Controls"

	/// The destination to go
	var/datum/port/input/new_destination

	/// The trigger to send the tram
	var/datum/port/input/trigger_move

	/// The current location
	var/datum/port/output/location

	/// Whether or not the tram is moving
	var/datum/port/output/travelling_output

	/// The tram controls computer (/obj/machinery/computer/tram_controls)
	var/datum/weakref/computer

/obj/item/circuit_component/tram_controls/Initialize()
	. = ..()

	var/obj/machinery/computer/tram_controls/computer_object = get(src, /obj/machinery/computer/tram_controls)
	if (computer_object)
		computer = WEAKREF(computer_object)

		RegisterSignal(computer_object.tram_part, COMSIG_TRAM_SET_TRAVELLING, .proc/on_tram_set_travelling)
		RegisterSignal(computer_object.tram_part, COMSIG_TRAM_TRAVEL, .proc/on_tram_travel)

	new_destination = add_input_port("Destination", PORT_TYPE_STRING, FALSE)
	trigger_move = add_input_port("Send Tram", PORT_TYPE_SIGNAL)

	location = add_output_port("Location", PORT_TYPE_STRING)
	travelling_output = add_output_port("Travelling", PORT_TYPE_NUMBER)

/obj/item/circuit_component/tram_controls/Destroy()
	new_destination = null
	trigger_move = null
	location = null
	travelling_output = null
	computer = null
	return ..()

/obj/item/circuit_component/tram_controls/input_received(datum/port/input/port)
	. = ..()
	if (.)
		return

	if (!COMPONENT_TRIGGERED_BY(trigger_move, port))
		return

	var/obj/machinery/computer/tram_controls/tram_controls = computer.resolve()

	if (isnull(tram_controls))
		return

	if (!tram_controls.powered())
		return

	var/destination

	for(var/obj/effect/landmark/tram/possible_destination as anything in GLOB.tram_landmarks)
		if(possible_destination.name == new_destination.input_value)
			destination = possible_destination
			break

	if (!destination)
		return

	tram_controls.try_send_tram(destination)

/obj/item/circuit_component/tram_controls/proc/on_tram_set_travelling(datum/source, travelling)
	SIGNAL_HANDLER

	travelling_output.set_output(travelling)

/obj/item/circuit_component/tram_controls/proc/on_tram_travel(datum/source, obj/effect/landmark/tram/from_where, obj/effect/landmark/tram/to_where)
	SIGNAL_HANDLER

	location.set_output(to_where.name)
