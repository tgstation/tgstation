/obj/machinery/lightbar/tram/exterior
	name = "tram exterior light"
	icon_state = "tram_front"
	light_range = 7
	light_power = 0.7
	light_angle = 30
	light_system = MOVABLE_LIGHT
	light_flags = LIGHT_ATTACHED
	var/specific_transport_id = TRAMSTATION_LINE_1

/obj/machinery/lightbar/tram/exterior/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/lightbar/tram/exterior/LateInitialize()
	. = ..()
	find_tram()

/obj/machinery/lightbar/tram/exterior/proc/find_tram()
	for(var/datum/transport_controller/linear/tram/tram as anything in SSicts_transport.transports_by_type[ICTS_TYPE_TRAM])
		if(tram.specific_transport_id != specific_transport_id)
			continue
		RegisterSignal(tram, COMSIG_ICTS_TRANSPORT_LIGHTS, PROC_REF(set_direction))
		break

/obj/machinery/lightbar/tram/exterior/proc/set_direction(source, controller_active, controller_status, travel_direction, estop)
	SIGNAL_HANDLER

	if(estop)
		set_light_range_power_color(4, 0.4, LIGHT_COLOR_INTENSE_RED)
		icon_state = "tram_rear"

	else if((travel_direction & (SOUTH|EAST)) && controller_active || (travel_direction & (NORTH|WEST)) && !controller_active)
		switch(dir)
			if(NORTH, EAST)
				set_light_range_power_color(4, 0.4, LIGHT_COLOR_INTENSE_RED)
				icon_state = "tram_rear"
			if(SOUTH, WEST)
				set_light_range_power_color(7, 0.7, LIGHT_COLOR_FAINT_BLUE)
				icon_state = "tram_front"

	else if((travel_direction & (NORTH|WEST)) && controller_active || (travel_direction & (SOUTH|EAST)) && !controller_active)
		switch(dir)
			if(NORTH, EAST)
				set_light_range_power_color(7, 0.7, LIGHT_COLOR_FAINT_BLUE)
				icon_state = "tram_front"
			if(SOUTH, WEST)
				set_light_range_power_color(4, 0.4, LIGHT_COLOR_INTENSE_RED)
				icon_state = "tram_rear"
	else
		stack_trace("Light [src] received an invalid direction from signal")
		return

	update_appearance()

/obj/machinery/lightbar/tram
	name = "tram light"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tram_front"
	layer = WALL_OBJ_LAYER
	plane = GAME_PLANE_UPPER
	use_power = ACTIVE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.02
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.02
	light_range = 4
	light_power = 0.5
	light_color = LIGHT_COLOR_FAINT_BLUE
	light_system = MOVABLE_LIGHT
	light_flags = LIGHT_ATTACHED

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/lightbar/tram/exterior, (-32))
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/lightbar/tram/interior, 0)
