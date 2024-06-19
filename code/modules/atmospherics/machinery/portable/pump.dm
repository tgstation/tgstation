/obj/machinery/portable_atmospherics/pump
	name = "portable air pump"
	icon_state = "siphon"
	density = TRUE
	max_integrity = 250
	///Is the machine on?
	var/on = FALSE
	///What direction is the machine pumping (into pump/port or out to the tank/area)?
	var/direction = PUMP_OUT
	///Player configurable, sets what's the release pressure
	var/target_pressure = ONE_ATMOSPHERE

	volume = 1000

/obj/machinery/portable_atmospherics/pump/on_deconstruction(disassembled)
	var/turf/local_turf = get_turf(src)
	local_turf.assume_air(air_contents)
	return ..()

/obj/machinery/portable_atmospherics/pump/update_icon_state()
	icon_state = "[initial(icon_state)]_[on]"
	return ..()

/obj/machinery/portable_atmospherics/pump/update_overlays()
	. = ..()
	if(holding)
		. += "siphon-open"
	if(connected_port)
		. += "siphon-connector"

/obj/machinery/portable_atmospherics/pump/process_atmos()
	if(take_atmos_damage())
		excited = TRUE
		return ..()

	if(!on)
		return ..()

	excited = TRUE

	var/turf/local_turf = get_turf(src)

	var/datum/gas_mixture/sending
	var/datum/gas_mixture/receiving

	if (holding) //Work with tank when inserted, otherwise - with area
		sending = (direction == PUMP_IN ? holding.return_air() : air_contents)
		receiving = (direction == PUMP_IN ? air_contents : holding.return_air())
	else
		sending = (direction == PUMP_IN ? local_turf.return_air() : air_contents)
		receiving = (direction == PUMP_IN ? air_contents : local_turf.return_air())

	if(sending.pump_gas_to(receiving, target_pressure) && !holding)
		air_update_turf(FALSE, FALSE) // Update the environment if needed.

	return ..()

/obj/machinery/portable_atmospherics/pump/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!is_operational)
		return
	if(prob(50 / severity))
		on = !on
		if(on)
			SSair.start_processing_machine(src)
	if(prob(100 / severity))
		direction = PUMP_OUT
	target_pressure = rand(0, 100 * ONE_ATMOSPHERE)
	update_appearance()

/obj/machinery/portable_atmospherics/pump/replace_tank(mob/living/user, close_valve)
	. = ..()
	if(!.)
		return
	if(close_valve)
		if(on)
			on = FALSE
			update_appearance()
	else if(on && holding && direction == PUMP_OUT)
		user.investigate_log("started a transfer into [holding].", INVESTIGATE_ATMOS)

/obj/machinery/portable_atmospherics/pump/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PortablePump", name)
		ui.open()

/obj/machinery/portable_atmospherics/pump/ui_data()
	var/data = list()
	data["on"] = on
	data["direction"] = direction
	data["connected"] = !!connected_port
	data["pressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["targetPressure"] = round(target_pressure ? target_pressure : 0)
	data["defaultPressure"] = round(PUMP_DEFAULT_PRESSURE)
	data["minPressure"] = round(PUMP_MIN_PRESSURE)
	data["maxPressure"] = round(PUMP_MAX_PRESSURE)
	data["hasHypernobCrystal"] = !!nob_crystal_inserted
	data["reactionSuppressionEnabled"] = !!suppress_reactions

	if(holding)
		data["holding"] = list()
		data["holding"]["name"] = holding.name
		var/datum/gas_mixture/holding_mix = holding.return_air()
		data["holding"]["pressure"] = round(holding_mix.return_pressure())
	else
		data["holding"] = null
	return data

/obj/machinery/portable_atmospherics/pump/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			on = !on
			if(on)
				SSair.start_processing_machine(src)
			if(on && !holding)
				var/plasma = air_contents.gases[/datum/gas/plasma]
				var/n2o = air_contents.gases[/datum/gas/nitrous_oxide]
				if(n2o || plasma)
					message_admins("[ADMIN_LOOKUPFLW(usr)] turned on a pump that contains [n2o ? "N2O" : ""][n2o && plasma ? " & " : ""][plasma ? "Plasma" : ""] at [ADMIN_VERBOSEJMP(src)]")
					log_admin("[key_name(usr)] turned on a pump that contains [n2o ? "N2O" : ""][n2o && plasma ? " & " : ""][plasma ? "Plasma" : ""] at [AREACOORD(src)]")
			else if(on && direction == PUMP_OUT)
				usr.investigate_log("started a transfer into [holding].", INVESTIGATE_ATMOS)
			. = TRUE
		if("direction")
			if(direction == PUMP_OUT)
				direction = PUMP_IN
			else
				if(on && holding)
					usr.investigate_log("started a transfer into [holding].", INVESTIGATE_ATMOS)
				direction = PUMP_OUT
			. = TRUE
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "reset")
				pressure = PUMP_DEFAULT_PRESSURE
				. = TRUE
			else if(pressure == "min")
				pressure = PUMP_MIN_PRESSURE
				. = TRUE
			else if(pressure == "max")
				pressure = PUMP_MAX_PRESSURE
				. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				target_pressure = clamp(round(pressure), PUMP_MIN_PRESSURE, PUMP_MAX_PRESSURE)
				investigate_log("was set to [target_pressure] kPa by [key_name(usr)].", INVESTIGATE_ATMOS)
		if("eject")
			if(holding)
				replace_tank(usr, FALSE)
				. = TRUE
		if("reaction_suppression")
			if(!nob_crystal_inserted)
				stack_trace("[usr] tried to toggle reaction suppression on a pump without a noblium crystal inside, possible href exploit attempt.")
				return
			suppress_reactions = !suppress_reactions
			SSair.start_processing_machine(src)
			message_admins("[ADMIN_LOOKUPFLW(usr)] turned [suppress_reactions ? "on" : "off"] the [src] reaction suppression.")
			usr.investigate_log("turned [suppress_reactions ? "on" : "off"] the [src] reaction suppression.")
			. = TRUE
	update_appearance()

/obj/machinery/portable_atmospherics/pump/unregister_holding()
	on = FALSE
	return ..()

/obj/machinery/portable_atmospherics/pump/lil_pump
	name = "Lil' Pump"

/obj/machinery/portable_atmospherics/pump/lil_pump/Initialize(mapload)
	. = ..()
	//25% chance to occur
	if(prob(25))
		name = "Liler' Pump"
		desc = "When a Lil' Pump and a portable air pump love each other very much."
		var/matrix/lil_pump = matrix()
		lil_pump.Scale(0.8)
		src.transform = lil_pump
