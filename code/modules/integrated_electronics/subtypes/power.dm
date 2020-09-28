/obj/item/integrated_circuit/power/
	category_text = "Power - Active"

/obj/item/integrated_circuit/power/transmitter
	name = "power transmission circuit"
	desc = "This can wirelessly transmit electricity from an assembly's battery towards a nearby machine."
	icon_state = "power_transmitter"
	extended_desc = "This circuit transmits 5 kJ of electricity every time the activator pin is pulsed. The input pin must be \
	a reference to a machine to send electricity to. This can be a battery, or anything containing a battery. The machine can exist \
	inside the assembly, or adjacent to it. The power is sourced from the assembly's power cell. If the target is outside of the assembly, \
	some power is lost due to ineffiency."
	w_class = WEIGHT_CLASS_SMALL
	complexity = 16
	inputs = list("target" = IC_PINTYPE_REF)
	outputs = list(
		"target cell charge" = IC_PINTYPE_NUMBER,
		"target cell max charge" = IC_PINTYPE_NUMBER,
		"target cell percentage" = IC_PINTYPE_NUMBER
		)
	activators = list("transmit" = IC_PINTYPE_PULSE_IN, "on transmit" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 500 // Inefficency has to come from somewhere.
	var/amount_to_move = 5000

/obj/item/integrated_circuit/power/transmitter/large
	name = "large power transmission circuit"
	desc = "This can wirelessly transmit a lot of electricity from an assembly's battery towards a nearby machine. <b>Warning:</b> Do not operate in flammable environments."
	extended_desc = "This circuit transmits 20 kJ of electricity every time the activator pin is pulsed. The input pin must be \
	a reference to a machine to send electricity to. This can be a battery, or anything containing a battery. The machine can exist \
	inside the assembly, or adjacent to it. The power is sourced from the assembly's power cell. If the target is outside of the assembly, \
	some power is lost due to ineffiency. Warning! Don't stack more than 1 power transmitter, as it becomes less efficient for every other \
	transmission circuit in its own assembly and other nearby ones."
	w_class = WEIGHT_CLASS_BULKY
	complexity = 32
	power_draw_per_use = 2000
	amount_to_move = 20000

/obj/item/integrated_circuit/power/transmitter/do_work()

	var/atom/movable/AM = get_pin_data_as_type(IC_INPUT, 1, /atom/movable)
	if(!AM)
		return FALSE
	if(istype(AM, /obj/item/gun/energy))
		return FALSE
	if(!assembly)
		return FALSE // Pointless to do everything else if there's no battery to draw from.
	var/obj/item/stock_parts/cell/cell = AM.get_cell()
	if(cell)
		var/transfer_amount = amount_to_move
		var/turf/A = get_turf(src)
		var/turf/B = get_turf(AM)
		if(A.Adjacent(B))
			if(AM.loc != assembly)
				transfer_amount *= 0.8 // Losses due to distance.
			var/list/U=A.GetAllContents(/obj/item/integrated_circuit/power/transmitter)
			transfer_amount *= 1 / U.len
			set_pin_data(IC_OUTPUT, 1, cell.charge)
			set_pin_data(IC_OUTPUT, 2, cell.maxcharge)
			set_pin_data(IC_OUTPUT, 3, cell.percent())
			activate_pin(2)
			push_data()
			if(cell.charge == cell.maxcharge)
				return FALSE
			if(transfer_amount && assembly.draw_power(amount_to_move)) // CELLRATE is already handled in draw_power()
				cell.give(transfer_amount * GLOB.CELLRATE)
				if(istype(AM, /obj/item))
					var/obj/item/I = AM
					I.update_icon()
				return TRUE
	else
		set_pin_data(IC_OUTPUT, 1, null)
		set_pin_data(IC_OUTPUT, 2, null)
		set_pin_data(IC_OUTPUT, 3, null)
		activate_pin(2)
		push_data()
		return FALSE

/obj/item/integrated_circuit/power/transmitter/large/do_work()
	if(..()) // If the above code succeeds, do this below.
		var/atom/movable/acting_object = get_object()
		if(prob(20))
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(12, 1, src)
			s.start()
			acting_object.visible_message("<span class='warning'>\The [acting_object] makes some sparks!</span>")
	return TRUE


// - wire connector - //
/obj/item/integrated_circuit/power/transmitter/wire_connector
	name = "wire connector"
	desc = "Connects to a wire and allows to read the power, charge it or charge itself from the wire's power."
	extended_desc = "This circuit will automatically attempt to locate and connect to wires on the floor beneath it when pulsed. \
						You <b>must</b> set a target before connecting. It can also transfer energy up to 2kJ from the assembly  \
						to a wire and backwards if negative values are set for energy transfer."
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	inputs = list(
			"charge" = IC_PINTYPE_NUMBER
			)
	activators = list(
			"toggle connection" = IC_PINTYPE_PULSE_IN,
			"transfer power" = IC_PINTYPE_PULSE_IN,
			"on connected" = IC_PINTYPE_PULSE_OUT,
			"on connection failed" = IC_PINTYPE_PULSE_OUT,
			"on disconnected" = IC_PINTYPE_PULSE_OUT
			)
	outputs = list(
			"connected cable" = IC_PINTYPE_REF,
			"powernet power" = IC_PINTYPE_NUMBER,
			"powernet load" = IC_PINTYPE_NUMBER
			)
	complexity = 35
	power_draw_per_use = 100
	amount_to_move = 0

	var/obj/structure/cable/connected_cable

/obj/item/integrated_circuit/power/transmitter/wire_connector/Destroy()
	connected_cable = null
	return ..()

/obj/item/integrated_circuit/power/transmitter/wire_connector/Initialize()
	START_PROCESSING(SSobj, src)
	. = ..()

//Does wire things
/obj/item/integrated_circuit/power/transmitter/wire_connector/process()
	..()
	update_cable()
	push_data()

//If the assembly containing this is moved from the tile the wire is in, the connection breaks
/obj/item/integrated_circuit/power/transmitter/wire_connector/ext_moved()
	if(connected_cable)
		if(get_dist(get_object(), connected_cable) > 0)
			// The connected cable is removed
			connected_cable = null
			set_pin_data(IC_OUTPUT, 1, null)
			push_data()
			activate_pin(5)


/obj/item/integrated_circuit/power/transmitter/wire_connector/on_data_written()
	var/charge_num = get_pin_data(IC_INPUT, 1)
	//In case someone sets that pin to null
	if(!charge_num)
		amount_to_move = 0
		return

	amount_to_move = CLAMP(charge_num,-2000, 2000)

/obj/item/integrated_circuit/power/transmitter/wire_connector/do_work(var/n)
	if(n == 1)
		// If there is a connection, disconnect
		if(connected_cable)
			connected_cable = null
			set_pin_data(IC_OUTPUT, 1, null)
			push_data()
			activate_pin(5)
			return
	
		var/obj/structure/cable/foundcable = locate() in get_turf(src)
		// If no connector can't connect
		if(!foundcable || foundcable.invisibility != 0)
			set_pin_data(IC_OUTPUT, 1, null)
			push_data()
			activate_pin(4)
			return
		connected_cable = foundcable
		update_cable()
		push_data()
		activate_pin(3)
		return


	if(!connected_cable || !assembly)
		return

	if(!assembly.battery)
		return

	//No charge transfer, no need to syphon tickrates with scripts
	if(!amount_to_move || amount_to_move == 0)
		return

	//Second clamp: set the number between what the battery and powernet allows
	var/obj/item/stock_parts/cell/battery = assembly.battery
	amount_to_move = CLAMP(amount_to_move, -connected_cable.powernet.avail, battery.charge)

	if(amount_to_move > 0)
		connected_cable.powernet.newavail += battery.use(amount_to_move)
		return
	connected_cable.powernet.avail -= battery.give(-amount_to_move)

/obj/item/integrated_circuit/power/transmitter/wire_connector/proc/update_cable()
	if(get_dist(get_object(), connected_cable) > 0)
		connected_cable = null

	if(!connected_cable || connected_cable.invisibility != 0)
		set_pin_data(IC_OUTPUT, 1, null)
		set_pin_data(IC_OUTPUT, 2, null)
		set_pin_data(IC_OUTPUT, 3, null)
		return

	var/datum/powernet/analyzed_net = connected_cable.powernet
	set_pin_data(IC_OUTPUT, 1, WEAKREF(connected_cable))
	set_pin_data(IC_OUTPUT, 2, analyzed_net.viewavail)
	set_pin_data(IC_OUTPUT, 3, analyzed_net.viewload)
