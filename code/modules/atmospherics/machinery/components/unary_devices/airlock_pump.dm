/**
 * The pump looks up for the airlocks automatically based on airlock_pump_distance_limit and airlock_group_distance_limit values.
 * When placed, the dir value (direction where the pipes are coming from) is considered as a direction towards the station (internal). The opposite direction is external.
 * The airlock then tries to find airlocks or walls towards these directions until airlock_pump_distance_limit number of tiles reached.
 * When it finds a valid object, then it tries to find airlocks, in directions perpendicular to the found tiles.
 * And then adds them to the corresponding group (external/internal) until airlock_group_distance_limit number of tiles reached
 *
 * Example scheme of a valid configuration:
 * A-----W
 * A-----A
 * W--P--A
 * W-----W
 * A-----W
 *
 * Where:
 * A - airlocks
 * W - walls
 * P - pump
 */
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
	///Minimal distro pressure to start cycling
	var/min_distro_pressure = ONE_ATMOSPHERE / 10
	///Which pressure holds docked vessel\station for override of external_pressure_target
	var/docked_side_pressure
	///Rate of the pump to remove gases from the air
	var/volume_rate = 2000
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
	///Airlocks currently animating
	var/airlocks_animating = FALSE
	///Whether the airlocks comment the cycling details to the chat
	var/is_cycling_audible = TRUE

	COOLDOWN_DECLARE(check_turfs_cooldown)


/obj/machinery/atmospherics/components/unary/airlock_pump/update_icon_nopipes()
	if(!on || !is_operational || !powered())
		icon_state = "vent_off"
	else
		icon_state = pump_direction ? "vent_out" : "vent_in"


/obj/machinery/atmospherics/components/unary/airlock_pump/update_overlays()
	. = ..()
	if(!underfloor_state)
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
	update_appearance(UPDATE_ICON)


/obj/machinery/atmospherics/components/unary/airlock_pump/Initialize(mapload)
	. = ..()
	if(mapload)
		can_unwrench = FALSE


/obj/machinery/atmospherics/components/unary/airlock_pump/post_machine_initialize()
	. = ..()
	set_links()
	// If we are on docked shuttle - setup docking variables
	// Example - 'build your own shuttle' evac vessel
	var/turf/local_turf = get_turf(src)
	if (!cycling_set_up || !isshuttleturf(local_turf))
		return

	var/tile_air_pressure
	for(var/obj/machinery/door/airlock/external_airlock in external_airlocks)
		var/current_area = get_area(external_airlock)
		for(var/obj/machinery/door/airlock/other_airlock in orange(2, external_airlock))  // does not include src, extended because some escape pods have 1 plating turf exposed to space
			if(get_area(other_airlock) != current_area)  // does not include double-wide airlocks unless actually docked
				// Cycle linking is only disabled if we are actually adjacent to another airlock
				external_airlock.shuttledocked = TRUE
				other_airlock.shuttledocked = TRUE
				if (other_airlock.cycle_pump)
					INVOKE_ASYNC(other_airlock.cycle_pump, TYPE_PROC_REF(/obj/machinery/atmospherics/components/unary/airlock_pump, on_dock_request), internal_pressure_target) // Only case when airlock pumps speaking to each other directly
				// Save external airlocks turf in case our own docking purpouses
				local_turf = get_turf(other_airlock)

	if (local_turf)
		local_turf = get_step(local_turf, REVERSE_DIR(dir))
		tile_air_pressure = 0
		if (local_turf)
			tile_air_pressure = max(0, local_turf.return_air().return_pressure())
		on_dock_request(tile_air_pressure)

/obj/machinery/atmospherics/components/unary/airlock_pump/Initialize(mapload)
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
		stop_cycle("No power. Cycle aborted.", unbolt_only = TRUE)
		return //Couldn't complete the cycle due to power outage

	var/turf/location = get_turf(loc)
	if(isclosedturf(location))
		return

	if(COOLDOWN_FINISHED(src, check_turfs_cooldown))
		check_turfs()
		COOLDOWN_START(src, check_turfs_cooldown, 2 SECONDS)

	if(world.time - cycle_start_time > cycle_timeout)
		stop_cycle("Cycling timed out, bolts unlocked.", unbolt_only = TRUE)
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
		for(var/turf/tile as anything in adjacent_turfs)
			fill_tile(tile, split_moles, pressure_delta)
	else //tile -> waste node
		var/pressure_delta = tile_air_pressure - cycle_pressure_target
		if(pressure_delta <= allowed_pressure_error && stop_cycle("Decompression complete."))
			return //External target pressure reached

		siphon_tile(loc)
		for(var/turf/tile as anything in adjacent_turfs)
			siphon_tile(tile)


/// Fill a tile with air from the distro node
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


/// Siphon air from the tile to the waste node within the volume rate limit
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
		airlock.run_animation(DOOR_DENY_ANIMATION) // Already cycling
		return
	if(!cycling_set_up)
		airlock.say("Airlock pair not found.")
		return
	if(airlock in external_airlocks)
		// If it's not null - we shuttledocked
		// (it may be 0. Maybe badmin set internal pressure to 0 as well, who knows)
		if(docked_side_pressure != null)
			// Space-faced airlock detection
			var/turf/external_tile = get_step(airlock, REVERSE_DIR(dir))
			// Map edge or space turf
			if (external_tile == null || is_space_or_openspace(external_tile))
				airlock.run_animation(DOOR_DENY_ANIMATION)
				return
			var/tile_air_pressure = max(0, external_tile.return_air().return_pressure())
			var/pressure_delta = docked_side_pressure - tile_air_pressure
			if (pressure_delta > 0 ? (pressure_delta > allowed_pressure_error*10) : (pressure_delta*-1 > allowed_pressure_error*10))
				// Disabled to avoid airlocks close-open spam
				airlock.run_animation(DOOR_DENY_ANIMATION)
				return

		start_cycle(ATMOS_DIRECTION_SIPHONING, airlock)
	else if(airlock in internal_airlocks)
		start_cycle(ATMOS_DIRECTION_RELEASING, airlock)


///Start decompression or pressurization cycle depending on the passed direction
/obj/machinery/atmospherics/components/unary/airlock_pump/proc/start_cycle(cycle_direction, obj/machinery/door/airlock/source_airlock = null)
	if(on || !cycling_set_up || airlocks_animating || !powered())
		return FALSE

	pump_direction = cycle_direction

	for(var/obj/machinery/door/airlock/airlock as anything in (internal_airlocks + external_airlocks))
		INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door/airlock, secure_close))

	airlocks_animating = TRUE
	stoplag(1 SECONDS) // Wait for closing animation
	airlocks_animating = FALSE

	set_on(TRUE)
	cycle_start_time = world.time

	var/turf/local_turf = get_turf(src)
	var/tile_air_pressure = max(0, local_turf.return_air().return_pressure())

	if(pump_direction == ATMOS_DIRECTION_RELEASING)
		cycle_pressure_target = internal_pressure_target
		var/pressure_delta = cycle_pressure_target - tile_air_pressure
		if(pressure_delta <= allowed_pressure_error)
			stop_cycle("Pressure nominal, cycle skipped.")
			return TRUE

		var/datum/gas_mixture/distro_air = airs[1]
		if(distro_air.return_pressure() < min_distro_pressure)
			stop_cycle("Low pipe pressure, cycle skipped. Proceed with caution.", unbolt_only = TRUE)
			return TRUE

		if(!source_airlock)
			source_airlock = internal_airlocks[1]
		if(is_cycling_audible)
			source_airlock.say("Pressurizing airlock.")
	else
		cycle_pressure_target = docked_side_pressure != null ? docked_side_pressure : external_pressure_target
		var/pressure_delta = tile_air_pressure - cycle_pressure_target
		if(pressure_delta <= allowed_pressure_error)
			stop_cycle("Pressure nominal, cycle skipped.")
			return TRUE

		if(!source_airlock)
			source_airlock = external_airlocks[1]
		if(is_cycling_audible)
			source_airlock.say("Decompressing airlock.")

	return TRUE


///Complete/Abort cycle with the passed message
/obj/machinery/atmospherics/components/unary/airlock_pump/proc/stop_cycle(message = null, unbolt_only = FALSE)
	if(!on)
		return FALSE
	set_on(FALSE)

	// In case we can open both sides safe_dock will do it for us
	// it also handles its own messages. If we can't - procceed
	if (docked_side_pressure != null && safe_dock(unbolt_only))
		return TRUE

	var/list/obj/machinery/door/airlock/unlocked_airlocks = pump_direction == ATMOS_DIRECTION_RELEASING ? internal_airlocks : external_airlocks
	for(var/obj/machinery/door/airlock/airlock as anything in unlocked_airlocks)
		airlock.unbolt()
		if(open_airlock_on_cycle && !unbolt_only)
			INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door/airlock, secure_open)) //Can unbolt, but without audio

	airlocks_animating = TRUE
	stoplag(1 SECONDS) // Wait for opening animation
	airlocks_animating = FALSE

	if(message && is_cycling_audible)
		unlocked_airlocks[1].say(message)

	update_appearance(UPDATE_ICON)
	return TRUE

/obj/machinery/atmospherics/components/unary/airlock_pump/proc/on_dock_request(requester_pressure = 0)
	if (docked_side_pressure != null)
		return

	docked_side_pressure = requester_pressure

	if (!powered() || !cycling_set_up)
		return

	// We just finishing previous cycle
	if (airlocks_animating)
		say("Docking request queued.")
		stoplag(1.1 SECONDS) // Wait for opening animation
		if (airlocks_animating)	// Should (almost) never happened
			say("ERROR: D11. Please re-initiate docking sequence.")
			return

	if (on)
		// You can't go there, there is a shuttle now
		if (pump_direction == ATMOS_DIRECTION_SIPHONING)
			stop_cycle("Cycling sequence overriden by docking sequence.", TRUE)
			start_cycle(ATMOS_DIRECTION_RELEASING)
		// If cycling inside, docking will be handled by stop_cycle proc
		return

	// Check if we need cycle in
	var/turf/local_turf = get_turf(src)
	var/tile_air_pressure = max(0, local_turf.return_air().return_pressure())
	var/pressure_delta = internal_pressure_target - tile_air_pressure
	if(pressure_delta <= allowed_pressure_error)
		// We fine
		safe_dock()
	else
		var/obj/machinery/door/airlock/source_airlock = pick(internal_airlocks)
		source_airlock.say("Docking sequence initiated")
		start_cycle(ATMOS_DIRECTION_RELEASING)


/obj/machinery/atmospherics/components/unary/airlock_pump/proc/safe_dock(unbolt_only = FALSE)
	var/pressure_delta = internal_pressure_target - docked_side_pressure
	// Docked vessel has pressure higher then our internal
	if ((pressure_delta + allowed_pressure_error) < 0)
		return FALSE
	// Pressure is too different, its unsafe to open both sides
	else if (pressure_delta > allowed_pressure_error * 10)
		return FALSE
	// No power handles by stop_cycle pretty good
	else if (!powered())
		return FALSE

	var/turf/local_turf = get_turf(src)
	var/tile_air_pressure = max(0, local_turf.return_air().return_pressure())
	pressure_delta = internal_pressure_target - tile_air_pressure
	// Chamber is not pressurised
	if(pressure_delta > allowed_pressure_error)
		return FALSE

	for(var/obj/machinery/door/airlock/airlock as anything in (external_airlocks + internal_airlocks))
		if (airlock in external_airlocks)
			airlock.air_tight = TRUE
			local_turf = get_step(airlock, REVERSE_DIR(dir))
			// Map edge or space turf
			if (local_turf == null || is_space_or_openspace(local_turf))
				continue

			tile_air_pressure = max(0, local_turf.return_air().return_pressure())
			pressure_delta = docked_side_pressure - tile_air_pressure
			// Do not open airlocks leading in space
			// If docked entity now has pressure lower or higher then was declared on docking
			// We will keep airlocks closed until redocking or fixing atmos
			if (pressure_delta > 0 ? (pressure_delta > allowed_pressure_error*10) : (pressure_delta*-1 > allowed_pressure_error*10))
				continue

		airlock.unbolt()
		if(open_airlock_on_cycle && !unbolt_only)
			INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door/airlock, secure_open))

	airlocks_animating = TRUE
	stoplag(1 SECONDS) // Wait for closing animation
	airlocks_animating = FALSE
	update_appearance(UPDATE_ICON)
	say("Docking complete.")
	return TRUE


/obj/machinery/atmospherics/components/unary/airlock_pump/proc/undock()
	if (docked_side_pressure == null)
		return
	docked_side_pressure = null
	if(!powered())
		return

	for(var/obj/machinery/door/airlock/airlock as anything in external_airlocks)
		INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door/airlock, secure_close), TRUE)

	say("Docking connection terminated.")
	airlocks_animating = TRUE
	stoplag(1 SECONDS) // Wait for closing animation
	airlocks_animating = FALSE


///Update adjacent_turfs with atmospherically adjacent tiles
/obj/machinery/atmospherics/components/unary/airlock_pump/proc/check_turfs()
	adjacent_turfs.Cut()
	var/turf/local_turf = get_turf(src)
	adjacent_turfs = local_turf.get_atmos_adjacent_turfs(alldir = TRUE)


///Find airlocks and link up with them
/obj/machinery/atmospherics/components/unary/airlock_pump/proc/set_links()
	var/perpendicular_dirs = NSCOMPONENT(dir) ? WEST|EAST : NORTH|SOUTH
	var/turf/internal_airlocks_origin = find_density(get_turf(src), dir)
	var/turf/external_airlocks_origin = find_density(get_turf(src), REVERSE_DIR(dir))
	internal_airlocks = get_adjacent_airlocks(internal_airlocks_origin, perpendicular_dirs)
	external_airlocks = get_adjacent_airlocks(external_airlocks_origin, perpendicular_dirs)

	// This is support for awkwardly shaped airlocks that cycle on a group ID
	if(!length(internal_airlocks))
		for(var/obj/machinery/door/airlock/external_airlock as anything in external_airlocks)
			internal_airlocks |= external_airlock.close_others
		// For double-wide airlocks, so we don't end up with doors in both lists
		internal_airlocks -= external_airlocks
	if(!length(external_airlocks))
		for(var/obj/machinery/door/airlock/internal_airlock as anything in internal_airlocks)
			external_airlocks |= internal_airlock.close_others
		external_airlocks -= internal_airlocks

	if(!length(external_airlocks) || !length(internal_airlocks))
		if(!can_unwrench) //maploaded pump
			CRASH("[type] couldn't find airlocks to cycle with!")
		internal_airlocks.Cut()
		external_airlocks.Cut()
		say("Cycling setup failed. No opposite airlocks found.")
		return

	for(var/obj/machinery/door/airlock/airlock as anything in (internal_airlocks + external_airlocks))
		airlock.set_cycle_pump(src)
		RegisterSignal(airlock, COMSIG_QDELETING, PROC_REF(unlink_airlock))
		if (airlock in external_airlocks)
			INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door/airlock, secure_close))
		else if(open_airlock_on_cycle)
			INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door/airlock, secure_open))

	cycle_timeout *= round((internal_airlocks.len + external_airlocks.len) / 2)
	cycling_set_up = TRUE
	if(can_unwrench)
		say("Cycling setup complete.")


///Get the turf of the first found airlock or an airtight structure (walls) within the allowed range
/obj/machinery/atmospherics/components/unary/airlock_pump/proc/find_density(turf/origin, direction, max_distance = airlock_pump_distance_limit)
	var/turf/next_turf = origin
	var/limit = max(1, max_distance)
	while(limit)
		limit--
		next_turf = get_step(next_turf, direction)
		var/obj/machinery/door/airlock/found_airlock = locate() in next_turf
		if(is_valid_airlock(found_airlock))
			return found_airlock.loc
		if(!next_turf.can_atmos_pass)
			return next_turf


///Find airlocks adjacent to the central one, lined up along the provided directions
/obj/machinery/atmospherics/components/unary/airlock_pump/proc/get_adjacent_airlocks(origin_turf, directions)
	var/list/airlocks = list()

	var/obj/machinery/door/airlock/origin_airlock = locate() in origin_turf
	if(is_valid_airlock(origin_airlock))
		airlocks.Add(origin_airlock)

	for(var/direction in GLOB.cardinals)
		if(!(direction & directions))
			continue
		var/turf/next_turf = origin_turf
		var/limit = max(0, airlock_group_distance_limit)
		while(limit)
			limit--
			next_turf = get_step(next_turf, direction)
			var/obj/machinery/door/airlock/found_airlock = locate() in next_turf
			if (is_valid_airlock(found_airlock))
				airlocks.Add(found_airlock)
			else
				limit = 0

	return airlocks


///Whether the passed airlock can be linked with
/obj/machinery/atmospherics/components/unary/airlock_pump/proc/is_valid_airlock(obj/machinery/door/airlock/airlock)
	if(!airlock)
		return FALSE
	if(airlock.cycle_pump)
		return FALSE // Already linked
	if(can_unwrench && !istype(airlock, valid_airlock_typepath))
		return FALSE // Invalid airlock type and the pump is not mapspawn
	return TRUE


///Find airlocks and link up with them
/obj/machinery/atmospherics/components/unary/airlock_pump/proc/unlink_airlock(airlock)
	UnregisterSignal(airlock, COMSIG_QDELETING)

	if(airlock in internal_airlocks)
		internal_airlocks.Remove(airlock)
	if(airlock in external_airlocks)
		external_airlocks.Remove(airlock)

	if(!internal_airlocks.len || !external_airlocks.len)
		break_all_links()


///Break the cycling setup
/obj/machinery/atmospherics/components/unary/airlock_pump/proc/break_all_links()
	for(var/obj/machinery/door/airlock/airlock as anything in (internal_airlocks + external_airlocks))
		UnregisterSignal(airlock, COMSIG_QDELETING)

	external_airlocks = list()
	internal_airlocks = list()
	cycle_timeout = initial(cycle_timeout)
	cycling_set_up = FALSE

/obj/machinery/atmospherics/components/unary/airlock_pump/relaymove(mob/living/user, direction)
	if(initialize_directions & direction)
		return ..()
	if((NORTH|EAST) & direction)
		user.ventcrawl_layer = clamp(user.ventcrawl_layer + 2, PIPING_LAYER_DEFAULT - 1, PIPING_LAYER_DEFAULT + 1)
	if((SOUTH|WEST) & direction)
		user.ventcrawl_layer = clamp(user.ventcrawl_layer - 2, PIPING_LAYER_DEFAULT - 1, PIPING_LAYER_DEFAULT + 1)
	to_chat(user, "You align yourself with the [user.ventcrawl_layer == 2 ? 1 : 2]\th output.")

/obj/machinery/atmospherics/components/unary/airlock_pump/on_set_is_operational(was_operational)
	if(was_operational && !is_operational)
		// unbolt all the doors but don't open them
		for(var/obj/machinery/door/airlock/airlock as anything in (internal_airlocks + external_airlocks))
			airlock.unbolt()
		audible_message(span_notice("[src] whirrs as [p_they()] loses power, disengaging airlock bolts."))
	else if(!was_operational && is_operational)
		// upon regaining power, re-bolt relevant airlocks
		for(var/obj/machinery/door/airlock/airlock as anything in external_airlocks)
			INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door/airlock, secure_close))
		for(var/obj/machinery/door/airlock/airlock as anything in internal_airlocks)
			if(open_airlock_on_cycle)
				INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door/airlock, secure_open))
		audible_message(span_notice("[src] whirrs as [p_they()] regains power, re-engaging airlock bolts."))

/obj/machinery/atmospherics/components/unary/airlock_pump/unbolt_only
	open_airlock_on_cycle = FALSE

/obj/machinery/atmospherics/components/unary/airlock_pump/silent
	is_cycling_audible = FALSE

/obj/machinery/atmospherics/components/unary/airlock_pump/lavaland
	external_pressure_target = LAVALAND_EQUIPMENT_EFFECT_PRESSURE
