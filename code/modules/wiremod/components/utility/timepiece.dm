#define COMP_TIMEPIECE_TWENTYFOUR_HOUR "24-Hour"
#define COMP_TIMEPIECE_TWELVE_HOUR "12-Hour"
#define COMP_TIMEPIECE_SECONDS "Seconds"
#define COMP_TIMEPIECE_MINUTES "Minutes"
#define COMP_TIMEPIECE_HOURS "Hours"

/**
 * # Timepiece Component
 *
 * returns the current station time.
 */
/obj/item/circuit_component/timepiece
	display_name = "Timepiece"
	desc = "A component that outputs the current station time. The text output port is used for time formats while the numerical output port is used for units of time."
	category = "Utility"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The time format of the text output
	var/datum/port/input/option/format
	/// The unit of time for the numerical output
	var/datum/port/input/option/time_unit
	/// The output for 24/12 hour formats
	var/datum/port/output/text_output
	/// seconds, minutes, hours.
	var/datum/port/output/num_output

/obj/item/circuit_component/timepiece/populate_ports()
	text_output = add_output_port("Time Format", PORT_TYPE_STRING)
	num_output = add_output_port("Unit of Time", PORT_TYPE_NUMBER)

/obj/item/circuit_component/timepiece/populate_options()
	var/static/format_options = list(
		COMP_TIMEPIECE_TWENTYFOUR_HOUR, // Station time is expressed in 24-h in the status tab. So this is the default.
		COMP_TIMEPIECE_TWELVE_HOUR,
	)
	format = add_option_port("Time Format", format_options)
	var/static/unit_options = list(
		COMP_TIMEPIECE_HOURS,
		COMP_TIMEPIECE_MINUTES,
		COMP_TIMEPIECE_SECONDS,
	)
	time_unit = add_option_port("Unit of Time", unit_options)

/obj/item/circuit_component/timepiece/input_received(datum/port/input/port)
	var/time

	switch(format.value)
		if(COMP_TIMEPIECE_TWENTYFOUR_HOUR)
			time = station_time_timestamp()
		if(COMP_TIMEPIECE_TWELVE_HOUR)
			time = time_to_twelve_hour(station_time())

	text_output.set_output(time)

	switch(time_unit.value)
		if(COMP_TIMEPIECE_HOURS)
			time = round(station_time() / (1 HOURS))
		if(COMP_TIMEPIECE_MINUTES)
			time = round(station_time() / (1 MINUTES))
		if(COMP_TIMEPIECE_SECONDS)
			time = round(station_time() / (1 SECONDS))

	num_output.set_output(time)

#undef COMP_TIMEPIECE_TWENTYFOUR_HOUR
#undef COMP_TIMEPIECE_TWELVE_HOUR
#undef COMP_TIMEPIECE_SECONDS
#undef COMP_TIMEPIECE_MINUTES
#undef COMP_TIMEPIECE_HOURS
