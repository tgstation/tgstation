//States for airlock_control
#define AIRLOCK_STATE_INOPEN "inopen"
#define AIRLOCK_STATE_PRESSURIZE "pressurize"
#define AIRLOCK_STATE_CLOSED "closed"
#define AIRLOCK_STATE_DEPRESSURIZE "depressurize"
#define AIRLOCK_STATE_OUTOPEN "outopen"

/obj/machinery/airlock_controller
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "airlock_control_standby"
	base_icon_state = "airlock_control"

	name = "airlock console"
	density = FALSE

	power_channel = AREA_USAGE_ENVIRON

	// Setup parameters only
	var/exterior_door_tag
	var/interior_door_tag
	var/airpump_tag
	var/sensor_tag
	var/sanitize_external

	var/datum/weakref/interior_door_ref
	var/datum/weakref/exterior_door_ref
	var/datum/weakref/pump_ref
	var/datum/weakref/sensor_ref

	var/last_pressure = null

	var/state = AIRLOCK_STATE_CLOSED
	var/target_state = AIRLOCK_STATE_CLOSED

	var/processing = FALSE

/obj/machinery/airlock_controller/post_machine_initialize()
	. = ..()

	var/obj/machinery/door/interior_door = GLOB.objects_by_id_tag[interior_door_tag]
	if (!isnull(interior_door_tag) && !istype(interior_door))
		stack_trace("interior_door_tag is set to [interior_door_tag], which is not a door ([interior_door || "null"])")
	interior_door_ref = WEAKREF(interior_door)

	var/obj/machinery/door/exterior_door = GLOB.objects_by_id_tag[exterior_door_tag]
	if (!isnull(exterior_door_tag) && !istype(exterior_door))
		stack_trace("exterior_door_tag is set to [exterior_door_tag], which is not a door ([exterior_door || "null"])")
	exterior_door_ref = WEAKREF(exterior_door)

	var/obj/machinery/atmospherics/components/binary/dp_vent_pump/pump = GLOB.objects_by_id_tag[airpump_tag]
	if (!isnull(airpump_tag) && !istype(pump))
		stack_trace("airpump_tag is set to [airpump_tag], which is not a pump ([pump || "null"])")
	pump_ref = WEAKREF(pump)

	var/obj/machinery/airlock_sensor/sensor = GLOB.objects_by_id_tag[sensor_tag]
	if (!isnull(sensor_tag) && !istype(sensor))
		stack_trace("sensor_tag is set to [sensor_tag], which is not a sensor ([sensor || "null"])")
	sensor_ref = WEAKREF(sensor)

/obj/machinery/airlock_controller/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AirlockController", src)
		ui.open()

/obj/machinery/airlock_controller/process(seconds_per_tick)
	var/process_again = TRUE
	while(process_again)
		process_again = FALSE
		switch(state)
			if(AIRLOCK_STATE_INOPEN)
				if(target_state != state)
					var/obj/machinery/door/airlock/interior_airlock = interior_door_ref.resolve()
					if (isnull(interior_airlock))
						continue

					if(interior_airlock.density)
						state = AIRLOCK_STATE_CLOSED
						process_again = TRUE
					else
						interior_airlock.secure_close()
				else
					var/obj/machinery/atmospherics/components/binary/dp_vent_pump/pump = pump_ref.resolve()

					if(pump?.on)
						pump.on = FALSE
						pump.update_appearance(UPDATE_ICON)

			if(AIRLOCK_STATE_PRESSURIZE)
				if(target_state == AIRLOCK_STATE_INOPEN)
					var/sensor_pressure = sensor_pressure()
					if (isnull(sensor_pressure))
						continue

					if(sensor_pressure >= ONE_ATMOSPHERE*0.95)
						var/obj/machinery/door/airlock/interior_airlock = interior_door_ref.resolve()
						if (isnull(interior_airlock))
							continue

						if(interior_airlock.density)
							interior_airlock?.secure_open()
						else
							state = AIRLOCK_STATE_INOPEN
							process_again = TRUE
					else
						var/obj/machinery/atmospherics/components/binary/dp_vent_pump/pump = pump_ref.resolve()
						if (isnull(pump))
							continue

						if(pump.pump_direction == ATMOS_DIRECTION_SIPHONING)
							pump.pressure_checks |= ATMOS_EXTERNAL_BOUND
							pump.pump_direction = ATMOS_DIRECTION_RELEASING
						else if(!pump.on)
							pump.on = TRUE
							pump.update_appearance(UPDATE_ICON)
				else
					state = AIRLOCK_STATE_CLOSED
					process_again = TRUE

			if(AIRLOCK_STATE_CLOSED)
				if(target_state == AIRLOCK_STATE_OUTOPEN)
					var/obj/machinery/door/airlock/interior_airlock = interior_door_ref.resolve()
					if (isnull(interior_airlock))
						continue

					if(interior_airlock.density)
						state = AIRLOCK_STATE_DEPRESSURIZE
						process_again = TRUE
					else
						interior_airlock?.secure_close()
				else if(target_state == AIRLOCK_STATE_INOPEN)
					var/obj/machinery/door/airlock/exterior_airlock = exterior_door_ref.resolve()
					if (isnull(exterior_airlock))
						continue

					if(exterior_airlock.density)
						state = AIRLOCK_STATE_PRESSURIZE
						process_again = TRUE
					else
						exterior_airlock?.secure_close()
				else
					var/obj/machinery/atmospherics/components/binary/dp_vent_pump/pump = pump_ref.resolve()
					if (isnull(pump))
						continue

					if (!pump.on)
						pump.on = TRUE
						pump.update_appearance(UPDATE_ICON)

			if(AIRLOCK_STATE_DEPRESSURIZE)
				var/target_pressure = ONE_ATMOSPHERE*0.05
				if(sanitize_external)
					target_pressure = ONE_ATMOSPHERE*0.01

				var/sensor_pressure = sensor_pressure()
				if (isnull(sensor_pressure))
					continue

				if(sensor_pressure <= target_pressure)
					if(target_state == AIRLOCK_STATE_OUTOPEN)
						var/obj/machinery/door/airlock/exterior_airlock = exterior_door_ref.resolve()
						if (isnull(exterior_airlock))
							continue

						if(exterior_airlock.density)
							exterior_airlock.secure_open()
						else
							state = AIRLOCK_STATE_OUTOPEN
					else
						state = AIRLOCK_STATE_CLOSED
						process_again = TRUE
				else if((target_state != AIRLOCK_STATE_OUTOPEN) && !sanitize_external)
					state = AIRLOCK_STATE_CLOSED
					process_again = TRUE
				else
					var/obj/machinery/atmospherics/components/binary/dp_vent_pump/pump = pump_ref.resolve()
					if (isnull(pump))
						continue

					if(pump.pump_direction == ATMOS_DIRECTION_RELEASING)
						pump.pressure_checks &= ~ATMOS_EXTERNAL_BOUND
						pump.pump_direction = ATMOS_DIRECTION_SIPHONING
					else if(!pump.on)
						pump.on = TRUE
						pump.update_appearance(UPDATE_ICON)

			if(AIRLOCK_STATE_OUTOPEN) //state 2
				if(target_state != AIRLOCK_STATE_OUTOPEN)
					var/obj/machinery/door/airlock/exterior_airlock = exterior_door_ref.resolve()
					if (isnull(exterior_airlock))
						continue

					if(exterior_airlock.density)
						if(sanitize_external)
							state = AIRLOCK_STATE_DEPRESSURIZE
							process_again = TRUE
						else
							state = AIRLOCK_STATE_CLOSED
							process_again = TRUE
					else
						exterior_airlock.secure_close()
				else
					var/obj/machinery/atmospherics/components/binary/dp_vent_pump/pump = pump_ref.resolve()
					if (isnull(pump))
						continue

					if (pump.on)
						pump.on = FALSE
						pump.update_appearance(UPDATE_ICON)

	processing = state != target_state

	update_appearance()
	SStgui.update_uis(src)

/obj/machinery/airlock_controller/ui_data(mob/user)
	var/list/data = list()

	data["airlockState"] = state

	var/sensor_pressure = sensor_pressure()
	data["sensorPressure"] = isnull(sensor_pressure) ? "----" : round(sensor_pressure, 0.1)

	var/obj/machinery/door/airlock/interior_airlock = interior_door_ref.resolve()
	if (isnull(interior_airlock))
		data["interiorStatus"] = "----"
	else
		data["interiorStatus"] = interior_airlock.density ? "closed" : "open"

	var/obj/machinery/door/airlock/exterior_airlock = exterior_door_ref.resolve()
	if (isnull(exterior_airlock))
		data["exteriorStatus"] = "----"
	else
		data["exteriorStatus"] = exterior_airlock.density ? "closed" : "open"

	var/obj/machinery/atmospherics/components/binary/dp_vent_pump/pump = pump_ref.resolve()
	switch (pump?.pump_direction)
		if (null)
			data["pumpStatus"] = "----"
		if (ATMOS_DIRECTION_RELEASING)
			data["pumpStatus"] = "release"
		if (ATMOS_DIRECTION_SIPHONING)
			data["pumpStatus"] = "siphon"

	return data

/obj/machinery/airlock_controller/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("cycleClosed")
			target_state = AIRLOCK_STATE_CLOSED
		if("cycleExterior")
			target_state = AIRLOCK_STATE_OUTOPEN
		if("cycleInterior")
			target_state = AIRLOCK_STATE_INOPEN
		if("abort")
			target_state = AIRLOCK_STATE_CLOSED

	return TRUE

/// Starts an airlock cycle
/obj/machinery/airlock_controller/proc/cycle()
	if (state == AIRLOCK_STATE_INOPEN || state == AIRLOCK_STATE_PRESSURIZE)
		target_state = AIRLOCK_STATE_OUTOPEN
	else
		target_state = AIRLOCK_STATE_INOPEN

/// Returns the pressure over the pump, or null if it is deleted
/obj/machinery/airlock_controller/proc/sensor_pressure()
	var/obj/machinery/airlock_sensor/sensor = sensor_ref.resolve()
	if (!isnull(sensor) && !sensor.on)
		return last_pressure

	var/datum/gas_mixture/air = sensor?.return_air()
	last_pressure = air?.return_pressure()
	return last_pressure

/obj/machinery/airlock_controller/incinerator_ordmix
	name = "Incinerator Access Console"
	airpump_tag = INCINERATOR_ORDMIX_DP_VENTPUMP
	exterior_door_tag = INCINERATOR_ORDMIX_AIRLOCK_EXTERIOR
	id_tag = INCINERATOR_ORDMIX_AIRLOCK_CONTROLLER
	interior_door_tag = INCINERATOR_ORDMIX_AIRLOCK_INTERIOR
	sanitize_external = TRUE
	sensor_tag = INCINERATOR_ORDMIX_AIRLOCK_SENSOR

/obj/machinery/airlock_controller/incinerator_atmos
	name = "Incinerator Access Console"
	airpump_tag = INCINERATOR_ATMOS_DP_VENTPUMP
	exterior_door_tag = INCINERATOR_ATMOS_AIRLOCK_EXTERIOR
	id_tag = INCINERATOR_ATMOS_AIRLOCK_CONTROLLER
	interior_door_tag = INCINERATOR_ATMOS_AIRLOCK_INTERIOR
	sanitize_external = TRUE
	sensor_tag = INCINERATOR_ATMOS_AIRLOCK_SENSOR

/obj/machinery/airlock_controller/incinerator_syndicatelava
	name = "Incinerator Access Console"
	airpump_tag = INCINERATOR_SYNDICATELAVA_DP_VENTPUMP
	exterior_door_tag = INCINERATOR_SYNDICATELAVA_AIRLOCK_EXTERIOR
	id_tag = INCINERATOR_SYNDICATELAVA_AIRLOCK_CONTROLLER
	interior_door_tag = INCINERATOR_SYNDICATELAVA_AIRLOCK_INTERIOR
	sanitize_external = TRUE
	sensor_tag = INCINERATOR_SYNDICATELAVA_AIRLOCK_SENSOR

/obj/machinery/airlock_controller/update_icon_state()
	icon_state = "[base_icon_state]_[processing ? "process" : "standby"]"
	return ..()

#undef AIRLOCK_STATE_CLOSED
#undef AIRLOCK_STATE_DEPRESSURIZE
#undef AIRLOCK_STATE_INOPEN
#undef AIRLOCK_STATE_OUTOPEN
#undef AIRLOCK_STATE_PRESSURIZE
