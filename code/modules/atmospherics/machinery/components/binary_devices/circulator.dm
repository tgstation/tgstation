//node2, air2, network2 correspond to input
//node1, air1, network1 correspond to output

/obj/machinery/atmospherics/components/binary/circulator
	name = "circulator/heat exchanger"
	desc = "A gas circulator pump and heat exchanger."
	icon_state = "circ-off"

	var/active = FALSE

	var/last_pressure_delta = 0
	pipe_flags = PIPING_ONE_PER_TURF

	anchored = TRUE
	density = TRUE
	var/const/hot = 0
	var/const/cold = 1

	var/mode = hot
	var/obj/machinery/power/generator/generator

//default cold circ for mappers
/obj/machinery/atmospherics/components/binary/circulator/cold
	mode = cold

/obj/machinery/atmospherics/components/binary/circulator/proc/return_transfer_air()

	var/datum/gas_mixture/air1 = airs[1]
	var/datum/gas_mixture/air2 = airs[2]

	var/output_starting_pressure = air1.return_pressure()
	var/input_starting_pressure = air2.return_pressure()

	if(output_starting_pressure >= input_starting_pressure-10)
		//Need at least 10 KPa difference to overcome friction in the mechanism
		last_pressure_delta = 0
		return null

	//Calculate necessary moles to transfer using PV = nRT
	if(air2.temperature>0)
		var/pressure_delta = (input_starting_pressure - output_starting_pressure)/2

		var/transfer_moles = pressure_delta*air1.volume/(air2.temperature * R_IDEAL_GAS_EQUATION)

		last_pressure_delta = pressure_delta

		//Actually transfer the gas
		var/datum/gas_mixture/removed = air2.remove(transfer_moles)

		update_parents()

		return removed

	else
		last_pressure_delta = 0

/obj/machinery/atmospherics/components/binary/circulator/process_atmos()
	..()
	update_icon()

/obj/machinery/atmospherics/components/binary/circulator/update_icon()
	if(!is_operational())
		icon_state = "circ-p"
	else if(last_pressure_delta > 0)
		if(last_pressure_delta > ONE_ATMOSPHERE)
			icon_state = "circ-run"
		else
			icon_state = "circ-slow"
	else
		icon_state = "circ-off"

/obj/machinery/atmospherics/components/binary/circulator/attackby(obj/item/O, mob/user, params)
	if(panel_open)

		if(istype(O, /obj/item/wrench))
			anchored = !anchored
			O.play_tool_sound(src)
			if(generator)
				disconnectFromGenerator()
			to_chat(user, "<span class='notice'>You [anchored?"secure":"unsecure"] \the [src].</span>")
			return

		else if(istype(O, /obj/item/multitool))
			if(generator)
				disconnectFromGenerator()
			mode = !mode
			to_chat(user, "<span class='notice'>You set \the [src] to [mode?"cold":"hot"] mode.</span>")
			return

		else if(default_deconstruction_crowbar(O))
			return

	if(istype(O, /obj/item/screwdriver))
		panel_open = !panel_open
		O.play_tool_sound(src)
		to_chat(user, "<span class='notice'>You [panel_open?"open":"close"] \the [src]'s panel.</span>")
		return

	else
		return ..()

/obj/machinery/atmospherics/components/binary/circulator/on_deconstruction()
	if(generator)
		disconnectFromGenerator()

/obj/machinery/atmospherics/components/binary/circulator/proc/disconnectFromGenerator()
	if(mode)
		generator.cold_circ = null
	else
		generator.hot_circ = null
	generator.update_icon()
	generator = null