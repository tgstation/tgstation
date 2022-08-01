/**
 * # Clock Component
 *
 * Fires every tick of the circuit timer SS
 */
/obj/item/circuit_component/clock
	display_name = "Clock"
	desc = "A component that repeatedly fires."
	category = "Utility"

	/// Whether the clock is on or not
	var/datum/port/input/on

	/// the interval at wich the clock tick is a multiple of COMP_CLOCK_DELAY
	var/datum/port/input/interval

	/// The signal from this clock component
	var/datum/port/output/signal

	///used to compute how many ticks since last signal
	var/delta_last_signal = COMP_CLOCK_DELAY/(1 SECONDS)

/obj/item/circuit_component/clock/get_ui_notices()
	. = ..()
	. += create_ui_notice("Clock Interval: interval * [DisplayTimeText(COMP_CLOCK_DELAY)]", "orange", "clock")

/obj/item/circuit_component/clock/populate_ports()
	on = add_input_port("On", PORT_TYPE_NUMBER)

	interval = add_input_port("Interval", PORT_TYPE_NUMBER)

	signal = add_output_port("Signal", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/clock/input_received(datum/port/input/port)

	if(on.value)
		start_process()
	else
		stop_process()

	///minimum clock interval cant be smaller than COMP_CLOCK_DELAY
	if(interval.value < 1)
		interval.value = 1

/obj/item/circuit_component/clock/Destroy()
	stop_process()
	return ..()

/**
 * Send signal only if sufficient ticks have elapsed
 *
 * since last signal
 */
/obj/item/circuit_component/clock/process(delta_time)
	if(delta_last_signal >= interval.value*COMP_CLOCK_DELAY/(1 SECONDS))
		signal.set_output(COMPONENT_SIGNAL)
		delta_last_signal = COMP_CLOCK_DELAY/(1 SECONDS)
	else
		delta_last_signal = delta_last_signal + delta_time

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
