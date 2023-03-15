/**
 * # Send Data Component
 *
 * Sends data between shells
 */
/obj/item/circuit_component/send_data
	display_name = "Send Data"
	display_desc = "A component that sends data to another shell."

	/// The input port
	var/datum/port/input/target
	//The data to send
	var/datum/port/input/data
	//Trigger
	var/datum/port/input/trigger
	var/atom/movable/self

/obj/item/circuit_component/send_data/Initialize(mapload)
	. = ..()
	target = add_input_port("Recipient", PORT_TYPE_ATOM)
	data = add_input_port("Data", PORT_TYPE_ANY)
	trigger = add_input_port("Trigger", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/send_data/register_shell(atom/movable/shell)
	self = shell

/obj/item/circuit_component/send_data/unregister_shell(atom/movable/shell)
	self = null

/obj/item/circuit_component/send_data/Destroy()
	target = null
	data = null
	trigger = null
	return ..()

/obj/item/circuit_component/send_data/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	if(COMPONENT_TRIGGERED_BY(trigger,port))
		var/atom/movable/recipient = target.input_value
		SEND_SIGNAL(recipient,COMSIG_DATA_RECEIVED,data.input_value,self)
