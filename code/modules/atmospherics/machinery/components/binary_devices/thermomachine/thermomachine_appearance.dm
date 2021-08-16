/obj/machinery/atmospherics/components/binary/thermomachine/update_icon_state()
	switch(target_temperature)
		if(BODYTEMP_HEAT_WARNING_3 to INFINITY)
			greyscale_colors = COLOR_RED
		if(BODYTEMP_HEAT_WARNING_2 to BODYTEMP_HEAT_WARNING_3)
			greyscale_colors = COLOR_ORANGE
		if(BODYTEMP_HEAT_WARNING_1 to BODYTEMP_HEAT_WARNING_2)
			greyscale_colors = COLOR_YELLOW
		if(BODYTEMP_COLD_WARNING_1 to BODYTEMP_HEAT_WARNING_1)
			greyscale_colors = COLOR_VIBRANT_LIME
		if(BODYTEMP_COLD_WARNING_2 to BODYTEMP_COLD_WARNING_1)
			greyscale_colors = COLOR_CYAN
		if(BODYTEMP_COLD_WARNING_3 to BODYTEMP_COLD_WARNING_2)
			greyscale_colors = COLOR_BLUE
		else
			greyscale_colors = COLOR_VIOLET

	set_greyscale(colors=greyscale_colors)

	if(panel_open)
		icon_state = "thermo-open"
		return ..()
	if(on && is_operational)
		if(skipping_work)
			icon_state = "thermo_1_blinking"
		else
			icon_state = "thermo_1"
		return ..()
	icon_state = "thermo_0"
	return ..()

/obj/machinery/atmospherics/components/binary/thermomachine/update_overlays()
	. = ..()
	if(!initial(icon))
		return
	var/mutable_appearance/thermo_overlay = new(initial(icon))
	. += getpipeimage(thermo_overlay, "pipe", dir, COLOR_LIME, piping_layer)
	. += getpipeimage(thermo_overlay, "pipe", turn(dir, 180), COLOR_MOSTLY_PURE_RED, piping_layer)
