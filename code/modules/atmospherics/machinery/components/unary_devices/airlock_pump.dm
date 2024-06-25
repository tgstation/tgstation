/// A vent, scrubber and a sensor in a single device meant specifically for cycling airlocks
/obj/machinery/atmospherics/components/unary/airlock_pump
	name = "airlock pump"
	desc = "A pump for cycling airlock that vents, siphons the air and controls the connected airlocks. Can be configured with a multitool."
	icon = 'icons/obj/machines/atmospherics/unary_devices.dmi'
	icon_state = "airlock_pump"
	pipe_state = "airlock_pump"
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.15
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
	var/pump_direction = ATMOS_DIRECTION_RELEASING
	///Set pressure target during pressurization cycle
	var/target_pressure = ONE_ATMOSPHERE
	///Allowed error in pressure checks
	var/target_pressure_error = ONE_ATMOSPHERE / 100
	///Rate of the pump to remove gases from the air
	var/volume_rate = 1000
	///The start time of the current cycle to calculate cycle duration
	var/cycle_start_time
	///Max duration of cycle, after which the pump will unlock the airlocks with a warning
	var/cycle_timeout = 10 SECONDS
	///List of the turfs adjacent to the pump for faster cycling and avoiding wind
	var/list/turf/adjacent_turfs = list()

	COOLDOWN_DECLARE(check_turfs_cooldown)

/obj/machinery/atmospherics/components/unary/airlock_pump/update_icon_nopipes()
	if(!on || !is_operational)
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

/obj/machinery/atmospherics/components/unary/airlock_pump/atmos_init()
	nodes = list()
	var/obj/machinery/atmospherics/node_distro = find_connecting(dir, 4)
	var/obj/machinery/atmospherics/node_waste = find_connecting(dir, 2)
	if(node_distro && !QDELETED(node_distro))
		nodes += node_distro
	if(node_waste && !QDELETED(node_waste))
		nodes += node_waste
	update_appearance()

/obj/machinery/atmospherics/components/unary/airlock_pump/New()
	. = ..()
	var/datum/gas_mixture/distro_air = airs[1]
	var/datum/gas_mixture/waste_air = airs[2]
	distro_air.volume = 1000
	waste_air.volume = 1000

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
		say("Cycling timed out!")
		stop_cycle()
		return //Couldn't complete the cycle before timeout

	var/datum/gas_mixture/distro_air = airs[1]
	var/datum/gas_mixture/tile_air = loc.return_air()
	var/tile_air_pressure = tile_air.return_pressure()

	if(pump_direction == ATMOS_DIRECTION_RELEASING) //distro node -> tile
		var/pressure_delta = target_pressure - tile_air_pressure

		if(pressure_delta <= target_pressure_error && stop_cycle())
			say("Pressurization complete.")
			return //Target pressure reached

		var/available_moles = distro_air.total_moles()
		var/total_tiles = adjacent_turfs.len + 1
		var/split_moles = QUANTIZE(available_moles / total_tiles)

		fill_tile(loc, split_moles, pressure_delta)
		for(var/turf/tile in adjacent_turfs)
			fill_tile(tile, split_moles, pressure_delta)
	else //tile -> waste node
		var/pressure_delta = tile_air_pressure

		if(pressure_delta <= target_pressure_error && stop_cycle())
			say("Depressurization complete.")
			return //Target pressure reached

		siphon_tile(loc)
		for(var/turf/tile in adjacent_turfs)
			siphon_tile(tile)

/obj/machinery/atmospherics/components/unary/airlock_pump/proc/fill_tile(turf/tile, moles, pressure_delta)
	var/datum/pipeline/distro_pipe = parents[1]
	var/datum/gas_mixture/distro_air = airs[1]
	var/datum/gas_mixture/tile_air = tile.return_air()
	var/transfer_moles = (pressure_delta * tile_air.volume) / (distro_air.temperature * R_IDEAL_GAS_EQUATION)
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

/obj/machinery/atmospherics/components/unary/airlock_pump/proc/start_cycle()
	if(on)
		return FALSE
	on = TRUE
	cycle_start_time = world.time
	say(pump_direction ? "Pressurizing." : "Depressurizing.")
	update_appearance()
	return TRUE

/obj/machinery/atmospherics/components/unary/airlock_pump/proc/stop_cycle()
	if(!on)
		return FALSE
	on = FALSE
	pump_direction = !pump_direction
	update_appearance()
	return TRUE

/obj/machinery/atmospherics/components/unary/airlock_pump/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	start_cycle()

/obj/machinery/atmospherics/components/unary/airlock_pump/proc/check_turfs()
	adjacent_turfs.Cut()
	var/turf/local_turf = get_turf(src)
	adjacent_turfs = local_turf.get_atmos_adjacent_turfs(alldir = TRUE)

