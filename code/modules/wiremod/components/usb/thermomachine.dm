/**
 * USB wiremod interface for temperature control unit machines
 */
/obj/item/circuit_component/thermomachine
	display_name = "Temperature Control Unit"
	desc = "The interface for communicating with a temperature control unit."

	///Set the target temperature
	var/datum/port/input/temperature
	///Activate the machine
	var/datum/port/input/on
	///Deactivate the machine
	var/datum/port/input/off
	///Signals the circuit to retrieve the machine's current pressure and temperature
	var/datum/port/input/request_data

	///Pressure of the port
	var/datum/port/output/port_pressure
	///Temperature of the port port
	var/datum/port/output/port_temperature

	///Whether the machine is currently active
	var/datum/port/output/is_active
	///Send a signal when the machine is turned on
	var/datum/port/output/turned_on
	///Send a signal when the machine is turned off
	var/datum/port/output/turned_off

	///The component parent object
	var/obj/machinery/atmospherics/components/unary/thermomachine/connected_machine

/obj/item/circuit_component/thermomachine/populate_ports()
	temperature = add_input_port("Set Temperature", PORT_TYPE_NUMBER, trigger = PROC_REF(set_temperature))
	on = add_input_port("Turn On", PORT_TYPE_SIGNAL, trigger = PROC_REF(set_machine_on))
	off = add_input_port("Turn Off", PORT_TYPE_SIGNAL, trigger = PROC_REF(set_machine_off))
	request_data = add_input_port("Request Port Data", PORT_TYPE_SIGNAL, trigger = PROC_REF(request_pump_data))

	port_pressure = add_output_port("Pressure", PORT_TYPE_NUMBER)
	port_temperature = add_output_port("Temperature", PORT_TYPE_NUMBER)

	is_active = add_output_port("Active", PORT_TYPE_NUMBER)
	turned_on = add_output_port("Turned On", PORT_TYPE_SIGNAL)
	turned_off = add_output_port("Turned Off", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/thermomachine/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/atmospherics/components/unary/thermomachine))
		connected_machine = shell
		RegisterSignal(connected_machine, COMSIG_ATMOS_MACHINE_SET_ON, PROC_REF(handle_pump_activation))

/obj/item/circuit_component/thermomachine/unregister_usb_parent(atom/movable/shell)
	UnregisterSignal(connected_machine, COMSIG_ATMOS_MACHINE_SET_ON)
	connected_machine = null
	return ..()

/obj/item/circuit_component/thermomachine/pre_input_received(datum/port/input/port)
	if(connected_machine)
		var/min = connected_machine.min_temperature
		var/max = connected_machine.max_temperature
		temperature.set_value(clamp(temperature.value, min, max))

/obj/item/circuit_component/thermomachine/proc/handle_pump_activation(datum/source, active)
	SIGNAL_HANDLER
	is_active.set_output(active)
	if(active)
		turned_on.set_output(COMPONENT_SIGNAL)
	else
		turned_off.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/thermomachine/proc/set_temperature()
	CIRCUIT_TRIGGER
	if(!connected_machine)
		return
	var/min = connected_machine.min_temperature
	var/max = connected_machine.max_temperature
	connected_machine.target_temperature = clamp(temperature.value, min, max)
	connected_machine.update_icon_state()

/obj/item/circuit_component/thermomachine/proc/set_machine_on()
	CIRCUIT_TRIGGER
	if(!connected_machine)
		return
	connected_machine.set_on(TRUE)
	connected_machine.update_use_power(ACTIVE_POWER_USE)

/obj/item/circuit_component/thermomachine/proc/set_machine_off()
	CIRCUIT_TRIGGER
	if(!connected_machine)
		return
	connected_machine.set_on(FALSE)
	connected_machine.update_use_power(IDLE_POWER_USE)
	connected_machine.update_appearance(UPDATE_ICON)

/obj/item/circuit_component/thermomachine/proc/request_pump_data()
	CIRCUIT_TRIGGER
	if(!connected_machine)
		return
	var/datum/gas_mixture/port = connected_machine.airs[1]
	port_pressure.set_output(port.return_pressure())
	port_temperature.set_output(port.return_temperature())
