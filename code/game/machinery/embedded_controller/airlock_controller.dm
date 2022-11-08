//States for airlock_control
#define AIRLOCK_STATE_INOPEN "inopen"
#define AIRLOCK_STATE_PRESSURIZE "pressurize"
#define AIRLOCK_STATE_CLOSED "closed"
#define AIRLOCK_STATE_DEPRESSURIZE "depressurize"
#define AIRLOCK_STATE_OUTOPEN "outopen"

/datum/computer/file/embedded_program/airlock_controller
	var/id_tag
	var/sanitize_external //Before the interior airlock opens, do we first drain all gases inside the chamber and then repressurize?

	var/datum/weakref/interior_door_ref
	var/datum/weakref/exterior_door_ref
	var/datum/weakref/pump_ref

	state = AIRLOCK_STATE_CLOSED
	var/target_state = AIRLOCK_STATE_CLOSED

	var/processing = FALSE

#ifdef MBTODO
/datum/computer/file/embedded_program/airlock_controller/receive_signal(datum/signal/signal)
	var/receive_tag = signal.data["tag"]
	if(!receive_tag)
		return

	if(receive_tag==sensor_tag)
		if(signal.data["pressure"])
			sensor_pressure = text2num(signal.data["pressure"])

	else if(receive_tag==exterior_door_tag)
		memory["exterior_status"] = signal.data["door_status"]

	else if(receive_tag==interior_door_tag)
		memory["interior_status"] = signal.data["door_status"]

	else if(receive_tag==airpump_tag)
		if(signal.data["power"])
			memory["pump_status"] = signal.data["direction"]
		else
			memory["pump_status"] = "off"

	else if(receive_tag==id_tag)
		switch(signal.data["command"])
			if("cycle")
				if(state < AIRLOCK_STATE_CLOSED)
					target_state = AIRLOCK_STATE_OUTOPEN
				else
					target_state = AIRLOCK_STATE_INOPEN
#endif

/datum/computer/file/embedded_program/airlock_controller/receive_user_command(command)
	switch(command)
		if("cycleClosed")
			target_state = AIRLOCK_STATE_CLOSED
		if("cycleExterior")
			target_state = AIRLOCK_STATE_OUTOPEN
		if("cycleInterior")
			target_state = AIRLOCK_STATE_INOPEN
		if("abort")
			target_state = AIRLOCK_STATE_CLOSED

/datum/computer/file/embedded_program/airlock_controller/process()
	var/process_again = 1
	while(process_again)
		process_again = 0
		switch(state)
			if(AIRLOCK_STATE_INOPEN)
				if(target_state != state)
					var/obj/machinery/door/airlock/interior_airlock = interior_door_ref.resolve()
					if (isnull(interior_airlock))
						continue

					if(interior_airlock.density)
						state = AIRLOCK_STATE_CLOSED
						process_again = 1
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
							process_again = 1
					else
						var/obj/machinery/atmospherics/components/binary/dp_vent_pump/pump = pump_ref.resolve()
						if (isnull(pump))
							continue

						if(pump.pump_direction == ATMOS_DIRECTION_SIPHONING)
							pump.pressure_checks |= ATMOS_EXTERNAL_BOUND
							pump.pump_direction = ATMOS_DIRECTION_RELEASING
						else if(pump.pump_direction == ATMOS_DIRECTION_RELEASING)
							pump.on = TRUE

						pump.update_appearance(UPDATE_ICON)
				else
					state = AIRLOCK_STATE_CLOSED
					process_again = 1

			if(AIRLOCK_STATE_CLOSED)
				if(target_state == AIRLOCK_STATE_OUTOPEN)
					var/obj/machinery/door/airlock/interior_airlock = interior_door_ref.resolve()
					if (isnull(interior_airlock))
						continue

					if(interior_airlock.density)
						state = AIRLOCK_STATE_DEPRESSURIZE
						process_again = 1
					else
						interior_airlock?.secure_close()
				else if(target_state == AIRLOCK_STATE_INOPEN)
					var/obj/machinery/door/airlock/exterior_airlock = exterior_door_ref.resolve()
					if (isnull(exterior_airlock))
						continue

					if(exterior_airlock.density)
						state = AIRLOCK_STATE_PRESSURIZE
						process_again = 1
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
						process_again = 1
				else if((target_state != AIRLOCK_STATE_OUTOPEN) && !sanitize_external)
					state = AIRLOCK_STATE_CLOSED
					process_again = 1
				else
					var/obj/machinery/atmospherics/components/binary/dp_vent_pump/pump = pump_ref.resolve()
					if (isnull(pump))
						continue

					if(pump.pump_direction == ATMOS_DIRECTION_RELEASING)
						pump.pressure_checks &= ~ATMOS_EXTERNAL_BOUND
						pump.pump_direction = ATMOS_DIRECTION_SIPHONING
						pump.update_appearance(UPDATE_ICON)

			if(AIRLOCK_STATE_OUTOPEN) //state 2
				if(target_state != AIRLOCK_STATE_OUTOPEN)
					var/obj/machinery/door/airlock/exterior_airlock = exterior_door_ref.resolve()
					if (isnull(exterior_airlock))
						continue

					if(exterior_airlock.density)
						if(sanitize_external)
							state = AIRLOCK_STATE_DEPRESSURIZE
							process_again = 1
						else
							state = AIRLOCK_STATE_CLOSED
							process_again = 1
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

	return 1

/// Returns the pressure over the pump, or null if it is deleted
/datum/computer/file/embedded_program/airlock_controller/proc/sensor_pressure()
	var/obj/machinery/atmospherics/components/binary/dp_vent_pump/pump = pump_ref.resolve()
	var/datum/gas_mixture/air = pump?.return_air()
	return air?.return_pressure()

/obj/machinery/airlock_controller
	icon = 'icons/obj/airlock_machines.dmi'
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

GLOBAL_LIST_EMPTY_TYPED(airlock_controllers_by_id, /obj/machinery/airlock_controller)

/obj/machinery/airlock_controller/Initialize(mapload)
	. = ..()
	if(!mapload)
		return

	if (!isnull(id_tag))
		GLOB.airlock_controllers_by_id[id_tag] = src

	var/datum/computer/file/embedded_program/airlock_controller/new_prog = new

	new_prog.id_tag = id_tag
	new_prog.sanitize_external = sanitize_external

	new_prog.master = src
	program = new_prog

/obj/machinery/airlock_controller/LateInitialize()
	. = ..()

	if (isnull(program))
		return

	var/datum/computer/file/embedded_program/airlock_controller/airlock_program = program
	airlock_program.interior_door_ref = WEAKREF(GLOB.airlocks_by_id[interior_door_tag])
	airlock_program.exterior_door_ref = WEAKREF(GLOB.airlocks_by_id[exterior_door_tag])
	airlock_program.pump_ref = WEAKREF(GLOB.vents_by_id[airpump_tag])

/obj/machinery/airlock_controller/Destroy()
	GLOB.airlock_controllers_by_id -= id_tag
	return ..()

/obj/machinery/airlock_controller/Topic(href, href_list) // needed to override obj/machinery/embedded_controller/Topic, dont think its actually used in game other than here but the code is still here

/obj/machinery/airlock_controller/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AirlockController", src)
		ui.open()

/obj/machinery/airlock_controller/process(delta_time)
	if(program)
		program.process(delta_time)

	update_appearance()
	SStgui.update_uis(src)

/obj/machinery/airlock_controller/ui_data(mob/user)
	var/list/data = list()

	var/datum/computer/file/embedded_program/airlock_controller/airlock_program = program
	data["airlockState"] = airlock_program.state

	var/sensor_pressure = airlock_program.sensor_pressure()
	data["sensorPressure"] = isnull(sensor_pressure) ? "----" : round(sensor_pressure, 0.1)

	var/obj/machinery/door/airlock/interior_airlock = airlock_program.interior_door_ref.resolve()
	if (isnull(interior_airlock))
		data["interiorStatus"] = "----"
	else
		data["interiorStatus"] = interior_airlock.density ? "closed" : "open"

	var/obj/machinery/door/airlock/exterior_airlock = airlock_program.exterior_door_ref.resolve()
	if (isnull(exterior_airlock))
		data["exteriorStatus"] = "----"
	else
		data["exteriorStatus"] = exterior_airlock.density ? "closed" : "open"

	var/obj/machinery/atmospherics/components/binary/dp_vent_pump/pump = airlock_program.pump_ref.resolve()
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
	// no need for sanitisation, command just changes target_state and can't do anything else
	process_command(action)
	return TRUE

/// Starts an airlock cycle
/obj/machinery/airlock_controller/proc/cycle()
	var/datum/computer/file/embedded_program/airlock_controller/airlock_program = program
	if (isnull(airlock_program))
		return

	if (airlock_program.state < AIRLOCK_STATE_CLOSED)
		airlock_program.target_state = AIRLOCK_STATE_OUTOPEN
	else
		airlock_program.target_state = AIRLOCK_STATE_INOPEN

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
	if(on && program)
		var/datum/computer/file/embedded_program/airlock_controller/airlock_program = program
		icon_state = "[base_icon_state]_[airlock_program.processing ? "process" : "standby"]"
		return ..()
	icon_state = "[base_icon_state]_off"
	return ..()
