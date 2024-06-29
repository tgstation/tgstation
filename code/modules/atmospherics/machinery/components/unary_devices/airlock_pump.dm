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
	///Target pressure for the current cycle
	var/cycle_pressure_target
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
	var/airlock_pump_distance_limit = 2
	///Max distance between the central airlock and the side airlocks in a group
	var/airlock_group_distance_limit = 2
	///Type of airlocks required for automatic cycling setup. To avoid hacking bridge doors. Ignored for mapspawn pump.
	var/valid_airlock_typepath = /obj/machinery/door/airlock/external
	///Station-facing airlocks used in cycling
	var/list/obj/machinery/door/airlock/internal_airlocks
	///Space-facing airlocks used in cycling
	var/list/obj/machinery/door/airlock/external_airlocks
	///Whether both airlocks are specified and cycling is available
	var/cycling_set_up = FALSE
	///Whether the pump opens the airlocks up instead of simpy unbolting them on cycle
	var/open_airlock_on_cycle = TRUE

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

	var/mutable_appearance/distro_pipe_appearance = get_pipe_image(icon, "pipe_exposed", dir, COLOR_BLUE, piping_layer = 4)
	if(nodes[1])
		distro_pipe_appearance = get_pipe_image(icon, "pipe_intact", dir, COLOR_BLUE, piping_layer = 4)
	. += distro_pipe_appearance

	var/mutable_appearance/waste_pipe_appearance = get_pipe_image(icon, "pipe_exposed", dir, COLOR_RED, piping_layer = 2)
	if(nodes[2])
		waste_pipe_appearance = get_pipe_image(icon, "pipe_intact", dir, COLOR_RED, piping_layer = 2)
	. += waste_pipe_appearance

	var/mutable_appearance/distro_cap_appearance = get_pipe_image(icon, "vent_cap", dir, piping_layer = 4)
	. += distro_cap_appearance

	var/mutable_appearance/waste_cap_appearance = get_pipe_image(icon, "vent_cap", dir, piping_layer = 2)
	. += waste_cap_appearance


/obj/machinery/atmospherics/components/unary/airlock_pump/atmos_init(list/node_connects)
	for(var/obj/machinery/atmospherics/target in get_step(src, dir))
		if(connection_check(target, 4) && !nodes[1])
			nodes[1] = target // Distro
		if(connection_check(target, 2) && !nodes[2])
			nodes[2] = target // Waste
	update_appearance()


/obj/machinery/atmospherics/components/unary/airlock_pump/Initialize(mapload)
	. = ..()
	if(mapload)
		can_unwrench = FALSE


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
		break_all_links()


/obj/machinery/atmospherics/components/unary/airlock_pump/can_unwrench(mob/user)
	. = ..()
	if(!.)
		to_chat(user, span_warning("You cannot unwrench [src], it is secured firmly in place!"))
		return FALSE
	if(. && on)
		to_chat(user, span_warning("You cannot unwrench [src], wait for the cycle completion!"))
		return FALSE


/obj/machinery/atmospherics/components/unary/airlock_pump/process_atmos()
	if(!on)
		return

	if(!powered())
		stop_cycle("No power. Aborting cycle.")
		return //Couldn't complete the cycle due to power outage

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
		var/pressure_delta = cycle_pressure_target - tile_air_pressure
		if(pressure_delta <= allowed_pressure_error && stop_cycle("Pressurization complete."))
			return //Internal target pressure reached

		var/available_moles = distro_air.total_moles()
		var/total_tiles = adjacent_turfs.len + 1
		var/split_moles = QUANTIZE(available_moles / total_tiles)

		fill_tile(loc, split_moles, pressure_delta)
		for(var/turf/tile in adjacent_turfs)
			fill_tile(tile, split_moles, pressure_delta)
	else //tile -> waste node
		var/pressure_delta = tile_air_pressure - cycle_pressure_target
		if(pressure_delta <= allowed_pressure_error && stop_cycle("Decompression complete."))
			return //External target pressure reached

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
	if(airlock in external_airlocks)
		start_cycle(ATMOS_DIRECTION_SIPHONING)
	else if(airlock in internal_airlocks)
		start_cycle(ATMOS_DIRECTION_RELEASING)


/obj/machinery/atmospherics/components/unary/airlock_pump/proc/start_cycle(cycle_direction)
	if(on || !cycling_set_up || !powered())
		return FALSE

	pump_direction = cycle_direction

	for(var/obj/machinery/door/airlock/airlock in (internal_airlocks + external_airlocks))
		INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door/airlock, secure_close))

	stoplag(0.2 SECONDS) // Wait for closing animation

	on = TRUE
	cycle_start_time = world.time
	update_appearance()

	if(pump_direction == ATMOS_DIRECTION_RELEASING)
		cycle_pressure_target = internal_pressure_target
		internal_airlocks[1].say("Pressurizing airlock.")
	else
		for(var/obj/machinery/door/airlock/airlock in external_airlocks)
			if(airlock.shuttledocked)
				stop_cycle("Shuttle docked, skipping cycle.")
				return TRUE
		cycle_pressure_target = external_pressure_target
		external_airlocks[1].say("Decompressing airlock.")

	return TRUE


/obj/machinery/atmospherics/components/unary/airlock_pump/proc/stop_cycle(message = null)
	if(!on)
		return FALSE
	on = FALSE

	var/list/obj/machinery/door/airlock/unlocked_airlocks = pump_direction == ATMOS_DIRECTION_RELEASING ? internal_airlocks : external_airlocks
	for(var/obj/machinery/door/airlock/airlock in unlocked_airlocks)
		airlock.unbolt()
		if(open_airlock_on_cycle)
			INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door/airlock, secure_open)) //Can unbolt, but without audio

	stoplag(0.2 SECONDS) // Wait for opening animation

	if(message)
		unlocked_airlocks[1].say(message)

	update_appearance()
	return TRUE


///Update adjacent_turfs with atmospherically adjacent tiles
/obj/machinery/atmospherics/components/unary/airlock_pump/proc/check_turfs()
	adjacent_turfs.Cut()
	var/turf/local_turf = get_turf(src)
	adjacent_turfs = local_turf.get_atmos_adjacent_turfs(alldir = TRUE)


///Find airlocks and link up with them
/obj/machinery/atmospherics/components/unary/airlock_pump/proc/set_links()
	var/obj/machinery/door/airlock/internal_airlock = find_airlock(get_turf(src), dir)
	var/obj/machinery/door/airlock/external_airlock = find_airlock(get_turf(src), REVERSE_DIR(dir))

	if(!internal_airlock || !external_airlock)
		if(!can_unwrench) //maploaded pump
			CRASH("[type] called couldn't find airlocks to cycle with!")
		external_airlock = null
		internal_airlock = null
		say("Cycling setup failed. No opposite airlocks found.")
		return

	var/perpendicular_dirs = NSCOMPONENT(dir) ? WEST|EAST : NORTH|SOUTH
	internal_airlocks = get_adjacent_airlocks(internal_airlock, perpendicular_dirs)
	external_airlocks = get_adjacent_airlocks(external_airlock, perpendicular_dirs)

	for(var/obj/machinery/door/airlock/airlock in (internal_airlocks + external_airlocks))
		airlock.set_cycle_pump(src)
		RegisterSignal(airlock, COMSIG_QDELETING, PROC_REF(unlink_airlock))
		if (airlock in external_airlocks)
			INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door/airlock, secure_close))
		else if(open_airlock_on_cycle)
			INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door/airlock, secure_open))

	cycling_set_up = TRUE
	if(can_unwrench)
		say("Cycling setup complete.")


///Find the first airlock within the allowed range
/obj/machinery/atmospherics/components/unary/airlock_pump/proc/find_airlock(turf/origin, direction, max_distance = airlock_pump_distance_limit)
	var/turf/next_turf = origin
	var/limit = max(1, max_distance)
	while(limit)
		limit--
		next_turf = get_step(next_turf, direction)
		var/obj/machinery/door/airlock/found_airlock = locate() in next_turf
		if (found_airlock && !found_airlock.cycle_pump && (!can_unwrench || istype(found_airlock, valid_airlock_typepath)))
			return found_airlock


///Find airlocks adjacent to the central one, lined up along the provided directions
/obj/machinery/atmospherics/components/unary/airlock_pump/proc/get_adjacent_airlocks(central_airlock, directions)
	var/list/airlocks = list(central_airlock)

	for(var/direction in GLOB.cardinals)
		if(!(direction & directions))
			continue
		var/turf/next_turf = get_turf(central_airlock)
		var/limit = max(0, airlock_group_distance_limit)
		while(limit)
			limit--
			next_turf = get_step(next_turf, direction)
			var/obj/machinery/door/airlock/found_airlock = locate() in next_turf
			if (found_airlock && !found_airlock.cycle_pump)
				airlocks.Add(found_airlock)
			else
				limit = 0

	return airlocks


///Find airlocks and link up with them
/obj/machinery/atmospherics/components/unary/airlock_pump/proc/unlink_airlock(airlock)
	UnregisterSignal(airlock, COMSIG_QDELETING)

	if(airlock in internal_airlocks)
		internal_airlocks.Remove(airlock)
	if(airlock in external_airlocks)
		external_airlocks.Remove(airlock)

	if(!internal_airlocks.len || !external_airlocks.len)
		break_all_links()


/obj/machinery/atmospherics/components/unary/airlock_pump/proc/break_all_links()
	for(var/obj/machinery/door/airlock/airlock in (internal_airlocks + external_airlocks))
		UnregisterSignal(airlock, COMSIG_QDELETING)

	external_airlocks = list()
	internal_airlocks = list()
	cycling_set_up = FALSE


/obj/machinery/atmospherics/components/unary/airlock_pump/relaymove(mob/living/user, direction)
	if(initialize_directions & direction)
		return ..()
	if((NORTH|EAST) & direction)
		user.ventcrawl_layer = clamp(user.ventcrawl_layer + 2, PIPING_LAYER_DEFAULT - 1, PIPING_LAYER_DEFAULT + 1)
	if((SOUTH|WEST) & direction)
		user.ventcrawl_layer = clamp(user.ventcrawl_layer - 2, PIPING_LAYER_DEFAULT - 1, PIPING_LAYER_DEFAULT + 1)
	to_chat(user, "You align yourself with the [user.ventcrawl_layer == 2 ? 1 : 2]\th output.")


/obj/machinery/atmospherics/components/unary/airlock_pump/lavaland
	external_pressure_target = LAVALAND_EQUIPMENT_EFFECT_PRESSURE

