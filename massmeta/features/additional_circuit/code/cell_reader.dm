/**
 * # Cell Charge Component
 *
 * Allows for reading of the max/current charge of the cell in an integrated circuit.
 */
/obj/item/circuit_component/cell_charge
	display_name = "Cell Charge"
	desc = "A component that can read out the max and current charge of the cell."
	category = "Sensor"

	/// max and current charge for the cell
	var/datum/port/output/max_charge
	var/datum/port/output/current_charge

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/cell_charge/populate_ports()
	max_charge = add_output_port("Max Charge", PORT_TYPE_NUMBER)
	current_charge = add_output_port("Current Charge", PORT_TYPE_NUMBER)

/obj/item/circuit_component/cell_charge/input_received(datum/port/input/port)
	var/obj/item/stock_parts/cell/read_cell = parent.cell
	if(!read_cell || !istype(read_cell))
		return
	max_charge.set_output(read_cell.maxcharge)
	current_charge.set_output(read_cell.charge)
