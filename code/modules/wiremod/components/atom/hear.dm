/**
 * # Hear Component
 *
 * Listens for messages. Requires a shell.
 */
/obj/item/circuit_component/hear
	display_name = "Voice Activator"

	flags_1 = HEAR_1

	/// The message heard
	var/datum/port/output/message_port
	/// The language heard
	var/datum/port/output/language_port
	/// The speaker
	var/datum/port/output/speaker_port
	/// The trigger sent when this event occurs
	var/datum/port/output/trigger_port

/obj/item/circuit_component/hear/Initialize()
	. = ..()
	message_port = add_output_port("Message", PORT_TYPE_STRING)
	language_port = add_output_port("Language", PORT_TYPE_STRING)
	speaker_port = add_output_port("Speaker", PORT_TYPE_ATOM)
	trigger_port = add_output_port("Triggered", PORT_TYPE_SIGNAL)


/obj/item/circuit_component/hear/Destroy()
	message_port = null
	language_port = null
	speaker_port = null
	trigger_port = null
	return ..()

/obj/item/circuit_component/hear/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods)
	if(speaker == parent?.shell)
		return

	message_port.set_output(raw_message)
	if(message_language)
		language_port.set_output(initial(message_language.name))
	speaker_port.set_output(speaker)
	trigger_port.set_output(COMPONENT_SIGNAL)
