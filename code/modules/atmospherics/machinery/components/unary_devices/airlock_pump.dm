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
	var/volume_rate = 200
	///is this pump acting on the 3x3 area around it.
	var/widenet = TRUE
	///List of the turfs near the pump, used for widenet
	var/list/turf/adjacent_turfs = list()

/obj/machinery/atmospherics/components/unary/airlock_pump/update_icon_nopipes()
	cut_overlays()

	if(showpipe)
		var/image/cap_distro = get_pipe_image(icon, "vent_cap", dir, COLOR_BLUE, piping_layer = 4)
		var/image/cap_waste = get_pipe_image(icon, "vent_cap", dir, COLOR_RED, piping_layer = 2)
		add_overlay(cap_distro)
		add_overlay(cap_waste)

	if(!on || !is_operational)
		icon_state = "vent_off"
	else
		icon_state = pump_direction ? "vent_out" : "vent_in"

/obj/machinery/atmospherics/components/unary/airlock_pump/update_icon()
	underlays.Cut()
	if(!showpipe)
		return ..()
	if(nodes[1])
		var/mutable_appearance/pipe_appearance = mutable_appearance('icons/obj/pipes_n_cables/pipe_underlays.dmi', "intact_[dir]_[4]")
		pipe_appearance.color = COLOR_BLUE
		underlays += pipe_appearance
	if(nodes[2])
		var/mutable_appearance/pipe_appearance = mutable_appearance('icons/obj/pipes_n_cables/pipe_underlays.dmi', "intact_[dir]_[2]")
		pipe_appearance.color = COLOR_RED
		underlays += pipe_appearance
	return ..()

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

	var/datum/gas_mixture/distro_air = airs[1]
	var/datum/gas_mixture/waste_air = airs[2]
	var/datum/pipeline/distro_pipe = parents[1]
	var/datum/pipeline/waste_pipe = parents[2]
	var/datum/gas_mixture/tile_air = loc.return_air()
	var/tile_air_pressure = tile_air.return_pressure()

	if(pump_direction == ATMOS_DIRECTION_RELEASING) //distro node -> tile
		var/pressure_delta = target_pressure - tile_air_pressure

		if(pressure_delta <= target_pressure_error)
			on = FALSE
			pump_direction = !pump_direction
			say("Pressurization complete.")
			update_appearance()
			return //Target pressure reached

		var/transfer_moles = (pressure_delta * tile_air.volume) / (distro_air.temperature * R_IDEAL_GAS_EQUATION)
		var/datum/gas_mixture/removed_air = distro_air.remove(transfer_moles)

		if(!removed_air)
			return //No air in distro

		loc.assume_air(removed_air)
		distro_pipe.update = TRUE

	else //tile -> waste node
		var/pressure_delta = tile_air_pressure

		if(pressure_delta <= target_pressure_error)
			on = FALSE
			pump_direction = !pump_direction
			say("Depressurization complete.")
			update_appearance()
			return //Target pressure reached

		var/removal_ratio =  min(1, volume_rate / tile_air.volume)
		var/transfer_moles = (pressure_delta * tile_air.volume) / (tile_air.temperature * R_IDEAL_GAS_EQUATION)
		var/datum/gas_mixture/removed_air = loc.remove_air(transfer_moles)

		if(!removed_air)
			return //No air on the tile

		waste_air.merge(removed_air)
		waste_pipe.update = TRUE

/obj/machinery/atmospherics/components/unary/airlock_pump/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!on)
		on = TRUE
		say(pump_direction ? "Pressurizing." : "Depressurizing.")
		update_appearance()
