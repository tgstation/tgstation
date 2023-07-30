/obj/machinery/light/tram/exterior
	name = "tram exterior light"
	brightness = 7
	bulb_power = 0.7
	light_angle = 30
	light_system = MOVABLE_LIGHT
	light_flags = LIGHT_ATTACHED
	nightshift_allowed = FALSE
	var/specific_transport_id = TRAMSTATION_LINE_1

/obj/machinery/light/tram/exterior/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/light/tram/exterior/LateInitialize()
	. = ..()
	find_tram()

/obj/machinery/light/tram/exterior/proc/find_tram()
	for(var/datum/transport_controller/linear/tram/tram as anything in SSicts_transport.transports_by_type[ICTS_TYPE_TRAM])
		if(tram.specific_transport_id != specific_transport_id)
			continue
		RegisterSignal(tram, COMSIG_ICTS_TRANSPORT_LIGHTS, PROC_REF(set_direction))
		break

/obj/machinery/light/tram/exterior/proc/set_direction(source, controller_active, controller_status, travel_direction)
	SIGNAL_HANDLER

	if(controller_status & EMERGENCY_STOP)
		return

	if((travel_direction & (SOUTH|EAST)) && controller_active || (travel_direction & (NORTH|WEST)) && !controller_active)
		switch(dir)
			if(NORTH, EAST)
				set_light_color(LIGHT_COLOR_INTENSE_RED)
				set_light_range(4)
				set_light_power(0.4)
				icon_state = "tram_rear"
			if(SOUTH, WEST)
				set_light_color(LIGHT_COLOR_FAINT_BLUE)
				set_light_range(7)
				set_light_power(0.7)
				icon_state = "tram_front"

	else if((travel_direction & (NORTH|WEST)) && controller_active || (travel_direction & (SOUTH|EAST)) && !controller_active)
		switch(dir)
			if(NORTH, EAST)
				set_light_color(LIGHT_COLOR_FAINT_BLUE)
				set_light_range(7)
				set_light_power(0.7)
				icon_state = "tram_front"
			if(SOUTH, WEST)
				set_light_color(LIGHT_COLOR_INTENSE_RED)
				set_light_range(4)
				set_light_power(0.4)
				icon_state = "tram_rear"
	else
		stack_trace("Light [src] received an invalid direction from signal")
		return

	update_appearance()

/obj/machinery/light/tram
	name = "tram light"
	icon_state = "tram_front"
	base_state = "tram_front"
	brightness = 4
	bulb_power = 0.5
	bulb_colour = LIGHT_COLOR_FAINT_BLUE
	light_system = MOVABLE_LIGHT
	light_flags = LIGHT_ATTACHED
	nightshift_light_color = COLOR_STARLIGHT

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/tram/exterior, (-32))
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light/tram/interior, 0)
