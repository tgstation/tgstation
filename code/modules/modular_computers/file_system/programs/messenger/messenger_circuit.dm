#define MESSENGER_CIRCUIT_MIN_COOLDOWN 5 SECONDS
#define MESSENGER_CIRCUIT_MAX_COOLDOWN 45 SECONDS
#define MESSENGER_CIRCUIT_CD_PER_RECIPIENT 1.5 SECONDS
#define MESSENGER_CIRCUIT_RINGTONE_CD 1.5 SECONDS

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
	///Pinged whenever a message is received.
	var/datum/port/output/received

	///A message to be sent when triggered
	var/datum/port/input/message
	///A list of PDA targets for the message to be sent
	var/datum/port/input/targets

	///Plays the ringtone when the input is received
	var/datum/port/input/ring
	///Set the ringtone to the input
	var/datum/port/input/set_ring

	///the cooldown of the ringtone.
	COOLDOWN_DECLARE(ring_cd)

/obj/item/circuit_component/mod_program/messenger/populate_ports()
	. = ..()
	received_message = add_output_port("Message", PORT_TYPE_STRING)
	sender_name = add_output_port("Sender Name", PORT_TYPE_STRING)
	sender_job =  add_output_port("Sender Job", PORT_TYPE_STRING)
	sender_device = add_output_port("Sender Device", PORT_TYPE_ATOM)
	received = add_output_port("Received", PORT_TYPE_SIGNAL)

	message = add_input_port("Message", PORT_TYPE_STRING)
	targets = add_input_port("Targets", PORT_TYPE_LIST(PORT_TYPE_ATOM))

	ring = add_input_port("Play Ringtone", PORT_TYPE_SIGNAL, trigger = PROC_REF(play_ringtone))
	set_ring = add_input_port("Set Ringtone", PORT_TYPE_STRING, trigger = PROC_REF(set_ringtone))

/obj/item/circuit_component/mod_program/messenger/input_received(datum/port/port)
	var/list/messenger_targets = list()
	for(var/datum/weakref/ref as anything in targets.value)
		var/obj/item/modular_computer/modpc = ref?.resolve() //entity ports are hardrefs, entity list ports are weakref. :thonking:
		if(!istype(modpc))
			continue
		var/datum/computer_file/program/messenger/messenger = locate() in modpc.stored_files
		if(messenger)
			messenger_targets |= messenger
	if(!length(messenger_targets))
		return
	var/datum/computer_file/program/messenger/messenger = associated_program
	var/filterd_message = censor_ic_filter_for_pdas(message.value)

	///We need to async send_message() because some tcomms devices might sleep. Also because of (non-existent) user tgui alerts.
	INVOKE_ASYNC(messenger, TYPE_PROC_REF(/datum/computer_file/program/messenger, send_message), src, filterd_message, messenger_targets)

/obj/item/circuit_component/mod_program/messenger/register_shell(atom/movable/shell)
	. = ..()
	RegisterSignal(associated_program.computer, COMSIG_MODULAR_PDA_MESSAGE_RECEIVED, PROC_REF(message_received))
	RegisterSignal(associated_program.computer, COMSIG_MODULAR_PDA_MESSAGE_SENT, PROC_REF(message_sent))

/obj/item/circuit_component/mod_program/messenger/unregister_shell()
	UnregisterSignal(associated_program.computer, list(COMSIG_MODULAR_PDA_MESSAGE_RECEIVED, COMSIG_MODULAR_PDA_MESSAGE_SENT))
	return ..()

/obj/item/circuit_component/mod_program/messenger/get_ui_notices()
	. = ..()
	. += create_ui_notice("Cooldown per recipient: [DisplayTimeText(MESSENGER_CIRCUIT_CD_PER_RECIPIENT)]", "orange", "stopwatch")
	. += create_ui_notice("Minimum cooldown: [DisplayTimeText(MESSENGER_CIRCUIT_MIN_COOLDOWN)]", "orange", "stopwatch")
	. += create_ui_notice("Maximum cooldown: [DisplayTimeText(MESSENGER_CIRCUIT_MAX_COOLDOWN)]", "orange", "stopwatch")

/obj/item/circuit_component/mod_program/messenger/proc/message_received(datum/source, datum/signal/subspace/messaging/tablet_message/signal, message_job, message_name)
	SIGNAL_HANDLER
	received_message.set_value(signal.data["message"])
	sender_name.set_output(message_name)
	sender_job.set_output(message_job)

	var/atom/source_device
	if(istype(signal.source, /datum/computer_file/program/messenger))
		var/datum/computer_file/program/messenger/sender_messenger = source
		source_device = sender_messenger.computer
	else if(isatom(signal.source))
		source_device = signal.source

	sender_device.set_output(source_device)
	received.set_output(COMPONENT_SIGNAL)

///Set the cooldown after the message was sent (by us)
/obj/item/circuit_component/mod_program/messenger/proc/message_sent(datum/source, atom/origin, datum/signal/subspace/messaging/tablet_message/signal)
	SIGNAL_HANDLER
	if(origin != src)
		return
	var/targets_length = length(signal.data["targets"])
	var/datum/computer_file/program/messenger/messenger = associated_program
	var/cool = clamp(targets_length * MESSENGER_CIRCUIT_CD_PER_RECIPIENT, MESSENGER_CIRCUIT_MIN_COOLDOWN, MESSENGER_CIRCUIT_MAX_COOLDOWN)
	COOLDOWN_START(messenger, last_text, cool)

/obj/item/circuit_component/mod_program/messenger/proc/set_ringtone(datum/port/port)
	var/datum/computer_file/program/messenger/messenger = associated_program
	messenger.set_ringtone(set_ring.value)

/obj/item/circuit_component/mod_program/messenger/proc/play_ringtone(datum/port/port)
	if(!COOLDOWN_FINISHED(src, ring_cd))
		return
	COOLDOWN_START(src, ring_cd, MESSENGER_CIRCUIT_RINGTONE_CD)
	var/datum/computer_file/program/messenger/messenger = associated_program
	messenger.computer.ring(messenger.ringtone)

#undef MESSENGER_CIRCUIT_MIN_COOLDOWN
#undef MESSENGER_CIRCUIT_MAX_COOLDOWN
#undef MESSENGER_CIRCUIT_CD_PER_RECIPIENT
#undef MESSENGER_CIRCUIT_RINGTONE_CD
