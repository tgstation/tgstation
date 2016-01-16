#define LOGIC_HIGH 5

//Indicators only have one input and no outputs
/obj/machinery/logic/indicator
	//Input is searched from the 'dir' direction
	var/obj/structure/cable/input

/obj/machinery/logic/indicator/process()
	if(input)
		return 1


	if(!input)
		var/turf/T = get_step(src, dir)
		if(T)
			var/inv_dir = turn(dir, 180)
			for(var/obj/structure/cable/C in T)
				if(C.d1 == inv_dir || C.d2 == inv_dir)
					input = C
					return 1

	return 0	//If it gets to here, it means no suitable wire to link to was found.

/obj/machinery/logic/indicator/bulb
	icon = 'icons/obj/lighting.dmi'
	icon_state = "bulb0"

/obj/machinery/logic/indicator/bulb/process()
	if(!..())	//Parent proc checks if input1 exists.
		return

	var/datum/powernet/pn_input = input.powernet
	if(!pn_input)
		return

	if(pn_input.avail >= LOGIC_HIGH)
		icon_state = "bulb1"
	else
		icon_state = "bulb0"




//Sensors only have one output and no inputs
/obj/machinery/logic/sensor
	//Output is searched from the 'dir' direction
	var/obj/structure/cable/output

/obj/machinery/logic/sensor/process()
	if(output)
		return 1

	if(!output)
		var/turf/T = get_step(src, dir)
		if(T)
			var/inv_dir = turn(dir, 180)
			for(var/obj/structure/cable/C in T)
				if(C.d1 == inv_dir || C.d2 == inv_dir)
					output = C
					return 1

	return 0	//If it gets to here, it means no suitable wire to link to was found.

//Constant high generator. This will continue to send a signal of LOGIC_HIGH as long as it exists.
/obj/machinery/logic/sensor/constant_high
	icon = 'icons/obj/atmospherics/outlet_injector.dmi'
	icon_state = "off"

/obj/machinery/logic/sensor/constant_high/process()
	if(!..())	//Parent proc checks if input1 exists.
		return

	var/datum/powernet/pn_output = output.powernet
	if(!pn_output)
		return

	pn_output.newavail = max(pn_output.avail, LOGIC_HIGH)




//ONE INPUT logic elements have one input and one output
/obj/machinery/logic/oneinput
	var/dir_input = 2
	var/dir_output = 1
	var/obj/structure/cable/input
	var/obj/structure/cable/output
	icon = 'icons/obj/pipes/heat.dmi'
	icon_state = "intact"

/obj/machinery/logic/oneinput/process()
	if(input && output)
		return 1

	if(!dir_input || !dir_output)
		return 0

	if(!input)
		var/turf/T = get_step(src, dir_input)
		if(T)
			var/inv_dir = turn(dir_input, 180)
			for(var/obj/structure/cable/C in T)
				if(C.d1 == inv_dir || C.d2 == inv_dir)
					input = C

	if(!output)
		var/turf/T = get_step(src, dir_output)
		if(T)
			var/inv_dir = turn(dir_output, 180)
			for(var/obj/structure/cable/C in T)
				if(C.d1 == inv_dir || C.d2 == inv_dir)
					output = C

	return 0	//On the process() call, where everything is still being searched for, it returns 0. It will return 1 on the next process() call.

//NOT GATE
/obj/machinery/logic/oneinput/not/process()
	if(!..())	//Parent proc checks if input1, input2 and output exist.
		return

	var/datum/powernet/pn_input = input.powernet

	if(!pn_input)
		return

	var/datum/powernet/pn_output = output.powernet
	if(!pn_output)
		return

	if( !(pn_input.avail >= LOGIC_HIGH))
		pn_output.newavail = max(pn_output.avail, LOGIC_HIGH)	//Set the output avilable power to 5 or whatever it was before.
	else
		pn_output.newload += LOGIC_HIGH		//Otherwise increase the load to 5









//TWO INPUT logic elements have two inputs and one output
/obj/machinery/logic/twoinput
	var/dir_input1 = 2
	var/dir_input2 = 8
	var/dir_output = 1
	var/obj/structure/cable/input1
	var/obj/structure/cable/input2
	var/obj/structure/cable/output
	icon = 'icons/obj/atmospherics/mixer.dmi'
	icon_state = "intact_off"

/obj/machinery/logic/twoinput/process()
	if(input1 && input2 && output)
		return 1

	if(!dir_input1 || !dir_input2 || !dir_output)
		return 0

	if(!input1)
		var/turf/T = get_step(src, dir_input1)
		if(T)
			var/inv_dir = turn(dir_input1, 180)
			for(var/obj/structure/cable/C in T)
				if(C.d1 == inv_dir || C.d2 == inv_dir)
					input1 = C

	if(!input2)
		var/turf/T = get_step(src, dir_input2)
		if(T)
			var/inv_dir = turn(dir_input2, 180)
			for(var/obj/structure/cable/C in T)
				if(C.d1 == inv_dir || C.d2 == inv_dir)
					input2 = C

	if(!output)
		var/turf/T = get_step(src, dir_output)
		if(T)
			var/inv_dir = turn(dir_output, 180)
			for(var/obj/structure/cable/C in T)
				if(C.d1 == inv_dir || C.d2 == inv_dir)
					output = C

	return 0	//On the process() call, where everything is still being searched for, it returns 0. It will return 1 on the next process() call.

//AND GATE
/obj/machinery/logic/twoinput/and/process()
	if(!..())	//Parent proc checks if input1, input2 and output exist.
		return

	var/datum/powernet/pn_input1 = input1.powernet
	var/datum/powernet/pn_input2 = input2.powernet

	if(!pn_input1 || !pn_input2)
		return

	var/datum/powernet/pn_output = output.powernet
	if(!pn_output)
		return

	if( (pn_input1.avail >= LOGIC_HIGH) && (pn_input2.avail >= LOGIC_HIGH) )
		pn_output.newavail = max(pn_output.avail, LOGIC_HIGH)	//Set the output avilable power to 5 or whatever it was before.
	else
		pn_output.newload += LOGIC_HIGH		//Otherwise increase the load to 5

//OR GATE
/obj/machinery/logic/twoinput/or/process()
	if(!..())	//Parent proc checks if input1, input2 and output exist.
		return

	var/datum/powernet/pn_input1 = input1.powernet
	var/datum/powernet/pn_input2 = input2.powernet

	if(!pn_input1 || !pn_input2)
		return

	var/datum/powernet/pn_output = output.powernet
	if(!pn_output)
		return

	if( (pn_input1.avail >= LOGIC_HIGH) || (pn_input2.avail >= LOGIC_HIGH) )
		pn_output.newavail = max(pn_output.avail, LOGIC_HIGH)	//Set the output avilable power to 5 or whatever it was before.
	else
		pn_output.newload += LOGIC_HIGH		//Otherwise increase the load to 5

//XOR GATE
/obj/machinery/logic/twoinput/xor/process()
	if(!..())	//Parent proc checks if input1, input2 and output exist.
		return

	var/datum/powernet/pn_input1 = input1.powernet
	var/datum/powernet/pn_input2 = input2.powernet

	if(!pn_input1 || !pn_input2)
		return

	var/datum/powernet/pn_output = output.powernet
	if(!pn_output)
		return

	if( (pn_input1.avail >= LOGIC_HIGH) != (pn_input2.avail >= LOGIC_HIGH) )
		pn_output.newavail = max(pn_output.avail, LOGIC_HIGH)	//Set the output avilable power to 5 or whatever it was before.
	else
		pn_output.newload += LOGIC_HIGH		//Otherwise increase the load to 5

//XNOR GATE (EQUIVALENCE)
/obj/machinery/logic/twoinput/xnor/process()
	if(!..())	//Parent proc checks if input1, input2 and output exist.
		return

	var/datum/powernet/pn_input1 = input1.powernet
	var/datum/powernet/pn_input2 = input2.powernet

	if(!pn_input1 || !pn_input2)
		return

	var/datum/powernet/pn_output = output.powernet
	if(!pn_output)
		return

	if( (pn_input1.avail >= LOGIC_HIGH) == (pn_input2.avail >= LOGIC_HIGH) )
		pn_output.newavail = max(pn_output.avail, LOGIC_HIGH)	//Set the output avilable power to 5 or whatever it was before.
	else
		pn_output.newload += LOGIC_HIGH		//Otherwise increase the load to 5

#define RELAY_POWER_TRANSFER 2000	//How much power a relay transfers through.

//RELAY - input1 governs the flow from input2 to output
/obj/machinery/logic/twoinput/relay/process()
	if(!..())	//Parent proc checks if input1, input2 and output exist.
		return

	var/datum/powernet/pn_input1 = input1.powernet

	if(!pn_input1)
		return

	if( pn_input1.avail >= LOGIC_HIGH )
		var/datum/powernet/pn_input2 = input2.powernet
		var/datum/powernet/pn_output = output.powernet

		if(!pn_output)
			return

		if(pn_input2.avail >= RELAY_POWER_TRANSFER)
			pn_input2.newload += RELAY_POWER_TRANSFER
			pn_output.newavail += RELAY_POWER_TRANSFER


#undef RELAY_POWER_TRANSFER
#undef LOGIC_HIGH