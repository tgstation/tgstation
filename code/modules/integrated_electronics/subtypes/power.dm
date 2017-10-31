/obj/item/integrated_circuit/power/
	category_text = "Power - Active"

/obj/item/integrated_circuit/power/transmitter
	name = "power transmission circuit"
	desc = "This can wirelessly transmit electricity from an assembly's battery towards a nearby machine."
	icon_state = "power_transmitter"
	extended_desc = "This circuit transmits 5 kJ of electricity every time the activator pin is pulsed. The input pin must be \
	a reference to a machine to send electricity to.  This can be a battery, or anything containing a battery.  The machine can exist \
	inside the assembly, or adjacent to it.  The power is sourced from the assembly's power cell.  If the target is outside of the assembly, \
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
	origin_tech = list(TECH_ENGINEERING = 4, TECH_DATA = 4, TECH_POWER = 4, TECH_MAGNET = 3)
	power_draw_per_use = 500 // Inefficency has to come from somewhere.
	var/amount_to_move = 5000

/obj/item/integrated_circuit/power/transmitter/large
	name = "large power transmission circuit"
	desc = "This can wirelessly transmit a lot of electricity from an assembly's battery towards a nearby machine.  Warning:  Do not operate in flammable enviroments."
	extended_desc = "This circuit transmits 20 kJ of electricity every time the activator pin is pulsed. The input pin must be \
	a reference to a machine to send electricity to.  This can be a battery, or anything containing a battery.  The machine can exist \
	inside the assembly, or adjacent to it.  The power is sourced from the assembly's power cell.  If the target is outside of the assembly, \
	some power is lost due to ineffiency."
	w_class = WEIGHT_CLASS_BULKY
	complexity = 32
	origin_tech = list(TECH_ENGINEERING = 4, TECH_DATA = 4, TECH_POWER = 6, TECH_MAGNET = 5)
	power_draw_per_use = 2000
	amount_to_move = 20000

/obj/item/integrated_circuit/power/transmitter/do_work()

	var/atom/movable/AM = get_pin_data_as_type(IC_INPUT, 1, /atom/movable)
	if(AM)
		if(!assembly)
			return FALSE // Pointless to do everything else if there's no battery to draw from.

		var/obj/item/stock_parts/cell/cell = null
		if(istype(AM, /obj/item/stock_parts/cell)) // Is this already a cell?
			cell = AM
		else // If not, maybe there's a cell inside it?
			for(var/obj/item/stock_parts/cell/C in AM.contents)
				if(C) // Find one cell to charge.
					cell = C
					break
		if(cell)
			var/transfer_amount = amount_to_move
			var/turf/A = get_turf(src)
			var/turf/B = get_turf(AM)
			if(A.Adjacent(B))
				if(AM.loc != assembly)
					transfer_amount *= 0.8 // Losses due to distance.

				if(cell.charge == cell.maxcharge)
					return FALSE

				if(transfer_amount && assembly.draw_power(amount_to_move)) // CELLRATE is already handled in draw_power()
					cell.give(transfer_amount * GLOB.CELLRATE)
				set_pin_data(IC_OUTPUT, 1, cell.charge)
				set_pin_data(IC_OUTPUT, 2, cell.maxcharge)
				set_pin_data(IC_OUTPUT, 3, cell.percent())
				activate_pin(2)
				push_data()
				return TRUE
		else
			set_pin_data(IC_OUTPUT, 1, null)
			set_pin_data(IC_OUTPUT, 2, null)
			set_pin_data(IC_OUTPUT, 3, null)
			activate_pin(2)
			push_data()
			return FALSE
	return FALSE

/obj/item/integrated_circuit/power/transmitter/large/do_work()
	if(..()) // If the above code succeeds, do this below.
		if(prob(2))
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(12, 1, src)
			s.start()
			visible_message("<span class='warning'>\The [assembly] makes some sparks!</span>")