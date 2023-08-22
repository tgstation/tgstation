///Mech air tank module
/obj/item/mecha_parts/mecha_equipment/air_tank
	name = "mounted air tank"
	desc = "An internal air tank used to pressurize mech cabin, scrub CO2 and power RCS thrusters. Comes with a pump and a set of sensors."
	icon_state = "mecha_air_tank"
	equipment_slot = MECHA_UTILITY
	can_be_toggled = TRUE
	///Whether the pressurization should start automatically when the cabin is sealed airtight
	var/auto_pressurize_on_seal = TRUE
	///The internal air tank obj of the mech
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	///Volume of this air tank
	var/volume = TANK_STANDARD_VOLUME * 10
	///Maximum pressure of this air tank
	var/maximum_pressure = ONE_ATMOSPHERE * 30
	///Whether the tank starts pressurized
	var/start_full = FALSE
	///Pumping
	///The connected air port, if we have one
	var/obj/machinery/atmospherics/components/unary/portables_connector/connected_port
	///Whether the pump is moving the air from/to the connected port
	var/tank_pump_active = FALSE
	///Direction of the pump - into the tank from the port or the air (PUMP_IN) or from the tank (PUMP_OUT)
	var/tank_pump_direction = PUMP_IN
	///Target pressure of the pump
	var/tank_pump_pressure = ONE_ATMOSPHERE

/obj/item/mecha_parts/mecha_equipment/air_tank/Initialize(mapload)
	. = ..()
	internal_tank = new(src)
	internal_tank.air_contents.volume = volume
	internal_tank.maximum_pressure = maximum_pressure
	if(start_full)
		internal_tank.air_contents.temperature = T20C
		internal_tank.air_contents.add_gases(/datum/gas/oxygen)
		internal_tank.air_contents.gases[/datum/gas/oxygen][MOLES] = maximum_pressure * volume / (R_IDEAL_GAS_EQUATION * internal_tank.air_contents.temperature)

/obj/item/mecha_parts/mecha_equipment/air_tank/Destroy()
	if(chassis)
		UnregisterSignal(chassis, COMSIG_MOVABLE_PRE_MOVE)
	STOP_PROCESSING(SSobj, src)
	qdel(internal_tank)
	return ..()

/obj/item/mecha_parts/mecha_equipment/air_tank/attach(obj/vehicle/sealed/mecha/new_mecha, attach_right)
	. = ..()
	START_PROCESSING(SSobj, src)
	RegisterSignal(new_mecha, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(disconnect_air))

/obj/item/mecha_parts/mecha_equipment/air_tank/detach(atom/moveto)
	disconnect_air()
	if(tank_pump_active)
		tank_pump_active = FALSE
	UnregisterSignal(chassis, COMSIG_MOVABLE_PRE_MOVE)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/air_tank/set_active(active)
	. = ..()
	if(active)
		var/datum/action/action = locate(/datum/action/vehicle/sealed/mecha/mech_toggle_cabin_seal) in usr.actions
		action.button_icon_state = "mech_cabin_[chassis.cabin_sealed ? "pressurized" : "open"]"
		action.build_all_button_icons()
	else
		var/datum/action/action = locate(/datum/action/vehicle/sealed/mecha/mech_toggle_cabin_seal) in usr.actions
		action.button_icon_state = "mech_cabin_[chassis.cabin_sealed ? "closed" : "open"]"
		action.build_all_button_icons()

/obj/item/mecha_parts/mecha_equipment/air_tank/process(seconds_per_tick)
	if(!chassis)
		return
	process_cabin_pressure()
	process_pump()

/obj/item/mecha_parts/mecha_equipment/air_tank/proc/process_cabin_pressure(seconds_per_tick)
	if(!chassis.cabin_sealed || !active)
		return
	var/datum/gas_mixture/external_air = chassis.loc.return_air()
	var/datum/gas_mixture/tank_air = internal_tank.return_air()
	var/datum/gas_mixture/cabin_air = chassis.cabin_air
	var/release_pressure = internal_tank.release_pressure
	var/cabin_pressure = cabin_air.return_pressure()
	if(cabin_pressure < release_pressure)
		tank_air.release_gas_to(cabin_air, release_pressure)
	if(cabin_pressure)
		cabin_air.pump_gas_to(external_air, PUMP_MAX_PRESSURE, GAS_CO2)

/obj/item/mecha_parts/mecha_equipment/air_tank/proc/process_pump(seconds_per_tick)
	if(!tank_pump_active)
		return
	var/turf/local_turf = get_turf(chassis)
	var/datum/gas_mixture/sending = (tank_pump_direction == PUMP_IN ? local_turf.return_air() : internal_tank.air_contents)
	var/datum/gas_mixture/receiving = (tank_pump_direction == PUMP_IN ? internal_tank.air_contents : local_turf.return_air())
	if(sending.pump_gas_to(receiving, tank_pump_pressure))
		air_update_turf(FALSE, FALSE)

/obj/item/mecha_parts/mecha_equipment/air_tank/proc/disconnect_air()
	SIGNAL_HANDLER
	if(connected_port && internal_tank.disconnect())
		to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_warning("Air port connection has been severed!")]")
		log_message("Lost connection to gas port.", LOG_MECHA)

/obj/item/mecha_parts/mecha_equipment/air_tank/get_snowflake_data()
	var/datum/gas_mixture/tank_air = internal_tank.return_air()
	return list(
		"snowflake_id" = MECHA_SNOWFLAKE_ID_AIR_TANK,
		"auto_pressurize_on_seal" = auto_pressurize_on_seal,
		"port_connected" = internal_tank?.connected_port ? TRUE : FALSE,
		"tank_release_pressure" = round(internal_tank.release_pressure),
		"tank_release_pressure_min" = internal_tank.can_min_release_pressure,
		"tank_release_pressure_max" = internal_tank.can_max_release_pressure,
		"tank_pump_active" = tank_pump_active,
		"tank_pump_direction" = tank_pump_direction,
		"tank_pump_pressure" = round(tank_pump_pressure),
		"tank_pump_pressure_min" = PUMP_MIN_PRESSURE,
		"tank_pump_pressure_max" = min(PUMP_MAX_PRESSURE, internal_tank.maximum_pressure),
		"tank_air" = gas_mixture_parser(tank_air, "tank"),
		"cabin_air" = gas_mixture_parser(chassis.cabin_air, "cabin"),
	)

/obj/item/mecha_parts/mecha_equipment/air_tank/handle_ui_act(action, list/params)
	switch(action)
		if("set_cabin_pressure")
			var/new_pressure = text2num(params["new_pressure"])
			internal_tank.release_pressure = clamp(round(new_pressure), internal_tank.can_min_release_pressure, internal_tank.can_max_release_pressure)
			return TRUE
		if("toggle_port")
			if(internal_tank.connected_port)
				if(internal_tank.disconnect())
					to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_notice("Disconnected from the air system port.")]")
					log_message("Disconnected from gas port.", LOG_MECHA)
					return TRUE
				to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_warning("Unable to disconnect from the air system port!")]")
				return
			var/obj/machinery/atmospherics/components/unary/portables_connector/possible_port = locate() in chassis.loc
			if(internal_tank.connect(possible_port))
				to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_notice("Connected to the air system port.")]")
				log_message("Connected to gas port.", LOG_MECHA)
				return TRUE
			to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_warning("Unable to connect with air system port!")]")
			return FALSE
		if("toggle_auto_pressurize")
			auto_pressurize_on_seal = !auto_pressurize_on_seal
			return TRUE
		if("toggle_tank_pump")
			tank_pump_active = !tank_pump_active
			return TRUE
		if("toggle_tank_pump_direction")
			tank_pump_direction = !tank_pump_direction
			return TRUE
		if("set_tank_pump_pressure")
			var/new_pressure = text2num(params["new_pressure"])
			tank_pump_pressure = clamp(round(new_pressure), PUMP_MIN_PRESSURE, min(PUMP_MAX_PRESSURE, internal_tank.maximum_pressure))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/air_tank/full
	start_full = TRUE
