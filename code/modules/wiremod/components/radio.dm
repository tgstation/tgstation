/**
 * # Radio Component
 *
 * Listens out for signals on the designated frequencies and
 */
/obj/item/circuit_component/radio
	display_name = "Radio"

	/// Frequency input
	var/datum/port/input/freq
	/// Signal input
	var/datum/port/input/code

	/// Current frequency value
	var/current_freq = DEFAULT_SIGNALER_CODE

	var/datum/radio_frequency/radio_connection

/obj/item/circuit_component/radio/Initialize()
	. = ..()
	freq = add_input_port("Frequency", PORT_TYPE_NUMBER, default = FREQ_SIGNALER)
	code = add_input_port("Code", PORT_TYPE_NUMBER, default = DEFAULT_SIGNALER_CODE)
	trigger_input = add_input_port("Send", PORT_TYPE_SIGNAL)
	trigger_output = add_output_port("Received", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/radio/Destroy()
	freq = null
	code = null
	trigger_input = null
	trigger_output = null
	SSradio.remove_object(src, current_freq)
	radio_connection = null
	return ..()

/obj/item/circuit_component/radio/input_received(datum/port/input/port)
	. = ..()
	freq.set_input(sanitize_frequency(freq.input_value, TRUE), FALSE)
	if(.)
		return
	var/frequency = freq.input_value

	SSradio.remove_object(src, current_freq)
	radio_connection = SSradio.add_object(src, frequency, RADIO_SIGNALER)
	current_freq = frequency

	if(COMPONENT_TRIGGERED_BY(trigger_input, port))
		var/datum/signal/signal = new(list("code" = round(code.input_value) || 0))
		radio_connection.post_signal(src, signal)

/obj/item/circuit_component/radio/receive_signal(datum/signal/signal)
	. = FALSE
	if(!signal)
		return
	if(signal.data["code"] != round(code.input_value || 0))
		return

	trigger_output.set_output(COMPONENT_SIGNAL)
