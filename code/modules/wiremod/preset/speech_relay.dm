/**
 * # Speech Relay preset
 *
 * Acts like poly. Says whatever it hears.
 */
/obj/item/integrated_circuit/loaded/speech_relay

/obj/item/integrated_circuit/loaded/speech_relay/Initialize()
	. = ..()
	var/obj/item/circuit_component/hear/hear = new()
	add_component(hear)
	hear.rel_x = 100
	hear.rel_y = 200

	var/obj/item/circuit_component/speech/speech = new()
	add_component(speech)
	speech.rel_x = 400
	speech.rel_y = 200

	speech.message.register_output_port(hear.message_port)
	speech.trigger.register_output_port(hear.trigger_port)

