/obj/machinery/atmospherics/components/trinary
	icon = 'modular_skyraptor/modules/aesthetics/moremospherics/icons/trinary_devices.dmi'

/obj/machinery/meter/process_atmos()
	var/returnval = ..()

	if(returnval == FALSE)
		return returnval

	var/datum/gas_mixture/pipe_air = target?.return_air()
	var/env_temperature = pipe_air.temperature
	var/env_pressure = pipe_air.return_pressure()

	var/new_greyscale = greyscale_colors
	if(env_pressure == 0 || env_temperature == 0)
		new_greyscale = COLOR_WHITE
	else
		switch(env_temperature)
			if(BODYTEMP_HEAT_WARNING_3 to INFINITY)
				new_greyscale = "#FF0000"
			if(BODYTEMP_HEAT_WARNING_2 to BODYTEMP_HEAT_WARNING_3)
				new_greyscale = "#FF6600"
			if(BODYTEMP_HEAT_WARNING_1 to BODYTEMP_HEAT_WARNING_2)
				new_greyscale = "#FFFF00"
			if(BODYTEMP_COLD_WARNING_1 to BODYTEMP_HEAT_WARNING_1)
				new_greyscale = "#AAFF00"
			if(BODYTEMP_COLD_WARNING_2 to BODYTEMP_COLD_WARNING_1)
				new_greyscale = "#00FF66"
			if(BODYTEMP_COLD_WARNING_3 to BODYTEMP_COLD_WARNING_2)
				new_greyscale = "#0066FF"
			else
				new_greyscale = "#6600FF"

	if(new_greyscale != greyscale_colors)//dont update if nothing has changed since last update
		greyscale_colors = new_greyscale
		set_greyscale(greyscale_colors)

	return returnval

/obj/machinery/atmospherics/components/binary
	icon = 'modular_skyraptor/modules/aesthetics/moremospherics/icons/binary_devices.dmi'

/obj/machinery/atmospherics/components/unary
	icon = 'modular_skyraptor/modules/aesthetics/moremospherics/icons/unary_devices.dmi'



/obj/item/pipe_meter
	icon = 'modular_skyraptor/modules/aesthetics/moremospherics/icons/pipes/pipe_item.dmi'

/datum/greyscale_config/meter
	icon_file = 'modular_skyraptor/modules/aesthetics/moremospherics/icons/pipes/meter.dmi'



/obj/machinery/atmospherics/components/unary/thermomachine
	icon = 'modular_skyraptor/modules/aesthetics/moremospherics/icons/thermomachine.dmi'
	greyscale_colors = "#AAFF00"

/obj/machinery/atmospherics/components/unary/thermomachine/update_icon_state()
	var/returnval = ..()
	var/colors_to_use = ""
	switch(target_temperature)
		if(BODYTEMP_HEAT_WARNING_3 to INFINITY)
			colors_to_use = "#FF0000"
		if(BODYTEMP_HEAT_WARNING_2 to BODYTEMP_HEAT_WARNING_3)
			colors_to_use = "#FF6600"
		if(BODYTEMP_HEAT_WARNING_1 to BODYTEMP_HEAT_WARNING_2)
			colors_to_use = "#FFFF00"
		if(BODYTEMP_COLD_WARNING_1 to BODYTEMP_HEAT_WARNING_1)
			colors_to_use = "#AAFF00"
		if(BODYTEMP_COLD_WARNING_2 to BODYTEMP_COLD_WARNING_1)
			colors_to_use = "#00FF66"
		if(BODYTEMP_COLD_WARNING_3 to BODYTEMP_COLD_WARNING_2)
			colors_to_use = "#0066FF"
		else
			colors_to_use = "#6600FF"

	if(greyscale_colors != colors_to_use)
		set_greyscale(colors=colors_to_use)

	return returnval

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/on/coldroom
	greyscale_colors = "#00FF66"

/datum/greyscale_config/thermomachine
	icon_file = 'modular_skyraptor/modules/aesthetics/moremospherics/icons/thermomachine.dmi'
