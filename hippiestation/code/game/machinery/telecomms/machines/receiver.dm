//Code for the interceptor circuit
/obj/machinery/telecomms/receiver/Options_Menu()
	var/dat = "<br>Remote control: <a href='?src=[REF(src)];toggle_remote_control=1'>[GLOB.remote_control ? "<font color='green'><b>ENABLED</b></font>" : "<font color='red'><b>DISABLED</b></font>"]</a>"
	dat += "<br>Broadcasting signals: "
	for(var/i in GLOB.ic_speakers)
		var/obj/item/integrated_circuit/I = i
		var/obj/item/O = I.get_object()
		if(get_area(O)) //if it isn't in nullspace, can happen due to printer newing all possible circuits to fetch list data
			dat += "<br>[O.name] = [O.x], [O.y], [O.z], [get_area(O)]"
	dat += "<br><br>Circuit jammer signals: "
	for(var/i in GLOB.ic_jammers)
		var/obj/item/integrated_circuit/I = i
		var/obj/item/O = I.get_object()
		if(get_area(O)) //if it isn't in nullspace, can happen due to printer newing all possible circuits to fetch list data
			dat += "<br>[O.name] = [O.x], [O.y], [O.z], [get_area(O)]"
	return dat

/obj/machinery/telecomms/receiver/Options_Topic(href, href_list)
	if(href_list["toggle_remote_control"])
		GLOB.remote_control = !GLOB.remote_control

/obj/machinery/telecomms/receiver/receive_signal(datum/signal/signal)
	if(LAZYLEN(GLOB.ic_jammers) && GLOB.remote_control)
		for(var/i in GLOB.ic_jammers)
			var/obj/item/integrated_circuit/input/tcomm_interceptor/T = i
			var/obj/item/O = T.get_object()
			if(is_station_level(O.z)&& (!istype(get_area(O), /area/space)))
				if(!istype(signal.source, /obj/item/device/radio/headset/integrated))
					signal.data["reject"] = TRUE
					break
	..()

//makeshift receiver used for the circuit, so that we don't
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

// End
