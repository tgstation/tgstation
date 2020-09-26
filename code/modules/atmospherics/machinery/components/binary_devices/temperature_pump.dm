/obj/machinery/atmospherics/components/binary/temperature_pump
	icon_state = "tpump_map-3"
	name = "temperature pump"
	desc = "A pump that moves heat only."

	can_unwrench = TRUE
	shift_underlay_only = FALSE

	///Value of the amount of rate of heat exchange
	var/heat_transfer_rate = 0
	///Maximum allowed amount for the heat exchange
	var/max_heat_transfer_rate = 4500

	construction_type = /obj/item/pipe/directional
	pipe_state = "tpump"

/obj/machinery/atmospherics/components/binary/temperature_pump/CtrlClick(mob/user)
	if(can_interact(user))
		on = !on
		investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
		update_icon()
	return ..()

/obj/machinery/atmospherics/components/binary/temperature_pump/AltClick(mob/user)
	if(can_interact(user) && !(heat_transfer_rate == max_heat_transfer_rate))
		heat_transfer_rate = max_heat_transfer_rate
		investigate_log("was set to [heat_transfer_rate] K/s by [key_name(user)]", INVESTIGATE_ATMOS)
		update_icon()
	return ..()

/obj/machinery/atmospherics/components/binary/temperature_pump/update_icon_nopipes()
	icon_state = "tpump_[on && is_operational ? "on" : "off"]-[set_overlay_offset(piping_layer)]"

/obj/machinery/atmospherics/components/binary/temperature_pump/process_atmos()

	if(!on || !is_operational)
		return

	var/datum/gas_mixture/air_input = airs[1]
	var/datum/gas_mixture/air_output = airs[2]

	if((air_output.temperature + heat_transfer_rate) >= air_input.temperature || (air_input.temperature - heat_transfer_rate) <= TCRYO)
		return

	air_input.temperature -= heat_transfer_rate
	air_output.temperature += heat_transfer_rate
	update_parents()

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
				investigate_log("was set to [heat_transfer_rate] K/s by [key_name(usr)]", INVESTIGATE_ATMOS)
	update_icon()

