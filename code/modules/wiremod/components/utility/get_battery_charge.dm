/**
 * # get battery charge Component
 *
 * Return the current shell's battery charge.
 */
/obj/item/circuit_component/get_battery_charge
	display_name = "get battery charge"
	desc = "A component that returns the current shell's battery charge. The absolute charge is in Joules."
	category = "Utility"

	/// The input signal
	var/datum/port/input/input_sig_read_charge
	/// The output signal
	var/datum/port/output/output_sig_charge_read

	///the cell of the shell.
	var/obj/item/stock_parts/power_store/shell_cell
	///the charge of the cell of the shell (output in percent)
	var/datum/port/output/output_number_percent_charge
	///the charge of the cell of the shell (output in absolute value, Joules)
	var/datum/port/output/output_number_absolute_charge


/obj/item/circuit_component/get_battery_charge/populate_ports()
	/// The input port to trigger reading the charge
	input_sig_read_charge = add_input_port("Read Charge", PORT_TYPE_SIGNAL, trigger = PROC_REF(proc_read_charge))
	/// The output port for the charge percentage
	output_number_percent_charge = add_output_port("Charge Percent", PORT_TYPE_NUMBER)
	/// The output port for the charge absolute value
	output_number_absolute_charge = add_output_port("Charge Absolute", PORT_TYPE_NUMBER)
	output_sig_charge_read = add_output_port("Charge Read", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/get_battery_charge/proc/proc_read_charge()
	CIRCUIT_TRIGGER

	var/atom/movable/shell = parent
	shell_cell = shell.get_cell()

	///output -1 if no cell is found
	output_number_percent_charge.set_output(shell_cell? shell_cell.percent() : -1)
	output_number_absolute_charge.set_output(shell_cell? shell_cell.charge() : -1)

	///output signal when the charge is read, even if the cell is not found
	output_sig_charge_read.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/get_battery_charge/register_shell(atom/movable/shell)
	output_number_percent_charge.set_output(null)
	output_number_absolute_charge.set_output(null)
	output_sig_charge_read.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/get_battery_charge/unregister_shell(atom/movable/shell)
	output_number_percent_charge.set_output(null)
	output_number_absolute_charge.set_output(null)
	output_sig_charge_read.set_output(COMPONENT_SIGNAL)
