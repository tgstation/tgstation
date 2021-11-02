/**
 * # Speech Relay preset
 *
 * Acts like poly. Says whatever it hears.
 */
/obj/item/integrated_circuit/loaded/speech_relay

/obj/item/integrated_circuit/loaded/speech_relay/Initialize(mapload)
	. = ..()
	var/obj/item/circuit_component/hear/hear = new()
	add_component(hear)
	hear.rel_x = 100
	hear.rel_y = 200

	var/obj/item/circuit_component/speech/speech = new()
	add_component(speech)
	speech.rel_x = 400
	speech.rel_y = 200

	speech.message.connect(hear.message_port)
