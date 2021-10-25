/obj/machinery/heat_system
	var/heat_capacity = 500
	var/temporary_temperature = T20C

/obj/machinery/heat_system/heat_pipe
	name = "heat pipe"
	desc = "test"
	icon = 'icons/obj/plumbing/fluid_ducts.dmi'
	icon_state = "nduct"

	layer = LOW_OBJ_LAYER


	///set to TRUE to disable autoconnect
	var/stop_autoconnect = FALSE
	///wheter we allow our connects to be changed after initialization or not
	var/lock_connects = FALSE
	///bitfield with the directions we're connected in
	var/connects
	///our pipeline
	var/datum/heat_pipeline/heat_pipeline
	///1,2,4,8,16
	var/pipe_layer = DUCT_LAYER_DEFAULT
	///track the pipes we're connected to
	var/list/neighbours = list()

	var/removable = TRUE

/obj/machinery/heat_system/heat_pipe/Initialize(mapload, force_direction = null, can_remove = TRUE)
	. = ..()

	add_atom_colour(COLOR_BRIGHT_ORANGE, FIXED_COLOUR_PRIORITY)

	if(!isnull(force_direction))
		stop_autoconnect = TRUE
		connects = force_direction

	removable = can_remove

	create_pipeline()
	handle_layer()
	attempt_connect()

/obj/machinery/heat_system/heat_pipe/Destroy()
	nullify_pipeline()
	return ..()

/obj/machinery/heat_system/heat_pipe/proc/handle_layer()
	var/offset
	switch(pipe_layer)//it's a bitfield, but it's fine because it only works when there's one layer, and multiple layers should be handled differently
		if(FIRST_DUCT_LAYER)
			offset = -10
		if(SECOND_DUCT_LAYER)
			offset = -5
		if(THIRD_DUCT_LAYER)
			offset = 0
		if(FOURTH_DUCT_LAYER)
			offset = 5
		if(FIFTH_DUCT_LAYER)
			offset = 10
	pixel_x = offset
	pixel_y = offset

/obj/machinery/heat_system/heat_pipe/update_icon_state()
	var/temp_icon = initial(icon_state)
	for(var/direction in GLOB.cardinals)
		if(direction & connects)
			if(direction == NORTH)
				temp_icon += "_n"
			if(direction == SOUTH)
				temp_icon += "_s"
			if(direction == EAST)
				temp_icon += "_e"
			if(direction == WEST)
				temp_icon += "_w"
	icon_state = temp_icon
	return ..()

/obj/machinery/heat_system/heat_pipe/proc/attempt_connect()
	for(var/direction in GLOB.cardinals)
		if(stop_autoconnect && !(direction & connects))
			continue
		for(var/obj/machinery/heat_system/heat_pipe/pipe in get_step(src, direction))
			if(connect_network(pipe, direction))
				add_connects(direction)
	update_appearance()

/obj/machinery/heat_system/heat_pipe/proc/connect_network(obj/machinery/heat_system/heat_pipe/pipe, direction)
	return connect_pipe(pipe, direction)

/obj/machinery/heat_system/heat_pipe/proc/connect_pipe(obj/machinery/heat_system/heat_pipe/pipe, direction)
	var/opposite_dir = turn(direction, 180)

	if(!stop_autoconnect && pipe.stop_autoconnect && !(opposite_dir & pipe.connects))
		return
	if(stop_autoconnect && pipe.stop_autoconnect && !(connects & pipe.connects))
		return

	if((heat_pipeline == pipe.heat_pipeline) && heat_pipeline)
		add_neighbour(pipe, direction)

		pipe.add_connects(opposite_dir)
		pipe.update_appearance()
		return TRUE
	if(!(pipe in neighbours))
		if(!(pipe_layer & pipe.pipe_layer))
			return

	if(pipe.heat_pipeline)
		if(heat_pipeline)
			heat_pipeline.assimilate(pipe.heat_pipeline)
		else
			pipe.heat_pipeline.add_pipe(src)
	else
		if(heat_pipeline)
			heat_pipeline.add_pipe(pipe)
		else
			create_pipeline()
			heat_pipeline.add_pipe(pipe)

	add_neighbour(pipe, direction)

	addtimer(CALLBACK(pipe, .proc/attempt_connect))

	return TRUE

/obj/machinery/heat_system/heat_pipe/proc/create_pipeline()
	heat_pipeline = new()
	heat_pipeline.add_pipe(src)

///add a duct as neighbour. this means we're connected and will connect again if we ever regenerate
/obj/machinery/heat_system/heat_pipe/proc/add_neighbour(obj/machinery/heat_system/heat_pipe/pipe, direction)
	if(!(pipe in neighbours))
		neighbours[pipe] = direction
	if(!(src in pipe.neighbours))
		pipe.neighbours[src] = turn(direction, 180)

///remove all our neighbours, and remove us from our neighbours aswell
/obj/machinery/heat_system/heat_pipe/proc/lose_neighbours()
	for(var/obj/machinery/heat_system/heat_pipe/pipe in neighbours)
		pipe.neighbours.Remove(src)
		var/direction = get_dir(pipe, src)
		pipe.remove_connects(direction)
		pipe.update_appearance()
	neighbours = list()

///add a connect direction
/obj/machinery/heat_system/heat_pipe/proc/add_connects(new_connects)
	if(!lock_connects)
		connects |= new_connects

///remove a connect direction
/obj/machinery/heat_system/heat_pipe/proc/remove_connects(dead_connects)
	if(!lock_connects)
		connects &= ~dead_connects

///remove our connects
/obj/machinery/heat_system/heat_pipe/proc/reset_connects()
	if(!lock_connects)
		connects = 0

/obj/machinery/heat_system/heat_pipe/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return
	if(anchorvalue)
		attempt_connect()
	else
		disconnect_pipe(TRUE)

/obj/machinery/heat_system/heat_pipe/proc/disconnect_pipe(skipanchor)
	if(!skipanchor) //since set_anchored calls us too.
		set_anchored(FALSE)
	nullify_pipeline()
	lose_neighbours()
	reset_connects()
	update_appearance()
	if(!QDELETED(src))
		qdel(src)

/obj/machinery/heat_system/heat_pipe/proc/nullify_pipeline()
	if(heat_pipeline)
		heat_pipeline.remove_pipe(src)
		heat_pipeline = null

/obj/machinery/heat_system/heat_pipe/wrench_act(mob/living/user, obj/item/I)
	..()
	if((removable && anchored) || can_anchor())
		add_fingerprint(user)
		I.play_tool_sound(src)
		set_anchored(!anchored)
		user.visible_message( \
		"[user] [anchored ? null : "un"]fastens \the [src].", \
		span_notice("You [anchored ? null : "un"]fasten \the [src]."), \
		span_hear("You hear ratcheting."))
	return TRUE

/obj/machinery/heat_system/heat_pipe/proc/can_anchor(turf/T)
	if(!removable)
		return FALSE
	if(!T)
		T = get_turf(src)
	for(var/obj/machinery/heat_system/heat_pipe/D in T)
		if(!anchored || D == src)
			continue
		for(var/A in GLOB.cardinals)
			if(A & connects && A & D.connects)
				return FALSE
	return TRUE

/obj/machinery/heat_system/heat_pipe/proc/change_pipeline_energy(energy_amount)
	if(!heat_pipeline)
		return
	heat_pipeline.change_energy(energy_amount)




/obj/machinery/heat_system/heat_pipe/radiator
	name = "heat radiator"

/obj/machinery/heat_system/heat_pipe/radiator/Initialize(mapload)
	. = ..()
	SSair.atmos_machinery += src

/obj/machinery/heat_system/heat_pipe/radiator/Destroy()
	SSair.atmos_machinery -= src
	return ..()

/obj/machinery/heat_system/heat_pipe/radiator/update_overlays()
	. = ..()
	var/mutable_appearance/radiator = mutable_appearance('icons/obj/atmospherics/components/unary_devices.dmi', "heat_radiator", layer = (src.layer+0.01))
	. += radiator

/obj/machinery/heat_system/heat_pipe/radiator/process_atmos()
	var/turf/local_turf = loc

	var/datum/gas_mixture/environment = local_turf.return_air()

	var/env_temperature = environment.temperature
	var/env_heat_capacity = environment.heat_capacity()
	var/delta_temperature = heat_pipeline.temperature - env_temperature

	if(abs(delta_temperature) < 20)
		return

	var/moved_heat = 0.6 * delta_temperature * (heat_capacity * env_heat_capacity / (heat_capacity + env_heat_capacity))
	environment.temperature += moved_heat / env_heat_capacity
	local_turf.air_update_turf(TRUE)
	change_pipeline_energy(-moved_heat)







/obj/machinery/heat_system/separation_valve
	name = "separation valve"
	var/open = TRUE
	var/obj/machinery/heat_system/heat_pipe/port_1
	var/obj/machinery/heat_system/heat_pipe/port_2

/obj/machinery/heat_system/separation_valve/Initialize(mapload)
	. = ..()
	port_1 = new(loc, dir, FALSE)
	port_2 = new(loc, turn(dir, 180), FALSE)

	port_1.heat_pipeline.assimilate(port_2.heat_pipeline)

/obj/machinery/heat_system/separation_valve/update_overlays()
	. = ..()
	var/mutable_appearance/radiator = mutable_appearance('icons/obj/atmospherics/components/unary_devices.dmi', "heat_radiator", layer = (src.layer+0.01))
	. += radiator

/obj/machinery/heat_system/separation_valve/CtrlClick(mob/user)
	. = ..()
	toggle_open()

/obj/machinery/heat_system/separation_valve/proc/toggle_open()
	if(open)
		open = FALSE
		port_1.heat_pipeline.destroy_network()
		port_1.attempt_connect()
		port_2.attempt_connect()
		return
	open = TRUE
	port_1.heat_pipeline.assimilate(port_2.heat_pipeline)







/datum/heat_pipeline
	var/list/obj/machinery/heat_system/heat_pipe/heat_pipes = list()
	var/heat_capacity
	var/temperature

/datum/heat_pipeline/proc/add_pipe(obj/machinery/heat_system/heat_pipe/heat_pipe)
	if(!heat_pipe || (heat_pipe in heat_pipes))
		return FALSE

	heat_pipes += heat_pipe
	heat_pipe.heat_pipeline = src
	if(heat_capacity && heat_pipe.temporary_temperature)
		merge_heat(heat_pipe.heat_capacity, heat_pipe.temporary_temperature)
	heat_capacity += heat_pipe.heat_capacity
	if(!temperature && heat_pipe.temporary_temperature)
		temperature = heat_pipe.temporary_temperature
	heat_pipe.temporary_temperature = null

/datum/heat_pipeline/proc/remove_pipe(obj/machinery/heat_system/heat_pipe/heat_pipe)
	destroy_network(FALSE)
	for(var/obj/machinery/heat_system/heat_pipe/pipe in heat_pipe.neighbours)
		addtimer(CALLBACK(pipe, /obj/machinery/heat_system/heat_pipe/proc/attempt_connect))
	qdel(src)

/datum/heat_pipeline/proc/destroy_network(delete = TRUE, store_temperature = TRUE)
	for(var/obj/machinery/heat_system/heat_pipe/heat_pipe as anything in heat_pipes)
		if(store_temperature)
			heat_pipe.temporary_temperature = temperature
		heat_pipe.heat_pipeline = null
	if(delete)
		qdel(src)

/datum/heat_pipeline/proc/assimilate(datum/heat_pipeline/other_pipeline)

	if(heat_capacity && other_pipeline.temperature)
		merge_heat(other_pipeline.heat_capacity, other_pipeline.temperature)

	if(!temperature && other_pipeline.temperature)
		temperature = other_pipeline.temperature

	heat_pipes.Add(other_pipeline.heat_pipes)
	heat_capacity += other_pipeline.heat_capacity

	for(var/obj/machinery/heat_system/heat_pipe/pipe as anything in other_pipeline.heat_pipes)
		pipe.heat_pipeline = src

	other_pipeline.heat_pipes.Cut()
	other_pipeline.destroy_network(store_temperature = FALSE)

/datum/heat_pipeline/proc/merge_heat(other_heat_capacity, other_temperature)
	if(!other_heat_capacity)
		return
	if(!other_temperature)
		other_temperature = T20C

	var/our_energy = heat_capacity * temperature
	var/other_energy = other_heat_capacity * other_temperature
	var/combined_heat_capacity = heat_capacity + other_heat_capacity
	temperature = (our_energy + other_energy) / combined_heat_capacity

/datum/heat_pipeline/proc/change_energy(energy_amount)
	if(!energy_amount)
		return

	var/our_energy = heat_capacity * temperature
	temperature = max((our_energy + energy_amount) / heat_capacity, TCMB)
