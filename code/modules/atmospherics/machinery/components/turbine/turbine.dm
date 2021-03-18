/obj/machinery/atmospherics/components/unary/turbine
	icon = 'icons/obj/atmospherics/components/turbine.dmi'
	layer = OBJ_LAYER
	density = TRUE
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY
	var/connected = FALSE
	var/initial_volume = 500
	var/base_icon = ""

/obj/machinery/atmospherics/components/unary/turbine/attackby(obj/item/I, mob/user, params)
	if(!on)
		if(default_deconstruction_screwdriver(user, "[base_icon]", "[base_icon]", I))
			update_appearance()
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/atmospherics/components/unary/turbine/default_change_direction_wrench(mob/user, obj/item/I)
	if(!..())
		return FALSE
	SetInitDirections()
	var/obj/machinery/atmospherics/node = nodes[1]
	if(node)
		if(src in node.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
			node.disconnect(src)
		nodes[1] = null
	if(parents[1])
		nullifyPipenet(parents[1])

	atmosinit()
	node = nodes[1]
	if(node)
		node.atmosinit()
		node.addMember(src)
	SSair.add_to_rebuild_queue(src)
	return TRUE

/obj/machinery/atmospherics/components/unary/turbine/Initialize()
	. = ..()
	airs[1].volume = initial_volume

/obj/machinery/atmospherics/components/unary/turbine/turbine_inlet
	icon_state = "turbine_inlet"
	name = "Temperature control unit"
	desc = "Heats or cools gas in connected pipes."
	circuit = /obj/item/circuitboard/machine/thermomachine
	initial_volume = 500
	base_icon = "turbine_inlet"

/obj/machinery/atmospherics/components/unary/turbine/turbine_outlet
	icon_state = "turbine_outlet"
	name = "Temperature control unit"
	desc = "Heats or cools gas in connected pipes."
	circuit = /obj/item/circuitboard/machine/thermomachine
	initial_volume = 1000
	base_icon = "turbine_outlet"











/obj/machinery/power/turbine
	icon = 'icons/obj/atmospherics/components/turbine.dmi'
	layer = OBJ_LAYER
	density = TRUE
	var/connected = FALSE
	var/base_icon = ""
	var/on = FALSE

/obj/machinery/power/turbine/attackby(obj/item/I, mob/user, params)
	if(!on)
		if(default_deconstruction_screwdriver(user, "[base_icon]", "[base_icon]", I))
			update_appearance()
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/power/turbine/turbine_shaft
	icon_state = "turbine_shaft"
	name = "Temperature control unit"
	desc = "Heats or cools gas in connected pipes."
	circuit = /obj/item/circuitboard/machine/thermomachine
	base_icon = "turbine_shaft"

/obj/machinery/power/turbine/turbine_mod
	icon_state = "turbine_mod"
	name = "Temperature control unit"
	desc = "Heats or cools gas in connected pipes."
	circuit = /obj/item/circuitboard/machine/thermomachine
	base_icon = "turbine_mod"
	var/modify_behaviour = FALSE

/obj/machinery/power/turbine/turbine_controller
	icon_state = "turbine_interface"
	name = "Temperature control unit"
	desc = "Heats or cools gas in connected pipes."
	circuit = /obj/item/circuitboard/machine/thermomachine
	base_icon = "turbine_interface"
	var/list/machine_types = list()
	var/obj/machinery/atmospherics/components/unary/turbine/turbine_inlet/inlet
	var/obj/machinery/atmospherics/components/unary/turbine/turbine_outlet/outlet
	var/obj/machinery/power/turbine/turbine_shaft/shaft
	var/list/turbine_mods = list()
	var/datum/gas_mixture/first_point
	var/datum/gas_mixture/second_point
	var/efficiency = 0.9
	var/first_volume = 500
	var/second_volume = 1000
	var/rpm = 0
	var/generated_power = 0

/obj/machinery/power/turbine/turbine_controller/Initialize()
	. = ..()
	SSair.start_processing_machine(src)
	first_point = new
	first_point.volume = 500
	second_point = new
	second_point.volume = 1000

/obj/machinery/power/turbine/turbine_controller/Destroy()
	SSair.stop_processing_machine(src)
	return ..()

/obj/machinery/power/turbine/turbine_controller/multitool_act(mob/living/user, obj/item/multitool/I)
	. = ..()
	if(istype(I))
		if(connect_to_network())
			check_connection()
			return TRUE
	return FALSE

/obj/machinery/power/turbine/turbine_controller/proc/check_connection()
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
			if(istype(machine, /obj/machinery/atmospherics/components/unary/turbine/turbine_inlet))
				if(machine.dir == turn(dir, 270))
					machine_types |= machine
					inlet = machine
			if(istype(machine, /obj/machinery/atmospherics/components/unary/turbine/turbine_outlet))
				if(machine.dir == turn(dir, 90))
					machine_types |= machine
					outlet = machine
			if(istype(machine, /obj/machinery/power/turbine/turbine_shaft))
				if(machine.dir == turn(dir, 90))
					machine_types |= machine
					shaft = machine
			if(istype(machine, /obj/machinery/power/turbine/turbine_mod))
				if(machine.dir == dir)
					machine_types |= machine
					turbine_mods |= machine
	if(machine_types.len + 1 == 6)
		connected = TRUE
		inlet.connected = TRUE
		outlet.connected = TRUE
		shaft.connected = TRUE
		for(var/obj/machinery/power/turbine/turbine_mod/mod in turbine_mods)
			mod.connected = TRUE

/obj/machinery/power/turbine/turbine_controller/process_atmos()
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
	var/second_point_temperature = second_point.temperature

	var/work_done = 0
	var/delta_pressure = - (second_point_pressure - first_point_pressure)
	if(first_point_temperature > 500 || delta_pressure > 500)
		work_done = efficiency * second_point.total_moles() * R_IDEAL_GAS_EQUATION * first_point_temperature * log((first_point_pressure / second_point_pressure)) - rpm

	rpm = (work_done ** 0.6) * 4

	efficiency = clamp(1 - log(10, max(second_point_temperature, 1e3)) * 0.1, 0, 1)

	generated_power = rpm * efficiency * 10

	add_avail(generated_power)

	var/heat_capacity = second_point.heat_capacity()
	second_point.temperature = max((second_point.temperature * heat_capacity - work_done * second_point.total_moles() * 0.05) / heat_capacity, TCMB)

	var/datum/gas_mixture/second_remove = second_point.remove(second_point.total_moles())

	output.merge(second_remove)

	inlet.update_parents()
	outlet.update_parents()
