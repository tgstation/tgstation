/datum/integrated_io/activate
	name = "activation pin"
	io_type = PULSE_CHANNEL

/datum/integrated_io/activate/out // All this does is just make the UI say 'out' instead of 'in'
	data = 1

/datum/integrated_io/activate/push_data(datum/iopulse/pulse)
	for(var/k in 1 to linked.len)
		var/datum/integrated_io/io = linked[k]
		io.holder.check_then_do_work(activation_pulse = pulse)

/datum/integrated_io/activate/scramble()
	push_data()

/datum/integrated_io/activate/display_data()
	return "(\[pulse\])"

/datum/integrated_io/activate/display_pin_type()
	return IC_FORMAT_PULSE

/datum/integrated_io/activate/ask_for_pin_data(mob/user) // This just pulses the pin.
	holder.check_then_do_work(ignore_power = TRUE)
	to_chat(user, "<span class='notice'>You pulse \the [holder]'s [src] pin.</span>")

/datum/iopulse
	var/list/pulsed = list()
	var/index = 0
	var/dereference_time = 0
	var/list/referencing = list()

/datum/iopulse/New(iteration)
	index = iteration
	dereference_time = world.time + INTEGRATED_CIRCUITS_PULSE_DEREFERENCE_DELAY
