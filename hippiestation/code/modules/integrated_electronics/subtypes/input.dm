//Separated incerceptor and sender
//security=computer with CE access to allow/disallow it

//Interceptor (probs better put in input than manip)
//Intercepts a telecomms signal, aka a radio message (;halp getting griff)
//Inputs:
//Pass (Boolean): Decides if the signal will be silently intercepted
//					(true) or also blocked from being sent on the radio (false)

/obj/item/integrated_circuit/input/tcomm_interceptor
	name = "telecommunication interceptor"
	desc = "This circuit allows for telecomms signals \
	to be fetched prior to being broadcasted."
	extended_desc = "Similar \
	to the old NTSL system of realtime signal modification, \
	the circuit connects to telecomms and fetches data \
	for each signal, which can be sent normally or blocked, \
	for cases such as other circuits modifying certain data."
	complexity = 30
	w_class = WEIGHT_CLASS_SMALL
	inputs = list(
		"on" = IC_PINTYPE_BOOLEAN,
		"no pass" = IC_PINTYPE_BOOLEAN
		)
	outputs = list(
		"source" = IC_PINTYPE_STRING,
		"job" = IC_PINTYPE_STRING,
		"content" = IC_PINTYPE_STRING,
		"spans" = IC_PINTYPE_LIST
		)
	activators = list(
		"on intercept" = IC_PINTYPE_PULSE_OUT
		)
	power_draw_idle = 200
	spawn_flags = IC_SPAWN_RESEARCH
	var/obj/machinery/telecomms/receiver/circuit/receiver

/obj/item/integrated_circuit/input/tcomm_interceptor/Initialize()
	..()
	receiver = new(src)
	receiver.holder = src

/obj/item/integrated_circuit/input/tcomm_interceptor/Destroy()
	qdel(receiver)
	GLOB.ic_jammers -= src
	set_pin_data(IC_INPUT, 2, 0)
	..()

/obj/item/integrated_circuit/input/tcomm_interceptor/receive_signal(datum/signal/signal)
	if(signal.transmission_method == TRANSMISSION_SUBSPACE)
		set_pin_data(IC_OUTPUT, 1, signal.data["name"])
		set_pin_data(IC_OUTPUT, 2, signal.data["job"])
		set_pin_data(IC_OUTPUT, 3, signal.data["message"])
		set_pin_data(IC_OUTPUT, 4, signal.data["spans"])
		push_data()
		activate_pin(1)

/obj/item/integrated_circuit/input/tcomm_interceptor/on_data_written()
	if(get_pin_data(IC_INPUT, 2))
		GLOB.ic_jammers |= src
	else
		GLOB.ic_jammers -= src

/obj/item/integrated_circuit/input/tcomm_interceptor/power_fail()
	GLOB.ic_jammers -= src
	set_pin_data(IC_INPUT, 2, 0)

/obj/item/integrated_circuit/input/tcomm_interceptor/disconnect_all()
	GLOB.ic_jammers -= src
	set_pin_data(IC_INPUT, 2, 0)
	..()

//makeshift receiver used for the circuit up here, so that we don't
//have to edit radio.dm and other shit
/obj/machinery/telecomms/receiver/circuit
	idle_power_usage = 0
	var/obj/item/integrated_circuit/input/tcomm_interceptor/holder

/obj/machinery/telecomms/receiver/circuit/receive_signal(datum/signal/signal)
	if(!holder.get_pin_data(IC_INPUT, 1))
		return
	if(!signal)
		return
	holder.receive_signal(signal)

/obj/machinery/telecomms/receiver/receive_signal(datum/signal/signal)
	if(GLOB.ic_jammers.len && GLOB.remote_control)
		signal.data["reject"] = TRUE
	..()