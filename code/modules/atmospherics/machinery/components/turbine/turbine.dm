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
	airs[1].volume = 1000

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
	var/datum/gas_mixture/first_point
	var/datum/gas_mixture/second_point
	var/efficiency = 0.9
	var/first_volume = 500
	var/second_volume = 1000
	var/rpm = 0

/obj/machinery/turbine_controller/Initialize()
	. = ..()
	SSair.start_processing_machine(src)
	first_point = new
	first_point.volume = 500
	second_point = new
	second_point.volume = 1000

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

/obj/machinery/turbine_controller/process_atmos()
	if(!connected)
		return
	var/datum/gas_mixture/input_remove = inlet.airs[1].remove(inlet.airs[1].total_moles())
	var/datum/gas_mixture/output = outlet.airs[1]

	first_point.volume = first_volume
	second_point.volume = second_volume

	first_point.merge(input_remove)
	var/first_point_pressure = first_point.return_pressure()
	var/first_point_temperature = first_point.return_temperature()
	var/datum/gas_mixture/first_remove = first_point.remove(first_point.total_moles())

	second_point.merge(first_remove)
	var/second_point_pressure = second_point.return_pressure()

	var/work_done = 0
	if(first_remove.temperature > 1e3 || second_point_pressure > 1000)
		work_done = efficiency * second_point.total_moles() * R_IDEAL_GAS_EQUATION * first_point_temperature * log((first_point_pressure / second_point_pressure)) - rpm

	message_admins("[work_done] work_done")

	rpm = (work_done ** 0.6) * 4

	message_admins("[rpm] rpm")

	efficiency = clamp(1 - log(10, max(second_point.temperature, 1e3)) * 0.1, 0, 1)

	message_admins("[efficiency] efficiency")

	var/heat_capacity = second_point.heat_capacity()
	second_point.temperature = max((second_point.temperature * heat_capacity - work_done * second_point.total_moles() * 0.1) / heat_capacity, TCMB)

	var/datum/gas_mixture/second_remove = second_point.remove(second_point.total_moles())

	output.merge(second_remove)

	inlet.update_parents()
	outlet.update_parents()
