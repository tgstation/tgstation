/**
 * # Speech Component
 *
 * Sends a message. Requires a shell.
 */
/obj/item/circuit_component/speech
	display_name = "Speech"
	desc = "A component that sends a message. Requires a shell."
	category = "Action"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The message to send
	var/datum/port/input/message
	/// The quiet mode flag
	var/datum/port/input/quietmode

	/// The cooldown for this component of how often it can send speech messages.
	var/speech_cooldown = 1 SECONDS

/obj/item/circuit_component/speech/get_ui_notices()
	. = ..()
	. += create_ui_notice("Speech Cooldown: [DisplayTimeText(speech_cooldown)]", "orange", "stopwatch")

/obj/item/circuit_component/speech/populate_ports()
	message = add_input_port("Message", PORT_TYPE_STRING, trigger = null)
	quietmode = add_input_port("Quiet Mode", PORT_TYPE_NUMBER, default = 0)

/obj/item/circuit_component/speech/input_received(datum/port/input/port)
	if(!parent.shell)
		return

	if(TIMER_COOLDOWN_RUNNING(parent.shell, COOLDOWN_CIRCUIT_SPEECH))
		return

	if(message.value)
		var/atom/movable/shell = parent.shell
		shell.say(message.value, forced = "circuit speech | [parent.get_creator()]", message_range = quietmode.value > 0 ? WHISPER_RANGE : MESSAGE_RANGE)
		TIMER_COOLDOWN_START(shell, COOLDOWN_CIRCUIT_SPEECH, speech_cooldown)
