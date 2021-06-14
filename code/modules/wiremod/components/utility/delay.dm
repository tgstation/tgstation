/**
 * # Delay Component
 *
 * Delays a signal by a specified duration.
 */
/obj/item/circuit_component/delay
	display_name = "Delay"

	/// Amount to delay by
	var/datum/port/input/delay_amount
	/// Input signal to fire the delay
	var/datum/port/input/trigger

	/// The output of the signal
	var/datum/port/output/output

/obj/item/circuit_component/delay/Initialize()
	. = ..()
	delay_amount = add_input_port("Delay", PORT_TYPE_NUMBER, FALSE)
	trigger = add_input_port("Trigger", PORT_TYPE_SIGNAL)

	output = add_output_port("Result", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/delay/Destroy()
	output = null
	trigger = null
	delay_amount = null
	return ..()

/obj/item/circuit_component/delay/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	if(!COMPONENT_TRIGGERED_BY(trigger, port))
		return

	var/delay = delay_amount.input_value
	if(delay > COMP_DELAY_MIN_VALUE)
		// Convert delay into deciseconds
		addtimer(CALLBACK(output, /datum/port/output.proc/set_output, trigger.input_value), delay*10, timer_subsystem =SScircuit_component)
	else
		output.set_output(trigger.input_value)
