/**
 * # Speech Component
 *
 * Sends a message. Requires a shell.
 */
/obj/item/component/speech
	display_name = "Speech"

	/// The message to send
	var/datum/port/input/message
	/// The trigger to send the message
	var/datum/port/input/trigger

/obj/item/component/speech/Initialize()
	. = ..()
	message = add_input_port("Message", PORT_TYPE_STRING, FALSE)

	trigger = add_input_port("Trigger", PORT_TYPE_NUMBER)


/obj/item/component/speech/Destroy()
	message = null
	trigger = null
	return ..()

/obj/item/component/speech/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	if(!COMPONENT_TRIGGERED_BY(trigger))
		return

	var/atom/movable/shell = parent.shell
	if(!shell)
		return

	if(message.input_value)
		shell.say(message.input_value)
