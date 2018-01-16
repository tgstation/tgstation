//Interceptor
//Intercepts a telecomms signal, aka a radio message (;halp getting griff)
//Inputs:
//On (Boolean): If on, the circuit intercepts radio signals. Otherwise it does not. This doesn't affect no pass!
//No pass (Boolean): Decides if the signal will be silently intercepted
//					(false) or also blocked from being sent on the radio (true)
//Outputs:
//Source: name of the mob
//Job: job of the mob
//content: the actual message
//spans: a list of spans, there's not much info about this but stuff like robots will have "robot" span
/obj/item/integrated_circuit/input/tcomm_interceptor
	name = "telecommunication interceptor"
	desc = "This circuit allows for telecomms signals \
	to be fetched prior to being broadcasted."
	extended_desc = "Similar \
	to the old NTSL system of realtime signal modification, \
	the circuit connects to telecomms and fetches data \
	for each signal, which can be sent normally or blocked, \
	for cases such as other circuits modifying certain data. \
	Beware, this cannot stop signals from unreachable areas, such \
	as space or zlevels other than station's one."
	complexity = 30
	cooldown_per_use = 0.1
	w_class = WEIGHT_CLASS_SMALL
	inputs = list(
		"intercept" = IC_PINTYPE_BOOLEAN,
		"no pass" = IC_PINTYPE_BOOLEAN
		)
	outputs = list(
		"source" = IC_PINTYPE_STRING,
		"job" = IC_PINTYPE_STRING,
		"content" = IC_PINTYPE_STRING,
		"spans" = IC_PINTYPE_LIST,
		"frequency" = IC_PINTYPE_NUMBER
		)
	activators = list(
		"on intercept" = IC_PINTYPE_PULSE_OUT
		)
	power_draw_idle = 0
	spawn_flags = IC_SPAWN_RESEARCH
	var/obj/machinery/telecomms/receiver/circuit/receiver
	var/list/freq_blacklist = list(FREQ_CENTCOM,FREQ_SYNDICATE,FREQ_CTF_RED,FREQ_CTF_BLUE)

/obj/item/integrated_circuit/input/tcomm_interceptor/Initialize()
	. = ..()
	receiver = new(src)
	receiver.holder = src

/obj/item/integrated_circuit/input/tcomm_interceptor/Destroy()
	qdel(receiver)
	GLOB.ic_jammers -= src
	..()

/obj/item/integrated_circuit/input/tcomm_interceptor/receive_signal(datum/signal/signal)
	if((signal.transmission_method == TRANSMISSION_SUBSPACE) && get_pin_data(IC_INPUT, 1))
		if(signal.frequency in freq_blacklist)
			return
		set_pin_data(IC_OUTPUT, 1, signal.data["name"])
		set_pin_data(IC_OUTPUT, 2, signal.data["job"])
		set_pin_data(IC_OUTPUT, 3, signal.data["message"])
		set_pin_data(IC_OUTPUT, 4, signal.data["spans"])
		set_pin_data(IC_OUTPUT, 5, signal.frequency)
		push_data()
		activate_pin(1)

/obj/item/integrated_circuit/input/tcomm_interceptor/on_data_written()
	if(get_pin_data(IC_INPUT, 2))
		GLOB.ic_jammers |= src
		if(get_pin_data(IC_INPUT, 1))
			power_draw_idle = 200
		else
			power_draw_idle = 100
	else
		GLOB.ic_jammers -= src
		if(get_pin_data(IC_INPUT, 1))
			power_draw_idle = 100
		else
			power_draw_idle = 0

/obj/item/integrated_circuit/input/tcomm_interceptor/power_fail()
	set_pin_data(IC_INPUT, 1, 0)
	set_pin_data(IC_INPUT, 2, 0)

/obj/item/integrated_circuit/input/tcomm_interceptor/disconnect_all()
	set_pin_data(IC_INPUT, 1, 0)
	set_pin_data(IC_INPUT, 2, 0)
	..()
