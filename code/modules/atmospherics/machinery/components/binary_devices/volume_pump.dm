// Every cycle, the pump uses the air in air_in to try and move a specific volume of gas into air_out.
//
// node1, air1, network1 corresponds to input
// node2, air2, network2 corresponds to output
//
// Thus, the two variables affect pump operation are set in New():
//   air1.volume
//     This is the volume of gas available to the pump that may be transferred to the output
//   air2.volume
//     Higher quantities of this cause more air to be perfected later
//     but overall network volume is also increased as this increases...

/obj/machinery/atmospherics/components/binary/volume_pump
	icon_state = "volpump_map-3"
	name = "volumetric gas pump"
	desc = "A pump that moves gas by volume."
	can_unwrench = TRUE
	shift_underlay_only = FALSE
	construction_type = /obj/item/pipe/directional
	pipe_state = "volumepump"
	vent_movement = NONE
	///Transfer rate of the component in L/s
	var/transfer_rate = MAX_TRANSFER_RATE
	///Check if the component has been overclocked
	var/overclocked = FALSE
	///flashing light overlay which appears on multitooled vol pumps
	var/mutable_appearance/overclock_overlay

/obj/machinery/atmospherics/components/binary/volume_pump/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/atmos_volume_pump,
	))
	register_context()

/obj/machinery/atmospherics/components/binary/volume_pump/click_ctrl(mob/user)
	if(can_interact(user))
		set_on(!on)
		balloon_alert(user, "turned [on ? "on" : "off"]")
		investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
		update_appearance()
		return CLICK_ACTION_SUCCESS
	return CLICK_ACTION_BLOCKING

/obj/machinery/atmospherics/components/binary/volume_pump/click_alt(mob/user)
	if(transfer_rate == MAX_TRANSFER_RATE)
		return CLICK_ACTION_BLOCKING

	transfer_rate = MAX_TRANSFER_RATE
	investigate_log("was set to [transfer_rate] L/s by [key_name(user)]", INVESTIGATE_ATMOS)
	balloon_alert(user, "volume output set to [transfer_rate] L/s")
	update_appearance()
	return CLICK_ACTION_SUCCESS

/obj/machinery/atmospherics/components/binary/volume_pump/update_icon_nopipes()
	icon_state = on && is_operational ? "volpump_on-[set_overlay_offset(piping_layer)]" : "volpump_off-[set_overlay_offset(piping_layer)]"
	var/altlayeroverlay = FALSE
	if(set_overlay_offset(piping_layer) == 2)
		altlayeroverlay = TRUE
	overclock_overlay = mutable_appearance('icons/obj/machines/atmospherics/binary_devices.dmi', "vpumpoverclock[altlayeroverlay ? "2" : ""]")
	if(overclocked && on && is_operational)
		add_overlay(overclock_overlay)
	else
		cut_overlay(overclock_overlay)

/obj/machinery/atmospherics/components/binary/volume_pump/process_atmos()
	if(!on || !is_operational)
		return

	var/datum/gas_mixture/air1 = airs[1]
	var/datum/gas_mixture/air2 = airs[2]

// Pump mechanism just won't do anything if the pressure is too high/too low unless you overclock it.

	var/input_starting_pressure = air1.return_pressure()
	var/output_starting_pressure = air2.return_pressure()

	if((input_starting_pressure < VOLUME_PUMP_MINIMUM_OUTPUT_PRESSURE) || ((output_starting_pressure > VOLUME_PUMP_MAX_OUTPUT_PRESSURE)) && !overclocked)
		return

	var/transfer_ratio = transfer_rate / air1.volume

	var/datum/gas_mixture/removed = air1.remove_ratio(transfer_ratio)

	if(!removed.total_moles())
		return

	if(overclocked)//Some of the gas from the mixture leaks to the environment when overclocked
		var/turf/open/T = loc
		if(istype(T))
			var/datum/gas_mixture/leaked = removed.remove_ratio(VOLUME_PUMP_LEAK_AMOUNT)
			T.assume_air(leaked)

	air2.merge(removed)

	update_parents()

/obj/machinery/atmospherics/components/binary/volume_pump/examine(mob/user)
	. = ..()
	. += span_notice("Its pressure limits could be [overclocked ? "en" : "dis"]abled with a <b>multitool</b>.")
	if(overclocked)
		. += "Its warning light is on[on ? " and it's spewing gas!" : "."]"

/obj/machinery/atmospherics/components/binary/volume_pump/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_CTRL_LMB] = "Turn [on ? "off" : "on"]"
	context[SCREENTIP_CONTEXT_ALT_LMB] = "Maximize transfer rate"
	if(held_item && held_item.tool_behaviour == TOOL_MULTITOOL)
		context[SCREENTIP_CONTEXT_LMB] = "[overclocked ? "En" : "Dis"]able pressure limits"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/atmospherics/components/binary/volume_pump/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosPump", name)
		ui.open()

/obj/machinery/atmospherics/components/binary/volume_pump/ui_data()
	var/data = list()
	data["on"] = on
	data["rate"] = round(transfer_rate)
	data["max_rate"] = round(MAX_TRANSFER_RATE)
	return data

/obj/machinery/atmospherics/components/binary/volume_pump/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			set_on(!on)
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("rate")
			var/rate = params["rate"]
			if(rate == "max")
				rate = MAX_TRANSFER_RATE
				. = TRUE
			else if(text2num(rate) != null)
				rate = text2num(rate)
				. = TRUE
			if(.)
				transfer_rate = clamp(rate, 0, MAX_TRANSFER_RATE)
				investigate_log("was set to [transfer_rate] L/s by [key_name(usr)]", INVESTIGATE_ATMOS)
	update_appearance()

/obj/machinery/atmospherics/components/binary/volume_pump/can_unwrench(mob/user)
	. = ..()
	if(. && on && is_operational)
		to_chat(user, span_warning("You cannot unwrench [src], turn it off first!"))
		return FALSE

/obj/machinery/atmospherics/components/binary/volume_pump/multitool_act(mob/living/user, obj/item/I)
	if(!overclocked)
		overclocked = TRUE
		to_chat(user, "The pump makes a grinding noise and air starts to hiss out as you disable its pressure limits.")
		update_icon()
	else
		overclocked = FALSE
		to_chat(user, "The pump quiets down as you turn its limiters back on.")
		update_icon()
	return TRUE

// mapping

/obj/machinery/atmospherics/components/binary/volume_pump/layer2
	piping_layer = 2
	icon_state = "volpump_map-2"

/obj/machinery/atmospherics/components/binary/volume_pump/layer4
	piping_layer = 4
	icon_state = "volpump_map-4"

/obj/machinery/atmospherics/components/binary/volume_pump/on
	on = TRUE
	icon_state = "volpump_on_map-3"

/obj/machinery/atmospherics/components/binary/volume_pump/on/layer2
	piping_layer = 2
	icon_state = "volpump_on_map-2"

/obj/machinery/atmospherics/components/binary/volume_pump/on/layer4
	piping_layer = 4
	icon_state = "volpump_on_map-4"

/obj/item/circuit_component/atmos_volume_pump
	display_name = "Atmospheric Volume Pump"
	desc = "The interface for communicating with a volume pump."

	///Set the transfer rate of the pump
	var/datum/port/input/transfer_rate
	///Activate the pump
	var/datum/port/input/on
	///Deactivate the pump
	var/datum/port/input/off
	///Signals the circuit to retrieve the pump's current pressure and temperature
	var/datum/port/input/request_data

	///Pressure of the input port
	var/datum/port/output/input_pressure
	///Pressure of the output port
	var/datum/port/output/output_pressure
	///Temperature of the input port
	var/datum/port/output/input_temperature
	///Temperature of the output port
	var/datum/port/output/output_temperature

	///Whether the pump is currently active
	var/datum/port/output/is_active
	///Send a signal when the pump is turned on
	var/datum/port/output/turned_on
	///Send a signal when the pump is turned off
	var/datum/port/output/turned_off

	///The component parent object
	var/obj/machinery/atmospherics/components/binary/volume_pump/connected_pump

/obj/item/circuit_component/atmos_volume_pump/populate_ports()
	transfer_rate = add_input_port("New Transfer Rate", PORT_TYPE_NUMBER, trigger = PROC_REF(set_transfer_rate))
	on = add_input_port("Turn On", PORT_TYPE_SIGNAL, trigger = PROC_REF(set_pump_on))
	off = add_input_port("Turn Off", PORT_TYPE_SIGNAL, trigger = PROC_REF(set_pump_off))
	request_data = add_input_port("Request Port Data", PORT_TYPE_SIGNAL, trigger = PROC_REF(request_pump_data))

	input_pressure = add_output_port("Input Pressure", PORT_TYPE_NUMBER)
	output_pressure = add_output_port("Output Pressure", PORT_TYPE_NUMBER)
	input_temperature = add_output_port("Input Temperature", PORT_TYPE_NUMBER)
	output_temperature = add_output_port("Output Temperature", PORT_TYPE_NUMBER)

	is_active = add_output_port("Active", PORT_TYPE_NUMBER)
	turned_on = add_output_port("Turned On", PORT_TYPE_SIGNAL)
	turned_off = add_output_port("Turned Off", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/atmos_volume_pump/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/atmospherics/components/binary/volume_pump))
		connected_pump = shell
		RegisterSignal(connected_pump, COMSIG_ATMOS_MACHINE_SET_ON, PROC_REF(handle_pump_activation))

/obj/item/circuit_component/atmos_volume_pump/unregister_usb_parent(atom/movable/shell)
	UnregisterSignal(connected_pump, COMSIG_ATMOS_MACHINE_SET_ON)
	connected_pump = null
	return ..()

/obj/item/circuit_component/atmos_volume_pump/pre_input_received(datum/port/input/port)
	transfer_rate.set_value(clamp(transfer_rate.value, 0, MAX_TRANSFER_RATE))

/obj/item/circuit_component/atmos_volume_pump/proc/handle_pump_activation(datum/source, active)
	SIGNAL_HANDLER
	is_active.set_output(active)
	if(active)
		turned_on.set_output(COMPONENT_SIGNAL)
	else
		turned_off.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/atmos_volume_pump/proc/set_transfer_rate()
	CIRCUIT_TRIGGER
	if(!connected_pump)
		return
	connected_pump.transfer_rate = transfer_rate.value

/obj/item/circuit_component/atmos_volume_pump/proc/set_pump_on()
	CIRCUIT_TRIGGER
	if(!connected_pump)
		return
	connected_pump.set_on(TRUE)
	connected_pump.update_appearance()

/obj/item/circuit_component/atmos_volume_pump/proc/set_pump_off()
	CIRCUIT_TRIGGER
	if(!connected_pump)
		return
	connected_pump.set_on(FALSE)
	connected_pump.update_appearance()

/obj/item/circuit_component/atmos_volume_pump/proc/request_pump_data()
	CIRCUIT_TRIGGER
	if(!connected_pump)
		return
	var/datum/gas_mixture/air_input = connected_pump.airs[1]
	var/datum/gas_mixture/air_output = connected_pump.airs[2]
	input_pressure.set_output(air_input.return_pressure())
	output_pressure.set_output(air_output.return_pressure())
	input_temperature.set_output(air_input.return_temperature())
	output_temperature.set_output(air_output.return_temperature())
