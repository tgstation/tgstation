/**
 * # Dummy Component
 *
 * Dummy component that does nothing, only for debugging purposes
 *
 * Has two input and output ports that do nothing
 */
/obj/item/circuit_component/dummy
	display_name = "Dummy Component"

	/// The input ports of the dummy component
	var/datum/port/input/receive1
	var/datum/port/input/receive2

	/// The output ports of the dummy component
	var/datum/port/output/output1
	var/datum/port/output/output2

/obj/item/circuit_component/dummy/Initialize()
	. = ..()
	receive1 = add_input_port("Receive 1", PORT_TYPE_ANY)
	receive2 = add_input_port("Receive 2", PORT_TYPE_ANY)

	output1 = add_output_port("Output 1", PORT_TYPE_NUMBER)
	output2 = add_output_port("Output 2", PORT_TYPE_NUMBER)

/obj/item/circuit_component/dummy/Destroy()
	// Cleaned up in parent proc
	receive1 = null
	receive2 = null
	output1 = null
	output2 = null
	return ..()
