/**
 * # Clock Component
 *
 * Fires every 0.9 seconds
 */
/obj/item/component/clock
	display_name = "Clock"

	/// The signal from this clock component
	var/datum/port/output/signal

/obj/item/component/clock/Initialize()
	. = ..()
	signal = add_output_port("Signal", PORT_TYPE_NUMBER)
	RegisterSignal(signal, COMSIG_PORT_OUTPUT_CONNECT, .proc/start_process)
	RegisterSignal(signal, COMSIG_PORT_DISCONNECT, .proc/stop_process)

/obj/item/component/clock/Destroy()
	signal = null
	stop_process()
	return ..()

/obj/item/component/clock/process(delta_time)
	signal.set_output(COMPONENT_SIGNAL)

/**
 * Adds the component to the SSclock_component process list
 *
 * Starts ticking to send signals between periods of time
 */
/obj/item/component/clock/proc/start_process()
	SIGNAL_HANDLER
	START_PROCESSING(SSclock_component, src)

/**
 * Removes the component to the SSclock_component process list
 *
 * Signals stop getting sent.
 */
/obj/item/component/clock/proc/stop_process()
	SIGNAL_HANDLER
	STOP_PROCESSING(SSclock_component, src)
