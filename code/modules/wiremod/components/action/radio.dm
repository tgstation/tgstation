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

	/// Holds a reference to the shell.
	var/atom/movable/parent_shell = null

	/// The ckey of the user who used the shell we were placed in, important for signalling logs.
	var/owner_ckey = null

	/// The radio connection we are using to receive signals.
	var/datum/radio_frequency/radio_connection

	/// How long of a cooldown we have before we can send another signal.
	var/signal_cooldown_time = 1 SECONDS

/obj/item/circuit_component/radio/Initialize(mapload)
	. = ..()
	if(signal_cooldown_time > 0)
		desc = "[desc] It has a [signal_cooldown_time * 0.1] second cooldown between sending signals."

/obj/item/circuit_component/radio/register_shell(atom/movable/shell)
	parent_shell = shell
	var/potential_fingerprints = shell.fingerprintslast
	if(!isnull(potential_fingerprints))
		owner_ckey = potential_fingerprints

/obj/item/circuit_component/radio/unregister_shell(atom/movable/shell)
	parent_shell = null

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
	if(!TIMER_COOLDOWN_CHECK(parent, COOLDOWN_SIGNALLER_SEND))
		return

	var/frequency = freq.value
	if(frequency != current_freq)
		SSradio.remove_object(src, current_freq)
		radio_connection = SSradio.add_object(src, frequency, RADIO_SIGNALER)
		current_freq = frequency

	if(COMPONENT_TRIGGERED_BY(trigger_input, port))
		var/signal_code = round(code.value) || 0
		var/turf/location = get_turf(src)
		var/time = time2text(world.realtime,"hh:mm:ss")

		var/list/loggable_strings = list("[time] <B>:</B> The [QDELETED(parent_shell) ? "null circuit shell(?)" : parent_shell] @ location ([location.x],[location.y],[location.z]) transmitted the following signal <B>:</B> [format_frequency(current_freq)]/[signal_code] via the radio circuit component.")
		if(!isnull(owner_ckey))
			loggable_strings += "<B>:</B> The person who inserted the signalling circuit component was very likely [owner_ckey]."
		if(!QDELETED(parent_shell))
			loggable_strings += "<B>:</B> The last fingerprints on the containing shell was [parent_shell.fingerprintslast]."

		var/loggable_string = loggable_strings.Join(" ")
		add_to_signaler_investigate_log(loggable_string)
		TIMER_COOLDOWN_START(parent, COOLDOWN_SIGNALLER_SEND, signal_cooldown_time)

		var/datum/signal/signal = new(list("code" = signal_code, "key" = parent?.owner_id), logging_data = loggable_string)
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
