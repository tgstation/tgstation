/*
/obj/machinery/computer/tram_controls
	name = "tram controls"
	desc = "An interface for the tram that lets you tell the tram where to go and hopefully it makes it there. I'm here to describe the controls to you, not to inspire confidence."
	icon_state = "tram_controls"
	base_icon_state = "tram_"
	icon_screen = "tram_Central Wing_idle"
	icon_keyboard = null
	layer = SIGN_LAYER
	density = FALSE
	circuit = /obj/item/circuitboard/computer/tram_controls
	flags_1 = NODECONSTRUCT_1 | SUPERMATTER_IGNORES_1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON|INTERACT_MACHINE_SET_MACHINE
	light_color = COLOR_BLUE_LIGHT
	light_range = 0 //we dont want to spam SSlighting with source updates every movement

	///Weakref to the tram piece we control
	var/datum/weakref/tram_ref

	var/specific_lift_id = MAIN_STATION_TRAM

/obj/machinery/computer/tram_controls/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	AddComponent(/datum/component/usb_port, list(/obj/item/circuit_component/tram_controls))
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/tram_controls/LateInitialize()
	. = ..()
	find_tram()

	var/datum/transport_controller/linear/tram/tram_part = tram_ref?.resolve()
	if(tram_part)
		RegisterSignal(tram_part, COMSIG_ICTS_TRANSPORT_ACTIVE, PROC_REF(update_tram_display))
		icon_screen = "[base_icon_state][tram_part.idle_platform.name]_idle"
		update_appearance(UPDATE_ICON)

/**
 * Finds the tram from the console
 *
 * Locates tram parts in the lift global list after everything is done.
 */
/obj/machinery/computer/tram_controls/proc/find_tram()
	for(var/datum/lift_master/lift as anything in GLOB.active_lifts_by_type[TRAM_LIFT_ID])
		if(lift.specific_lift_id == specific_lift_id)
			tram_ref = WEAKREF(lift)

/obj/machinery/computer/tram_controls/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/*
/obj/machinery/computer/tram_controls/ui_status(mob/user,/datum/tgui/ui)
	var/datum/transport_controller/linear/tram/tram = tram_ref?.resolve()

	if(tram?.travelling)
		return UI_CLOSE
	if(!in_range(user, src) && !isobserver(user))
		return UI_CLOSE
	return ..()
*/

/obj/machinery/computer/tram_controls/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(!user.can_read(src, reading_check_flags = READING_CHECK_LITERACY))
		try_illiterate_movement(user)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TramControl", name)
		ui.open()

/// Traverse to a random location after some time
/obj/machinery/computer/tram_controls/proc/try_illiterate_movement(mob/user)
	var/datum/transport_controller/linear/tram/tram_lift = tram_ref?.resolve()
	if (!tram_lift || tram_lift.travelling)
		return
	user.visible_message(span_notice("[user] starts mashing buttons at random!"))
	if(!do_after(user, 5 SECONDS, target = src))
		return
	if (!tram_lift || tram_lift.travelling)
		to_chat(user, span_warning("The screen displays a flashing error message, but you can't comprehend it."))
		return // Broke or started moving during progress bar
	var/list/all_destinations = GLOB.tram_landmarks[specific_lift_id] || list()
	var/list/possible_destinations = all_destinations.Copy() - tram_lift.idle_platform
	if (!length(possible_destinations))
		to_chat(user, span_warning("The screen displays a flashing error message, but you can't comprehend it."))
		return // No possible places to end up
	try_send_tram(pick(possible_destinations))

/obj/machinery/computer/tram_controls/ui_data(mob/user)
	var/datum/transport_controller/linear/tram/tram_lift = tram_ref?.resolve()
	var/list/data = list()
	data["moving"] = tram_lift?.travelling
	data["broken"] = tram_lift ? FALSE : TRUE
	var/obj/effect/landmark/tram/current_loc = tram_lift?.idle_platform
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
	for(var/obj/effect/landmark/tram/destination as anything in GLOB.tram_landmarks[specific_lift_id])
		var/list/this_destination = list()
		this_destination["name"] = destination.name
		this_destination["dest_icons"] = destination.tgui_icons
		this_destination["id"] = destination.platform_code
		. += list(this_destination)

/obj/machinery/computer/tram_controls/ui_act(action, params)
	. = ..()
	if (.)
		return

	switch (action)
		if ("send")
			var/obj/effect/landmark/tram/destination_platform
			for (var/obj/effect/landmark/tram/destination as anything in GLOB.tram_landmarks[specific_lift_id])
				if(destination.platform_code == params["destination"])
					destination_platform = destination
					break

			if (!destination_platform)
				return FALSE

			return try_send_tram(destination_platform)

/// Attempts to sends the tram to the given destination
/obj/machinery/computer/tram_controls/proc/try_send_tram(obj/effect/landmark/tram/destination_platform)
	var/datum/transport_controller/linear/tram/tram_part = tram_ref?.resolve()
	if(!tram_part)
		return FALSE
	if(tram_part.controls_locked || tram_part.travelling) // someone else started already
		return FALSE
	tram_part.tram_travel(destination_platform)
	say("The next station is: [destination_platform.name]")
	update_appearance()
	return TRUE

/obj/machinery/computer/tram_controls/proc/update_tram_display(obj/effect/landmark/tram/idle_platform, travelling)
	SIGNAL_HANDLER
	var/datum/transport_controller/linear/tram/tram_part = tram_ref?.resolve()
	if(travelling)
		icon_screen = "[base_icon_state][tram_part.idle_platform.name]_active"
	else
		icon_screen = "[base_icon_state][tram_part.idle_platform.name]_idle"
	update_appearance(UPDATE_ICON)
	return PROCESS_KILL

/obj/machinery/computer/tram_controls/power_change() // Change tram operating status on power loss/recovery
	. = ..()
	var/datum/transport_controller/linear/tram/tram_part = tram_ref?.resolve()
	update_operating()
	if(tram_part)
		if(!tram_part.travelling)
			if(is_operational)
				for(var/obj/machinery/crossing_signal/xing as anything in SSicts_transport.crossing_signals)
					xing.set_signal_state(XING_STATE_MALF, TRUE)
				for(var/obj/machinery/destination_sign/desto as anything in SSicts_transport.displays)
					desto.icon_state = "[desto.base_icon_state][DESTINATION_OFF]"
					desto.update_appearance()
			else
				for(var/obj/machinery/crossing_signal/xing as anything in SSicts_transport.crossing_signals)
					xing.set_signal_state(XING_STATE_MALF, TRUE)
				for(var/obj/machinery/destination_sign/desto as anything in SSicts_transport.displays)
					desto.icon_state = "[desto.base_icon_state][DESTINATION_NOT_IN_SERVICE]"
					desto.update_appearance()

/obj/machinery/computer/tram_controls/proc/update_operating() // Pass the operating status from the controls to the lift_master
	var/datum/transport_controller/linear/tram/tram_part = tram_ref?.resolve()
	if(tram_part)
		if(machine_stat & NOPOWER)
			tram_part.is_operational = FALSE
		else
			tram_part.is_operational = TRUE



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
	var/obj/machinery/computer/tram_controls/computer

/obj/item/circuit_component/tram_controls/populate_ports()
	new_destination = add_input_port("Destination", PORT_TYPE_STRING, trigger = null)
	trigger_move = add_input_port("Send Tram", PORT_TYPE_SIGNAL)

	location = add_output_port("Location", PORT_TYPE_STRING)
	travelling_output = add_output_port("Travelling", PORT_TYPE_NUMBER)

/obj/item/circuit_component/tram_controls/register_usb_parent(atom/movable/shell)
	. = ..()
	if (istype(shell, /obj/machinery/computer/tram_controls))
		computer = shell
		var/datum/transport_controller/linear/tram/tram_part = computer.tram_ref?.resolve()
		RegisterSignal(tram_part, COMSIG_ICTS_TRANSPORT_ACTIVE, PROC_REF(on_tram_set_travelling))
		RegisterSignal(tram_part, COMSIG_TRAM_TRAVEL, PROC_REF(on_tram_travel))

/obj/item/circuit_component/tram_controls/unregister_usb_parent(atom/movable/shell)
	var/datum/transport_controller/linear/tram/tram_part = computer.tram_ref?.resolve()
	computer = null
	UnregisterSignal(tram_part, list(COMSIG_ICTS_TRANSPORT_ACTIVE, COMSIG_TRAM_TRAVEL))
	return ..()

/obj/item/circuit_component/tram_controls/input_received(datum/port/input/port)
	if (!COMPONENT_TRIGGERED_BY(trigger_move, port))
		return

	if (isnull(computer))
		return

	if (!computer.powered())
		return

	var/destination
	for(var/obj/effect/landmark/tram/possible_destination as anything in GLOB.tram_landmarks[computer.specific_lift_id])
		if(possible_destination.name == new_destination.value)
			destination = possible_destination
			break

	if (!destination)
		return

	computer.try_send_tram(destination)

/obj/item/circuit_component/tram_controls/proc/on_tram_set_travelling(datum/source, travelling)
	SIGNAL_HANDLER
	travelling_output.set_output(travelling)

/obj/item/circuit_component/tram_controls/proc/on_tram_travel(datum/source, obj/effect/landmark/tram/idle_platform, obj/effect/landmark/tram/destination_platform)
	SIGNAL_HANDLER
	location.set_output(destination_platform.name)

*/




