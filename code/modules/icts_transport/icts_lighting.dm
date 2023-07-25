/obj/machinery/light/tram/exterior
	name = "tram exterior light"
	icon_state = "tram4"
	brightness = 4
	bulb_power = 0.7
	light_angle = 60
	light_system = MOVABLE_LIGHT
	light_flags = LIGHT_ATTACHED
	bulb_colour = LIGHT_COLOR_CYAN
	nightshift_enabled = FALSE

/obj/machinery/light/tram/exterior/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/light/tram/exterior/LateInitialize()
	. = ..()
	RegisterSignal(SSicts_transport, COMSIG_ICTS_TRANSPORT_ACTIVE, PROC_REF(set_direction))

/obj/structure/tram/spoiler/proc/find_tram()
	for(var/datum/transport_controller/linear/tram/tram as anything in SSicts_transport.transports_by_type[ICTS_TYPE_TRAM])
		if(tram.specific_transport_id != tram_id)
			continue
		tram_ref = WEAKREF(tram)
		break

/obj/machinery/light/tram/exterior/proc/set_direction(source, controller, controller_active, controller_status, travel_direction)
	SIGNAL_HANDLER

	if(!controller_active)
		return

	switch(travel_direction)
		if(SOUTH, EAST)
			switch(dir)
				if(NORTH, EAST)
					set_light(l_color = LIGHT_COLOR_INTENSE_RED)
				if(SOUTH, WEST)
					set_light(l_color = LIGHT_COLOR_CYAN)

		if(NORTH, WEST)
			switch(dir)
				if(NORTH, EAST)
					set_light(l_color = LIGHT_COLOR_CYAN)
				if(SOUTH, WEST)
					set_light(l_color = LIGHT_COLOR_INTENSE_RED)

/obj/machinery/light/tram/interior
	name = "tram interior light"
	icon_state = "tram4"
	brightness = 4
	bulb_power = 0.5
	bulb_colour = LIGHT_COLOR_FAINT_BLUE
	light_system = MOVABLE_LIGHT
	light_flags = LIGHT_ATTACHED
	nightshift_light_color = COLOR_STARLIGHT
	nightshift_enabled = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/tram/exterior, (-32))
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/tram/exterior/red, (-32))
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/tram/interior, 0)
