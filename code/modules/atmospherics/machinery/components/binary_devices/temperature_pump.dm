#define TEMPERATURE_PUMP_POWER_CONVERSION 0.001

/obj/machinery/atmospherics/components/binary/temperature_pump
	icon_state = "tpump_map-3"
	name = "temperature pump"
	desc = "A pump that moves heat from one pipeline to another. The input will get cooler, and the output will get hotter."
	can_unwrench = TRUE
	shift_underlay_only = FALSE
	construction_type = /obj/item/pipe/directional
	pipe_state = "tpump"
	vent_movement = NONE
	///Percent of the heat delta to transfer
	var/heat_transfer_rate = 0
	///Maximum allowed transfer percentage
	var/max_heat_transfer_rate = 100

/obj/machinery/atmospherics/components/binary/temperature_pump/CtrlClick(mob/user)
	if(can_interact(user))
		on = !on
		investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
		update_appearance()
	return ..()

/obj/machinery/atmospherics/components/binary/temperature_pump/AltClick(mob/user)
	if(can_interact(user) && !(heat_transfer_rate == max_heat_transfer_rate))
		heat_transfer_rate = max_heat_transfer_rate
		investigate_log("was set to [heat_transfer_rate]% by [key_name(user)]", INVESTIGATE_ATMOS)
		balloon_alert(user, "transfer rate set to [heat_transfer_rate]%")
		update_appearance()
	return ..()

/obj/machinery/atmospherics/components/binary/temperature_pump/update_icon_nopipes()
	icon_state = "tpump_[on && is_operational ? "on" : "off"]-[set_overlay_offset(piping_layer)]"

/obj/machinery/atmospherics/components/binary/temperature_pump/process_atmos()
	if(!is_operational)
		return

	var/datum/gas_mixture/air_input = airs[1]
	var/datum/gas_mixture/air_output = airs[2]

	if(!QUANTIZE(air_input.total_moles()) || !QUANTIZE(air_output.total_moles())) //Don't transfer if there's no gas
		return
	var/datum/gas_mixture/remove_input = air_input.remove_ratio(0.9)
	var/datum/gas_mixture/remove_output = air_output.remove_ratio(0.9)

	var/coolant_temperature_delta = remove_input.temperature - remove_output.temperature
	var/power_usage
	var/input_capacity = remove_input.heat_capacity()
	var/output_capacity = remove_output.heat_capacity()

	//Exchange heat between the nodes.
	if(coolant_temperature_delta)
		var/thermal_equilibrium = (input_capacity * remove_input.temperature + output_capacity * remove_output.temperature) / (input_capacity + output_capacity)
		remove_input.temperature = max(thermal_equilibrium, TCMB)
		remove_output.temperature = max(thermal_equilibrium, TCMB)

	//Pump heat against the gradient.
	if(on)
		var/heat_amount = CALCULATE_CONDUCTION_ENERGY((remove_input.temperature - TCMB) * heat_transfer_rate * 0.01, input_capacity, output_capacity)
		remove_input.temperature = max((remove_input.temperature * input_capacity - heat_amount) / input_capacity, TCMB)
		remove_output.temperature = max((remove_output.temperature * output_capacity + heat_amount) / output_capacity, TCMB)
		power_usage = heat_amount * TEMPERATURE_PUMP_POWER_CONVERSION
	update_parents()


	air_input.merge(remove_input)
	air_output.merge(remove_output)

	if(power_usage)
		use_power(power_usage)

/obj/machinery/atmospherics/components/binary/temperature_pump/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosTempPump", name)
		ui.open()

/obj/machinery/atmospherics/components/binary/temperature_pump/ui_data()
	var/data = list()
	data["on"] = on
	data["rate"] = round(heat_transfer_rate)
	data["max_heat_transfer_rate"] = round(max_heat_transfer_rate)
	return data

/obj/machinery/atmospherics/components/binary/temperature_pump/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			on = !on
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("rate")
			var/rate = params["rate"]
			if(rate == "max")
				rate = max_heat_transfer_rate
				. = TRUE
			else if(text2num(rate) != null)
				rate = text2num(rate)
				. = TRUE
			if(.)
				heat_transfer_rate = clamp(rate, 0, max_heat_transfer_rate)
				investigate_log("was set to [heat_transfer_rate]% by [key_name(usr)]", INVESTIGATE_ATMOS)
	update_appearance()
#undef TEMPERATURE_PUMP_POWER_CONVERSION
