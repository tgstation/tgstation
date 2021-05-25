/**
 * # Clock Component
 *
 * Fires every tick of the circuit timer SS
 */
/obj/item/circuit_component/clock
	display_name = "Clock"

	/// Whether the clock is on or not
	var/datum/port/input/on

	/// The signal from this clock component
	var/datum/port/output/signal

/obj/item/circuit_component/clock/Initialize()
	. = ..()
	on = add_input_port("On", PORT_TYPE_NUMBER)

	signal = add_output_port("Signal", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/clock/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	if(on.input_value)
		start_process()
	else
		stop_process()

/obj/item/circuit_component/clock/Destroy()
	on = null
	signal = null
	stop_process()
	return ..()

/obj/item/circuit_component/clock/process(delta_time)
	signal.set_output(COMPONENT_SIGNAL)

/**
 * Adds the component to the SSclock_component process list
 *
 * Starts ticking to send signals between periods of time
 */
/obj/item/circuit_component/clock/proc/start_process()
	START_PROCESSING(SSclock_component, src)

/**
 * Removes the component to the SSclock_component process list
 *
 * Signals stop getting sent.
 */
/obj/item/circuit_component/clock/proc/stop_process()
	STOP_PROCESSING(SSclock_component, src)
