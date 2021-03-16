/obj/machinery/atmospherics/components/unary/turbine_inlet
	icon = 'icons/obj/atmospherics/components/turbine.dmi'
	icon_state = "turbine_inlet"
	name = "Temperature control unit"
	desc = "Heats or cools gas in connected pipes."
	layer = OBJ_LAYER
	density = TRUE
	circuit = /obj/item/circuitboard/machine/thermomachine
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY
	var/connected = FALSE

/obj/machinery/atmospherics/components/unary/turbine_inlet/Initialize()
	. = ..()
	airs[1].volume = 500

/obj/machinery/atmospherics/components/unary/turbine_outlet
	icon = 'icons/obj/atmospherics/components/turbine.dmi'
	icon_state = "turbine_outlet"
	name = "Temperature control unit"
	desc = "Heats or cools gas in connected pipes."
	layer = OBJ_LAYER
	density = TRUE
	circuit = /obj/item/circuitboard/machine/thermomachine
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY
	var/connected = FALSE

/obj/machinery/atmospherics/components/unary/turbine_outlet/Initialize()
	. = ..()
	airs[1].volume = 700

/obj/machinery/turbine_shaft
	icon = 'icons/obj/atmospherics/components/turbine.dmi'
	icon_state = "turbine_shaft"
	name = "Temperature control unit"
	desc = "Heats or cools gas in connected pipes."
	layer = OBJ_LAYER
	density = TRUE
	circuit = /obj/item/circuitboard/machine/thermomachine
	var/connected = FALSE

/obj/machinery/turbine_mod
	icon = 'icons/obj/atmospherics/components/turbine.dmi'
	icon_state = "turbine_mod"
	name = "Temperature control unit"
	desc = "Heats or cools gas in connected pipes."
	layer = OBJ_LAYER
	density = TRUE
	circuit = /obj/item/circuitboard/machine/thermomachine
	var/connected = FALSE
	var/modify_behaviour = FALSE

/obj/machinery/turbine_controller
	icon = 'icons/obj/atmospherics/components/turbine.dmi'
	icon_state = "turbine_interface"
	name = "Temperature control unit"
	desc = "Heats or cools gas in connected pipes."
	layer = OBJ_LAYER
	density = TRUE
	circuit = /obj/item/circuitboard/machine/thermomachine
	var/connected = FALSE
	var/list/machine_types = list()
	var/obj/machinery/atmospherics/components/unary/turbine_inlet/inlet
	var/obj/machinery/atmospherics/components/unary/turbine_outlet/outlet
	var/obj/machinery/turbine_shaft/shaft
	var/list/turbine_mods = list()
	var/datum/gas_mixture/entry_point
	var/datum/gas_mixture/mid_point
	var/datum/gas_mixture/exit_point

/obj/machinery/turbine_controller/Initialize()
	. = ..()
	SSair.start_processing_machine(src)
	mid_point = new
	mid_point.volume = 600

/obj/machinery/turbine_controller/Destroy()
	SSair.stop_processing_machine(src)
	return ..()

/obj/machinery/turbine_controller/multitool_act(mob/living/user, obj/item/multitool/I)
	. = ..()
	if(istype(I))
		check_connection()
		return TRUE
	return FALSE

/obj/machinery/turbine_controller/proc/check_connection()
	var/turf/controller = get_turf(src)
	var/turf/vertical = get_step(controller, turn(dir, 180))
	var/turf/horizontal = get_step(get_step(controller, turn(dir, 90)), turn(dir, 90))
	var/turf/diagonal = locate(horizontal.x, vertical.y, controller.z)
	if(dir & NORTH || dir & SOUTH)
		diagonal = locate(horizontal.x, vertical.y, controller.z)
	else
		diagonal = locate(vertical.x, horizontal.y, controller.z)

	for(var/turf/floor in block(controller, diagonal))
		for(var/obj/machinery/machine in floor.contents)
			if(istype(machine, /obj/machinery/atmospherics/components/unary/turbine_inlet))
				if(machine.dir == turn(dir, 270))
					machine_types |= machine
					inlet = machine
			if(istype(machine, /obj/machinery/atmospherics/components/unary/turbine_outlet))
				if(machine.dir == turn(dir, 90))
					machine_types |= machine
					outlet = machine
			if(istype(machine, /obj/machinery/turbine_shaft))
				if(machine.dir == turn(dir, 90))
					machine_types |= machine
					shaft = machine
			if(istype(machine, /obj/machinery/turbine_mod))
				if(machine.dir == dir)
					machine_types |= machine
					turbine_mods |= machine
	if(machine_types.len + 1 == 6)
		connected = TRUE
		inlet.connected = TRUE
		outlet.connected = TRUE
		shaft.connected = TRUE
		for(var/obj/machinery/turbine_mod/mod in turbine_mods)
			mod.connected = TRUE

/obj/machinery/turbine_controller/process()
	if(!connected)
		return
	var/datum/gas_mixture/input = inlet.airs[1]
	var/datum/gas_mixture/output = outlet.airs[1]
	var/input_pressure = input.return_pressure()
	var/mid_point_pressure = mid_point.return_pressure()
	var/mid_pressure_ratio = - (mid_point_pressure - input_pressure) / (mid_point_pressure + input_pressure)
	input.pump_gas_to(mid_point, input_pressure * mid_pressure_ratio)

	mid_point_pressure = mid_point.return_pressure()
	var/exit_point_pressure = output.return_pressure()
	var/exit_pressure_ratio = - (exit_point_pressure - mid_point_pressure) / (exit_point_pressure + mid_point_pressure)
	mid_point.pump_gas_to(output, mid_point_pressure * exit_pressure_ratio)

	inlet.update_parents()
	outlet.update_parents()


