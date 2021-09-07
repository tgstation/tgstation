/**
 * # Hear Component
 *
 * Listens for messages. Requires a shell.
 */
/obj/item/circuit_component/hear
	display_name = "Voice Activator"
	desc = "A component that listens for messages. Requires a shell."

	/// The message heard
	var/datum/port/output/message_port
	/// The language heard
	var/datum/port/output/language_port
	/// The speaker
	var/datum/port/output/speaker_port
	/// The trigger sent when this event occurs
	var/datum/port/output/trigger_port

/obj/item/circuit_component/hear/populate_ports()
	message_port = add_output_port("Message", PORT_TYPE_STRING)
	language_port = add_output_port("Language", PORT_TYPE_STRING)
	speaker_port = add_output_port("Speaker", PORT_TYPE_ATOM)
	trigger_port = add_output_port("Triggered", PORT_TYPE_SIGNAL)
	become_hearing_sensitive(ROUNDSTART_TRAIT)

/obj/item/circuit_component/hear/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods)
	if(speaker == parent?.shell)
		return

	message_port.set_output(raw_message)
	if(message_language)
		language_port.set_output(initial(message_language.name))
	speaker_port.set_output(speaker)
	trigger_port.set_output(COMPONENT_SIGNAL)
