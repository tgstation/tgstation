#define MESSENGER_CIRCUIT_MIN_COOLDOWN 5 SECONDS

/obj/item/circuit_component/mod_program/messenger
	associated_program = /datum/computer_file/program/messenger
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	///Contents of the last received message
	var/datum/port/output/received_message
	///Name of the sender of the above
	var/datum/port/output/sender_name
	///Job title of the sender of the above
	var/datum/port/output/sender_job
	///Reference to the device that sent the message. Usually a PDA.
	var/datum/port/output/sender_device

	///A message to be sent when triggered
	var/datum/port/input/message
	///A list of PDA targets for the message to be sent
	var/datum/port/input/targets

/obj/item/circuit_component/mod_program/messenger/populate_ports()
	received_message = add_output_port("Received Message", PORT_TYPE_STRING)
	sender_name = add_output_port("Sender Name", PORT_TYPE_STRING)
	sender_job =  add_output_port("Sender Job", PORT_TYPE_STRING)
	sender_device = add_output_port("Sender Device", PORT_TYPE_ATOM)

	message = add_input_port("Message", PORT_TYPE_STRING)
	targets = add_input_port("Targets", PORT_TYPE_LIST(PORT_TYPE_ATOM))

/obj/item/circuit_component/mod_program/messenger/input_received(datum/port/port)
	var/list/messenger_targets = list()
	for(var/obj/item/modular_computer/computer in targets.value)
		var/datum/computer_file/program/messenger/messenger = locate() in computer.stored_files
		if(messenger)
			messenger_targets += messenger
	var/messenger_length = length(messenger_targets)
	if(!messenger_length)
		return
	var/datum/computer_file/program/messenger/messenger = associated_program
	if(messenger.send_message(src, message.value, messenger_targets))
		COOLDOWN_START(messenger, last_text, max(messenger_length * 1.5 SECONDS, MESSENGER_CIRCUIT_MIN_COOLDOWN))

/obj/item/circuit_component/mod_program/messenger/register_shell(atom/movable/shell)
	. = ..()
	RegisterSignal(associated_program.computer, COMSIG_MODULAR_PDA_MESSAGE_RECEIVED, PROC_REF(message_received))

/obj/item/circuit_component/mod_program/messenger/unregister_shell()
	UnregisterSignal(associated_program.computer, COMSIG_MODULAR_PDA_MESSAGE_RECEIVED)
	return ..()

/obj/item/circuit_component/mod_program/messenger/proc/message_received(datum/source, datum/signal/subspace/messaging/tablet_message/signal, message_job, message_name)
	SIGNAL_HANDLER
	received_message.set_value(signal.data["message"])
	sender_name.set_value(message_name)
	sender_job.set_value(message_job)

	var/atom/source_device
	if(istype(signal.source, /datum/computer_file/program/messenger))
		var/datum/computer_file/program/messenger/sender_messenger = source
		source_device = sender_messenger.computer
	else if(isatom(signal.source))
		source_device = signal.source

	sender_device.set_value(source_device)

/obj/item/circuit_component/mod_program/messenger/get_ui_notices()
	. = ..()
	. += create_ui_notice("Sending a message with this circuit will result in a longer cooldown that scales with the number of recepients.")

#undef MESSENGER_CIRCUIT_MIN_COOLDOWN
