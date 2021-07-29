/**
 * # Radio Component
 *
 * Listens out for signals on the designated frequencies and sends signals on designated frequencies
 */
/obj/item/circuit_component/radio
	display_name = "Radio"
	display_desc = "A component that can listen and send frequencies. If set to private, the component will only receive signals from other components attached to circuitboards with the same owner id."

	/// Frequency input
	var/datum/port/input/freq
	/// Signal input
	var/datum/port/input/code

	// TODO: Move this all over to ntnet instead of radio signals
	/// The data to send over
	var/datum/port/input/data_to_send

	/// The data received
	var/datum/port/output/received_data

	/// Current frequency value
	var/current_freq = DEFAULT_SIGNALER_CODE

	var/datum/radio_frequency/radio_connection

/obj/item/circuit_component/radio/populate_options()
	var/static/component_options = list(
		COMP_RADIO_PUBLIC,
		COMP_RADIO_PRIVATE,
	)
	options = component_options

/obj/item/circuit_component/radio/Initialize()
	. = ..()
	freq = add_input_port("Frequency", PORT_TYPE_NUMBER, default = FREQ_SIGNALER)
	code = add_input_port("Code", PORT_TYPE_NUMBER, default = DEFAULT_SIGNALER_CODE)
	TRIGGER_CIRCUIT_COMPONENT(src, null)
	data_to_send = add_input_port("Data To Send", PORT_TYPE_LIST)
	trigger_input = add_input_port("Send", PORT_TYPE_SIGNAL)

	received_data = add_output_port("Received Data", PORT_TYPE_LIST)
	trigger_output = add_output_port("Received", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/radio/Destroy()
	SSradio.remove_object(src, current_freq)
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
		var/datum/signal/signal = new(list("code" = round(code.input_value) || 0, "key" = parent?.owner_id, "data" = data_to_send.input_value))
		radio_connection.post_signal(src, signal)

/obj/item/circuit_component/radio/receive_signal(datum/signal/signal)
	. = FALSE
	if(!signal)
		return
	if(signal.data["code"] != round(code.input_value || 0))
		return

	if(current_option == COMP_RADIO_PRIVATE && parent?.owner_id != signal.data["key"])
		return

	received_data.set_output(signal.data["data"])
	trigger_output.set_output(COMPONENT_SIGNAL)
