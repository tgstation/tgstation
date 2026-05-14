/**
 * USB wiremod interface for temperature pumps
 */
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
	heat_transfer_rate = add_input_port("Set Heat Transfer Rate", PORT_TYPE_NUMBER, trigger = PROC_REF(set_pump_heat_rate))
	on = add_input_port("Turn On", PORT_TYPE_SIGNAL, trigger = PROC_REF(set_pump_on))
	off = add_input_port("Turn Off", PORT_TYPE_SIGNAL, trigger = PROC_REF(set_pump_off))
	request_data = add_input_port("Request Port Data", PORT_TYPE_SIGNAL, trigger = PROC_REF(request_pump_data))

	heat_transfer_rate_state = add_output_port("Heat Transfer Rate", PORT_TYPE_NUMBER)
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
