/// A vent, scrubber and a sensor in a single device meant specifically for cycling airlocks. Ideal for airlocks of up to 3x3 tiles in size to avoid wind and timing out.
/obj/machinery/atmospherics/components/unary/airlock_pump
	name = "external airlock pump"
	desc = "A pump for cycling an external airlock controlled by the connected doors."
	icon = 'icons/obj/machines/atmospherics/unary_devices.dmi'
	icon_state = "airlock_pump"
	pipe_state = "airlock_pump"
	use_power = ACTIVE_POWER_USE
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION
	can_unwrench = TRUE
	welded = FALSE
	vent_movement = VENTCRAWL_ALLOWED | VENTCRAWL_CAN_SEE | VENTCRAWL_ENTRANCE_ALLOWED
	max_integrity = 100
	paintable = FALSE
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DISTRO_AND_WASTE_LAYERS | PIPING_DEFAULT_LAYER_ONLY | PIPING_ALL_COLORS
	layer = GAS_PUMP_LAYER
	hide = TRUE
	device_type = BINARY // Even though it is unary, it has two nodes on one side - used in node count checks

	///Indicates that the direction of the pump, if ATMOS_DIRECTION_SIPHONING is siphoning, if ATMOS_DIRECTION_RELEASING is releasing
	var/pump_direction = ATMOS_DIRECTION_SIPHONING
	///Target pressure for pressurization cycle
	var/internal_pressure_target = ONE_ATMOSPHERE
	///Target pressure for depressurization cycle
	var/external_pressure_target = 0
	///Allowed error in pressure checks
	var/allowed_pressure_error = ONE_ATMOSPHERE / 100
	///Rate of the pump to remove gases from the air
	var/volume_rate = 1000
	///The start time of the current cycle to calculate cycle duration
	var/cycle_start_time
	///Max duration of cycle, after which the pump will unlock the airlocks with a warning
	var/cycle_timeout = 10 SECONDS
	///List of the turfs adjacent to the pump for faster cycling and avoiding wind
	var/list/turf/adjacent_turfs = list()
	///Max distance between the airlock and the pump. Used to set up cycling.
	var/airlock_distance_limit = 2
	///Type of airlocks required for automatic cycling setup. To avoid hacking bridge doors.
	var/valid_airlock_typepath = /obj/machinery/door/airlock/external
	///Station-facing airlock used in cycling
	var/obj/machinery/door/airlock/internal_airlock
	///Space-facing airlock used in cycling
	var/obj/machinery/door/airlock/external_airlock
	///Whether both airlocks are specified and cycling is available
	var/cycling_set_up = FALSE

	COOLDOWN_DECLARE(check_turfs_cooldown)

/obj/machinery/atmospherics/components/unary/airlock_pump/update_icon_nopipes()
	if(!on || !is_operational || !powered())
		icon_state = "vent_off"
	else
		icon_state = pump_direction ? "vent_out" : "vent_in"

/obj/machinery/atmospherics/components/unary/airlock_pump/update_overlays()
	. = ..()
	if(!showpipe)
		return
	if(nodes[1])
		var/mutable_appearance/distro_pipe_appearance = get_pipe_image(icon, "airlock_pump_pipe", dir, COLOR_BLUE, piping_layer = 4)
		. += distro_pipe_appearance
	if(nodes[2])
		var/mutable_appearance/waste_pipe_appearance = get_pipe_image(icon, "airlock_pump_pipe", dir, COLOR_RED, piping_layer = 2)
		. += waste_pipe_appearance
	var/mutable_appearance/distro_cap_appearance = get_pipe_image(icon, "vent_cap", dir, COLOR_BLUE, piping_layer = 4)
	. += distro_cap_appearance
	var/mutable_appearance/waste_cap_appearance = get_pipe_image(icon, "vent_cap", dir, COLOR_RED, piping_layer = 2)
	. += waste_cap_appearance

/obj/machinery/atmospherics/components/unary/airlock_pump/atmos_init(list/node_connects)
	for(var/obj/machinery/atmospherics/target in get_step(src, dir))
		if(connection_check(target, 4) && !nodes[1])
			nodes[1] = target // Distro
		if(connection_check(target, 2) && !nodes[2])
			nodes[2] = target // Waste
	update_appearance()

/obj/machinery/atmospherics/components/unary/airlock_pump/post_machine_initialize()
	. = ..()
	set_links()

/obj/machinery/atmospherics/components/unary/airlock_pump/New()
	. = ..()
	var/datum/gas_mixture/distro_air = airs[1]
	var/datum/gas_mixture/waste_air = airs[2]
	distro_air.volume = 1000
	waste_air.volume = 1000

/obj/machinery/atmospherics/components/unary/airlock_pump/on_deconstruction(disassembled)
	. = ..()
	if(cycling_set_up)
		break_links()

/obj/machinery/atmospherics/components/unary/airlock_pump/power_change()
	. = ..()
	if(on && !powered())
		stop_cycle("No power. Aborting cycle.")

/obj/machinery/atmospherics/components/unary/airlock_pump/process_atmos()
	if(!on)
		return

	var/turf/location = get_turf(loc)
	if(isclosedturf(location))
		return

	if(COOLDOWN_FINISHED(src, check_turfs_cooldown))
		check_turfs()
		COOLDOWN_START(src, check_turfs_cooldown, 2 SECONDS)

	if(world.time - cycle_start_time > cycle_timeout)
		stop_cycle("Cycling timed out, bolts unlocked.")
		return //Couldn't complete the cycle before timeout

	var/datum/gas_mixture/distro_air = airs[1]
	var/datum/gas_mixture/tile_air = loc.return_air()
	var/tile_air_pressure = tile_air.return_pressure()

	if(pump_direction == ATMOS_DIRECTION_RELEASING) //distro node -> tile
		var/pressure_delta = internal_pressure_target - tile_air_pressure

		if(pressure_delta <= allowed_pressure_error && stop_cycle())
			internal_airlock.say("Pressurization complete.")
			return //Target pressure reached

		var/available_moles = distro_air.total_moles()
		var/total_tiles = adjacent_turfs.len + 1
		var/split_moles = QUANTIZE(available_moles / total_tiles)

		fill_tile(loc, split_moles, pressure_delta)
		for(var/turf/tile in adjacent_turfs)
			fill_tile(tile, split_moles, pressure_delta)
	else //tile -> waste node
		var/pressure_delta = tile_air_pressure - external_pressure_target

		if(pressure_delta <= allowed_pressure_error && stop_cycle())
			external_airlock.say("Decompression complete.")
			return //Target pressure reached

		siphon_tile(loc)
		for(var/turf/tile in adjacent_turfs)
			siphon_tile(tile)

/obj/machinery/atmospherics/components/unary/airlock_pump/proc/fill_tile(turf/tile, moles, pressure_delta)
	var/datum/pipeline/distro_pipe = parents[1]
	var/datum/gas_mixture/distro_air = airs[1]
	var/datum/gas_mixture/tile_air = tile.return_air()
	var/transfer_moles = (volume_rate / tile_air.volume) * (pressure_delta * tile_air.volume) / (distro_air.temperature * R_IDEAL_GAS_EQUATION)
	moles = min(moles, transfer_moles)

	var/datum/gas_mixture/removed_air = distro_air.remove(moles)

	if(!removed_air)
		return //No air in distro

	tile.assume_air(removed_air)
	distro_pipe.update = TRUE

/obj/machinery/atmospherics/components/unary/airlock_pump/proc/siphon_tile(turf/tile)
	var/datum/pipeline/waste_pipe = parents[2]
	var/datum/gas_mixture/waste_air = airs[2]
	var/datum/gas_mixture/tile_air = tile.return_air()

	var/transfer_moles = tile_air.total_moles() * (volume_rate / tile_air.volume)
	var/datum/gas_mixture/removed_air = tile.remove_air(transfer_moles)

	if(!removed_air)
		return //No air on the tile

	waste_air.merge(removed_air)
	waste_pipe.update = TRUE

/// Proc for triggering cycle by clicking on a bolted airlock that has a pump assigned
/obj/machinery/atmospherics/components/unary/airlock_pump/proc/airlock_act(obj/machinery/door/airlock/airlock)
	if(on)
		airlock.do_animate("deny") // Already cycling
		return
	if(!cycling_set_up)
		airlock.say("Airlock pair not found.")
		return
	if(airlock == external_airlock)
		start_cycle(ATMOS_DIRECTION_SIPHONING)
	else if(airlock == internal_airlock)
		start_cycle(ATMOS_DIRECTION_RELEASING)

/obj/machinery/atmospherics/components/unary/airlock_pump/proc/start_cycle(cycle_direction)
	if(on || !cycling_set_up)
		return FALSE

	pump_direction = cycle_direction

	internal_airlock.secure_close()
	external_airlock.secure_close()

	if(pump_direction == ATMOS_DIRECTION_RELEASING)
		internal_airlock.say("Pressurizing airlock.")
	else
		external_airlock.say("Decompressing airlock.")

	on = TRUE
	cycle_start_time = world.time
	update_appearance()
	return TRUE

/obj/machinery/atmospherics/components/unary/airlock_pump/proc/stop_cycle(message = null)
	if(!on)
		return FALSE

	var/obj/machinery/door/airlock/unlocked_airlock = pump_direction == ATMOS_DIRECTION_RELEASING ? internal_airlock : external_airlock

	unlocked_airlock.unbolt()
	if(message)
		unlocked_airlock.say(message)

	on = FALSE
	update_appearance()
	return TRUE

/obj/machinery/atmospherics/components/unary/airlock_pump/proc/check_turfs()
	adjacent_turfs.Cut()
	var/turf/local_turf = get_turf(src)
	adjacent_turfs = local_turf.get_atmos_adjacent_turfs(alldir = TRUE)

/obj/machinery/atmospherics/components/unary/airlock_pump/proc/set_links()
	internal_airlock = find_airlock(dir)
	external_airlock = find_airlock(REVERSE_DIR(dir))

	if(internal_airlock && external_airlock)
		internal_airlock.set_cycle_pump(src)
		external_airlock.set_cycle_pump(src)
		external_airlock.secure_close()

		RegisterSignal(internal_airlock, COMSIG_QDELETING, PROC_REF(break_links))
		RegisterSignal(external_airlock, COMSIG_QDELETING, PROC_REF(break_links))

		cycling_set_up = TRUE
		say("Cycling setup complete.")
		return

	say("Cycling setup failed. No opposite airlocks found.")
	external_airlock = null
	internal_airlock = null

/obj/machinery/atmospherics/components/unary/airlock_pump/proc/break_links()
	UnregisterSignal(external_airlock, COMSIG_QDELETING)
	UnregisterSignal(internal_airlock, COMSIG_QDELETING)

	external_airlock = null
	internal_airlock = null
	cycling_set_up = FALSE

/obj/machinery/atmospherics/components/unary/airlock_pump/proc/find_airlock(direction)
	var/turf/next_turf = get_turf(src)
	var/limit = max(1, airlock_distance_limit)
	while(limit)
		limit--
		next_turf = get_step(next_turf, direction)
		var/obj/machinery/door/airlock/found_airlock = locate() in next_turf
		if (found_airlock && !found_airlock.cycle_pump)
			return found_airlock

/obj/machinery/atmospherics/components/unary/airlock_pump/relaymove(mob/living/user, direction)
	if(initialize_directions & direction)
		return ..()
	if((NORTH|EAST) & direction)
		user.ventcrawl_layer = clamp(user.ventcrawl_layer + 2, PIPING_LAYER_DEFAULT - 1, PIPING_LAYER_DEFAULT + 1)
	if((SOUTH|WEST) & direction)
		user.ventcrawl_layer = clamp(user.ventcrawl_layer - 2, PIPING_LAYER_DEFAULT - 1, PIPING_LAYER_DEFAULT + 1)
	to_chat(user, "You align yourself with the [user.ventcrawl_layer == 2 ? 1 : 2]\th output.")


/obj/machinery/atmospherics/components/unary/airlock_pump/any_airlock_type
	name = "airlock pump"
	desc = "A pump for cycling an airlock controlled by the connected doors."
	valid_airlock_typepath = /obj/machinery/door/airlock

/obj/machinery/atmospherics/components/unary/airlock_pump/lavaland
	external_pressure_target = LAVALAND_EQUIPMENT_EFFECT_PRESSURE
