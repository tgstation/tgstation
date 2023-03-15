/**
 * # Receive Data Component
 *
 * Receive data from another shell
 */
/obj/item/circuit_component/receive_data
	display_name = "Receive Data"
	display_desc = "A component that receives the data sent from another shell."

	/// The shell that sent the data
	var/datum/port/output/sender
	//The data that was sent
	var/datum/port/output/data
	//Trigger
	var/datum/port/output/triggered

/obj/item/circuit_component/receive_data/Initialize(mapload)
	. = ..()
	sender = add_output_port("Sender", PORT_TYPE_ATOM)
	data = add_output_port("Data", PORT_TYPE_ANY)
	triggered = add_output_port("Triggered", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/receive_data/Destroy()
	sender = null
	data = null
	triggered = null
	return ..()

/obj/item/circuit_component/receive_data/register_shell(atom/movable/shell)
	RegisterSignal(shell, COMSIG_DATA_RECEIVED, .proc/on_data_received)

/obj/item/circuit_component/receive_data/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_DATA_RECEIVED)

/obj/item/circuit_component/receive_data/proc/on_data_received(atom/source, received_data, atom/sent_from)
	SIGNAL_HANDLER
	sender.set_output(sent_from)
	data.set_output(received_data)
	triggered.set_output(COMPONENT_SIGNAL)
