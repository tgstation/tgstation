/obj/machinery/atmospherics/components/binary/temperature_pump
	icon_state = "tpump_map-3"
	name = "temperature pump"
	desc = "A pump that moves heat from one pipeline to another. The input will get cooler, and the output will get hotter."
	can_unwrench = TRUE
	shift_underlay_only = FALSE
	construction_type = /obj/item/pipe/directional
	pipe_state = "tpump"
	vent_movement = NONE
	///Percent of the heat delta to transfer
	var/heat_transfer_rate = 0
	///Maximum allowed transfer percentage
	var/max_heat_transfer_rate = 100

/obj/machinery/atmospherics/components/binary/temperature_pump/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/usb_port, typecacheof(list(/obj/item/circuit_component/atmos_temperature_pump), only_root_path = TRUE))
	register_context()

/obj/machinery/atmospherics/components/binary/temperature_pump/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_CTRL_LMB] = "Turn [on ? "off" : "on"]"
	context[SCREENTIP_CONTEXT_ALT_LMB] = "Maximize transfer rate"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/atmospherics/components/binary/temperature_pump/click_ctrl(mob/user)
	if(is_operational)
		set_on(!on)
		balloon_alert(user, "turned [on ? "on" : "off"]")
		investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
		return CLICK_ACTION_SUCCESS
	return CLICK_ACTION_BLOCKING

/obj/machinery/atmospherics/components/binary/temperature_pump/click_alt(mob/user)
	if(heat_transfer_rate == max_heat_transfer_rate)
		return CLICK_ACTION_BLOCKING

	heat_transfer_rate = max_heat_transfer_rate
	investigate_log("was set to [heat_transfer_rate]% by [key_name(user)]", INVESTIGATE_ATMOS)
	balloon_alert(user, "transfer rate set to [heat_transfer_rate]%")
	update_appearance(UPDATE_ICON)
	return CLICK_ACTION_SUCCESS

/obj/machinery/atmospherics/components/binary/temperature_pump/update_icon_nopipes()
	icon_state = "tpump_[on && is_operational ? "on" : "off"]-[set_overlay_offset(piping_layer)]"

/obj/machinery/atmospherics/components/binary/temperature_pump/process_atmos()
	if(!on || !is_operational)
		return

	var/datum/gas_mixture/air_input = airs[1]
	var/datum/gas_mixture/air_output = airs[2]

	if(!QUANTIZE(air_input.total_moles()) || !QUANTIZE(air_output.total_moles())) //Don't transfer if there's no gas
		return
	var/datum/gas_mixture/remove_input = air_input.remove_ratio(0.9)
	var/datum/gas_mixture/remove_output = air_output.remove_ratio(0.9)

	var/coolant_temperature_delta = remove_input.temperature - remove_output.temperature

	if(coolant_temperature_delta > 0)
		var/input_capacity = remove_input.heat_capacity()
		var/output_capacity = remove_output.heat_capacity()

		var/cooling_heat_amount = (heat_transfer_rate * 0.01) * CALCULATE_CONDUCTION_ENERGY(coolant_temperature_delta, output_capacity, input_capacity)
		remove_output.temperature = max(remove_output.temperature + (cooling_heat_amount / output_capacity), TCMB)
		remove_input.temperature = max(remove_input.temperature - (cooling_heat_amount / input_capacity), TCMB)
		update_parents()

	var/power_usage = 200

	air_input.merge(remove_input)
	air_output.merge(remove_output)

	if(power_usage)
		use_energy(power_usage)

/obj/machinery/atmospherics/components/binary/temperature_pump/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosTempPump", name)
		ui.open()

/obj/machinery/atmospherics/components/binary/temperature_pump/ui_data()
	var/data = list()
	data["on"] = on
	data["rate"] = round(heat_transfer_rate)
	data["max_heat_transfer_rate"] = round(max_heat_transfer_rate)
	return data

/obj/machinery/atmospherics/components/binary/temperature_pump/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
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
				rate = max_heat_transfer_rate
				. = TRUE
			else if(text2num(rate) != null)
				rate = text2num(rate)
				. = TRUE
			if(.)
				heat_transfer_rate = clamp(rate, 0, max_heat_transfer_rate)
				investigate_log("was set to [heat_transfer_rate]% by [key_name(usr)]", INVESTIGATE_ATMOS)
	update_appearance(UPDATE_ICON)

//mapping

/obj/machinery/atmospherics/components/binary/temperature_pump/layer2
	icon_state = "tpump_map-2"
	piping_layer = 2

/obj/machinery/atmospherics/components/binary/temperature_pump/layer4
	icon_state = "tpump_map-4"
	piping_layer = 4

/obj/machinery/atmospherics/components/binary/temperature_pump/on
	on = TRUE
	icon_state = "tpump_on_map-3"

/obj/machinery/atmospherics/components/binary/temperature_pump/on/layer2
	icon_state = "tpump_on_map-2"
	piping_layer = 2

/obj/machinery/atmospherics/components/binary/temperature_pump/on/layer4
	icon_state = "tpump_on_map-4"
	piping_layer = 4

//	USB

/obj/item/circuit_component/atmos_temperature_pump
	display_name = "Atmospheric Temperature Pump"
	desc = "The interface for communicating with a temperature pump."

	///Set the percent of the heat delta to transfer
	var/datum/port/input/heat_transfer_rate
	///Activate the pump
	var/datum/port/input/on
	///Deactivate the pump
	var/datum/port/input/off
	///Signals the circuit to retrieve the pump's current percent and temperature
	var/datum/port/input/request_data

	///Current status of the percent
	var/datum/port/output/heat_transfer_rate_state
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
	var/obj/machinery/atmospherics/components/binary/temperature_pump/connected_pump

/obj/item/circuit_component/atmos_temperature_pump/populate_ports()
	heat_transfer_rate = add_input_port("New heat transfer rate", PORT_TYPE_NUMBER, trigger = PROC_REF(set_pump_heat_rate))
	on = add_input_port("Turn On", PORT_TYPE_SIGNAL, trigger = PROC_REF(set_pump_on))
	off = add_input_port("Turn Off", PORT_TYPE_SIGNAL, trigger = PROC_REF(set_pump_off))
	request_data = add_input_port("Request Port Data", PORT_TYPE_SIGNAL, trigger = PROC_REF(request_pump_data))

	heat_transfer_rate_state = add_output_port("Heat transfer rate", PORT_TYPE_NUMBER)
	input_pressure = add_output_port("Input Pressure", PORT_TYPE_NUMBER)
	output_pressure = add_output_port("Output Pressure", PORT_TYPE_NUMBER)
	input_temperature = add_output_port("Input Temperature", PORT_TYPE_NUMBER)
	output_temperature = add_output_port("Output Temperature", PORT_TYPE_NUMBER)

	is_active = add_output_port("Active", PORT_TYPE_NUMBER)
	turned_on = add_output_port("Turned On", PORT_TYPE_SIGNAL)
	turned_off = add_output_port("Turned Off", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/atmos_temperature_pump/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/atmospherics/components/binary/temperature_pump))
		connected_pump = shell
		RegisterSignal(connected_pump, COMSIG_ATMOS_MACHINE_SET_ON, PROC_REF(handle_pump_activation))

/obj/item/circuit_component/atmos_temperature_pump/unregister_usb_parent(atom/movable/shell)
	UnregisterSignal(connected_pump, COMSIG_ATMOS_MACHINE_SET_ON)
	connected_pump = null
	return ..()

/obj/item/circuit_component/atmos_temperature_pump/pre_input_received(datum/port/input/port)
	heat_transfer_rate.set_value(clamp(heat_transfer_rate.value, 0, connected_pump ? connected_pump.max_heat_transfer_rate : 100))

/obj/item/circuit_component/atmos_temperature_pump/proc/handle_pump_activation(datum/source, active)
	SIGNAL_HANDLER
	is_active.set_output(active)
	if(active)
		turned_on.set_output(COMPONENT_SIGNAL)
	else
		turned_off.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/atmos_temperature_pump/proc/set_pump_heat_rate()
	CIRCUIT_TRIGGER
	if(!connected_pump)
		return
	connected_pump.heat_transfer_rate = heat_transfer_rate.value

/obj/item/circuit_component/atmos_temperature_pump/proc/set_pump_on()
	CIRCUIT_TRIGGER
	if(!connected_pump)
		return
	connected_pump.set_on(TRUE)

/obj/item/circuit_component/atmos_temperature_pump/proc/set_pump_off()
	CIRCUIT_TRIGGER
	if(!connected_pump)
		return
	connected_pump.set_on(FALSE)
	connected_pump.update_appearance(UPDATE_ICON)

/obj/item/circuit_component/atmos_temperature_pump/proc/request_pump_data()
	CIRCUIT_TRIGGER
	if(!connected_pump)
		return
	var/datum/gas_mixture/air_input = connected_pump.airs[1]
	var/datum/gas_mixture/air_output = connected_pump.airs[2]
	heat_transfer_rate_state.set_output(connected_pump.heat_transfer_rate)
	input_pressure.set_output(air_input.return_pressure())
	output_pressure.set_output(air_output.return_pressure())
	input_temperature.set_output(air_input.return_temperature())
	output_temperature.set_output(air_output.return_temperature())
