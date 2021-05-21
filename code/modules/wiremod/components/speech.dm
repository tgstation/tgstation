/**
 * # Speech Component
 *
 * Sends a message. Requires a shell.
 */
/obj/item/circuit_component/speech
	display_name = "Speech"

	/// The message to send
	var/datum/port/input/message
	/// The trigger to send the message
	var/datum/port/input/trigger

	/// The next time that this component can send a message
	var/next_speech = 0
	/// The cooldown for this component of how often it can send speech messages.
	var/speech_cooldown = 2 SECONDS

/obj/item/circuit_component/speech/Initialize()
	. = ..()
	message = add_input_port("Message", PORT_TYPE_STRING, FALSE)

	trigger = add_input_port("Trigger", PORT_TYPE_NUMBER)


/obj/item/circuit_component/speech/Destroy()
	message = null
	trigger = null
	return ..()

/obj/item/circuit_component/speech/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	if(!COMPONENT_TRIGGERED_BY(trigger))
		return

	if(next_speech > world.time)
		return

	if(message.input_value)
		var/atom/movable/shell = parent.shell
		// Prevents appear as the individual component if there is a shell.
		if(shell)
			shell.say(message.input_value)
		else
			say(message.input_value)
		next_speech = world.time + speech_cooldown
