// Every cycle, the pump uses the air in air_in to try and make air_out the perfect pressure.
//
// node1, air1, network1 correspond to input
// node2, air2, network2 correspond to output
// Unlike ordinary pumps, this one won't pump if the input doesn't reach some temperature condition.

#define CHECK_AROUND 0
#define CHECK_BELOW 1
#define CHECK_ABOVE 2

/obj/machinery/atmospherics/components/binary/pump/temperature
	name = "temp-filtered gas pump"
	desc = "A pump that moves gas by pressure. Can filter by temperature."
	var/target_temperature = T20C
	var/temp_range = 10 //kelvins
	var/check_mode = CHECK_AROUND
	var/last_check_success = TRUE

/obj/machinery/atmospherics/components/binary/pump/temperature/update_icon_nopipes()
	if(last_check_success)
		..()
	else
		icon_state = "pump_off"

/obj/machinery/atmospherics/components/binary/pump/temperature/process_atmos()
	if(!on || !is_operational())
		return

	var/datum/gas_mixture/air1 = airs[1]

	var/input_starting_temperature = air1.return_temperature()
	last_check_success = TRUE
	switch(check_mode)
		if(CHECK_AROUND)
			if(input_starting_temperature-temp_range>target_temperature || input_starting_temperature+temp_range<target_temperature)
				last_check_success = FALSE
				return

		if(CHECK_BELOW)
			if(input_starting_temperature > target_temperature)
				last_check_success = FALSE
				return

		if(CHECK_ABOVE)
			if(input_starting_temperature < target_temperature)
				last_check_success = FALSE
				return

	var/datum/gas_mixture/air2 = airs[2]


	var/output_starting_pressure = air2.return_pressure()
	if((target_pressure - output_starting_pressure) < 0.01)
		//No need to pump gas if target is already reached!
		return

	//Calculate necessary moles to transfer using PV=nRT
	if((air1.total_moles() > 0) && (air1.temperature>0))
		var/pressure_delta = target_pressure - output_starting_pressure
		var/transfer_moles = pressure_delta*air2.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas
		var/datum/gas_mixture/removed = air1.remove(transfer_moles)
		air2.merge(removed)

		update_parents()

/obj/machinery/atmospherics/components/binary/pump/temperature/ui_data()
	var/data = list()
	data["on"] = on
	data["pressure"] = round(target_pressure)
	data["max_pressure"] = round(MAX_OUTPUT_PRESSURE)
	data["target"] = target_temperature
	data["range"] = temp_range
	data["mode"] = check_mode
	return data

/obj/machinery/atmospherics/components/binary/pump/temperature/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("power")
			on = !on
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_SUPERMATTER) // yogs - makes supermatter invest useful
			. = TRUE
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "max")
				pressure = MAX_OUTPUT_PRESSURE
				. = TRUE
			else if(pressure == "input")
				pressure = input("New output pressure (0-[MAX_OUTPUT_PRESSURE] kPa):", name, target_pressure) as num|null
				if(!isnull(pressure) && !..())
					. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				target_pressure = CLAMP(pressure, 0, MAX_OUTPUT_PRESSURE)
				investigate_log("was set to [target_pressure] kPa by [key_name(usr)]", INVESTIGATE_ATMOS)
				investigate_log("was set to [target_pressure] kPa by [key_name(usr)]", INVESTIGATE_SUPERMATTER) // yogs - makes supermatter invest useful
		if("target")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "input")
				target = input("Set new target (min 0K):", name, target_temperature) as num|null
				if(!isnull(target))
					. = TRUE
			else if(adjust)
				target = target_temperature + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				target_temperature = max(target, 0)
				investigate_log("was set to [target_temperature] K by [key_name(usr)]", INVESTIGATE_ATMOS)
				investigate_log("was set to [target_temperature] K by [key_name(usr)]", INVESTIGATE_SUPERMATTER)
		if("range")
			var/range = 10
			range = input("Set new range:",name,temp_range) as num|null
			if(!isnull(range))
				temp_range = max(range,0)
				investigate_log("range was set to [temp_range] K by [key_name(usr)]", INVESTIGATE_ATMOS)
				investigate_log("range was set to [temp_range] K by [key_name(usr)]", INVESTIGATE_SUPERMATTER)
		if("setRange")
			check_mode = CHECK_AROUND
		if("setBelow")
			check_mode = CHECK_BELOW
		if("setAbove")
			check_mode = CHECK_ABOVE

	update_icon()

/obj/machinery/atmospherics/components/binary/pump/temperature/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
																datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "atmos_temp_pump", name, 335, 115, master_ui, state)
		ui.open()

#undef CHECK_AROUND
#undef CHECK_BELOW
#undef CHECK_ABOVE
