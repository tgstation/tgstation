#define COMP_RADIO_PUBLIC "public"
#define COMP_RADIO_PRIVATE "private"

/**
 * # Radio Component
 *
 * Listens out for signals on the designated frequencies and sends signals on designated frequencies
 */
/obj/item/circuit_component/radio
	display_name = "Radio"
	desc = "A component that can listen and send frequencies. If set to private, the component will only receive signals from other components attached to circuitboards with the same owner id."
	category = "Action"

	/// The publicity options. Controls whether it's public or private.
	var/datum/port/input/option/public_options

	/// Frequency input
	var/datum/port/input/freq
	/// Signal input
	var/datum/port/input/code

	/// Current frequency value
	var/current_freq = DEFAULT_SIGNALER_CODE

	var/datum/radio_frequency/radio_connection

/obj/item/circuit_component/radio/populate_options()
	var/static/component_options = list(
		COMP_RADIO_PUBLIC,
		COMP_RADIO_PRIVATE,
	)
	public_options = add_option_port("Encryption Options", component_options)

/obj/item/circuit_component/radio/populate_ports()
	freq = add_input_port("Frequency", PORT_TYPE_NUMBER, default = FREQ_SIGNALER)
	code = add_input_port("Code", PORT_TYPE_NUMBER, default = DEFAULT_SIGNALER_CODE)
	trigger_component()
	// These are cleaned up on the parent
	trigger_input = add_input_port("Send", PORT_TYPE_SIGNAL)
	trigger_output = add_output_port("Received", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/radio/Destroy()
	SSradio.remove_object(src, current_freq)
	return ..()

/obj/item/circuit_component/radio/pre_input_received(datum/port/input/port)
	freq.set_value(sanitize_frequency(freq.value, TRUE))

/obj/item/circuit_component/radio/input_received(datum/port/input/port)
	INVOKE_ASYNC(src, PROC_REF(handle_radio_input), port)

/obj/item/circuit_component/radio/proc/handle_radio_input(datum/port/input/port)
	var/frequency = freq.value

	if(frequency != current_freq)
		SSradio.remove_object(src, current_freq)
		radio_connection = SSradio.add_object(src, frequency, RADIO_SIGNALER)
		current_freq = frequency

	if(COMPONENT_TRIGGERED_BY(trigger_input, port))
		var/datum/signal/signal = new(list("code" = round(code.value) || 0, "key" = parent?.owner_id))
		radio_connection.post_signal(src, signal)

/obj/item/circuit_component/radio/receive_signal(datum/signal/signal)
	. = FALSE
	if(!signal)
		return
	if(signal.data["code"] != round(code.value || 0))
		return

	if(public_options.value == COMP_RADIO_PRIVATE && parent?.owner_id != signal.data["key"])
		return

	trigger_output.set_output(COMPONENT_SIGNAL)

#undef COMP_RADIO_PUBLIC
#undef COMP_RADIO_PRIVATE
