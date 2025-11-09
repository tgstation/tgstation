// Don't forget to look into other atmos subtypes for variables to save and initialize
// knock it out now before it gets forgotten in the future

/obj/machinery/meter/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon)
	. -= NAMEOF(src, icon_state)
	// /obj/machinery/meter/monitored/distro_loop has an id_tag ?
	return .

/obj/machinery/atmospherics/pipe/layer_manifold/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon_state)
	return .

/obj/machinery/atmospherics/get_save_vars()
	. = ..()
	. += NAMEOF(src, piping_layer)
	. += NAMEOF(src, pipe_color)
	. += NAMEOF(src, on)
	. += NAMEOF(src, vent_movement)

	. -= NAMEOF(src, name)
	. -= NAMEOF(src, id_tag)
	. -= NAMEOF(src, icon)
	. -= NAMEOF(src, icon_state)
	return .

/obj/machinery/atmospherics/pipe/smart/get_save_substitute_type()
	var/base_type = /obj/machinery/atmospherics/pipe/smart/manifold4w

	var/cache_key = "[base_type]-[pipe_color]-[hide]-[piping_layer]"
	var/cached_typepath = GLOB.map_export_typepath_cache[cache_key]
	if(!isnull(cached_typepath))
		return cached_typepath

	var/color_path = ""
	switch(pipe_color)
		if(COLOR_YELLOW)
			color_path = "/yellow"
		if(ATMOS_COLOR_OMNI)
			color_path = "/general"
		if(COLOR_CYAN)
			color_path = "/cyan"
		if(COLOR_VIBRANT_LIME)
			color_path = "/green"
		if(COLOR_ENGINEERING_ORANGE)
			color_path = "/orange"
		if(COLOR_PURPLE)
			color_path = "/purple"
		if(COLOR_DARK)
			color_path = "/dark"
		if(COLOR_BROWN)
			color_path = "/brown"
		if(COLOR_STRONG_VIOLET)
			color_path = "/violet"
		if(COLOR_LIGHT_PINK)
			color_path = "/pink"
		if(COLOR_RED)
			color_path = "/scrubbers"
		if(COLOR_BLUE)
			color_path = "/supply"
		else
			color_path = "/general"

	var/visible_path = hide ? "/hidden" : "/visible"

	var/layer_path = ""
	switch(piping_layer)
		if(1)
			layer_path = "/layer1"
		if(2)
			layer_path = "/layer2"
		if(3)
			layer_path = ""
		if(4)
			layer_path = "/layer4"
		if(5)
			layer_path = "/layer5"

	var/full_path = "[base_type][color_path][visible_path][layer_path]"
	var/typepath = text2path(full_path)

	if(ispath(typepath))
		GLOB.map_export_typepath_cache[cache_key] = typepath
		return typepath

	GLOB.map_export_typepath_cache[cache_key] = FALSE
	stack_trace("Failed to convert pipe to typepath: [full_path]")
	return FALSE

// these spawn underneath cryo machines and will duplicate after every save
/obj/machinery/atmospherics/components/unary/is_saveable(turf/current_loc, list/obj_blacklist)
	if(locate(/obj/machinery/cryo_cell) in loc)
		return FALSE

	return ..()

/obj/machinery/atmospherics/components/unary/get_save_vars()
	. = ..()
	. += NAMEOF(src, welded)
	return .

// REMEMBER
// lots of scrubbers/vents/pipe shit does not have layers 1 & 5 so plz test to make sure it works

/obj/machinery/atmospherics/components/unary/get_save_substitute_type()
	var/base_type
	if(istype(src, /obj/machinery/atmospherics/components/unary/vent_scrubber))
		base_type = /obj/machinery/atmospherics/components/unary/vent_scrubber
	else if(istype(src, /obj/machinery/atmospherics/components/unary/vent_pump/high_volume))
		base_type = /obj/machinery/atmospherics/components/unary/vent_pump/high_volume
	else if(istype(src, /obj/machinery/atmospherics/components/unary/vent_pump))
		base_type = /obj/machinery/atmospherics/components/unary/vent_pump
	else
		return FALSE

	var/cache_key = "[base_type]-[on]-[piping_layer]"
	var/cached_typepath = GLOB.map_export_typepath_cache[cache_key]
	if(!isnull(cached_typepath))
		return cached_typepath

	var/on_path = on ? "/on" : ""

	var/layer_path = ""
	switch(piping_layer)
		if(1)
			layer_path = "/layer1"
		if(2)
			layer_path = "/layer2"
		if(3)
			layer_path = ""
		if(4)
			layer_path = "/layer4"
		if(5)
			layer_path = "/layer5"

	var/full_path = "[base_type][on_path][layer_path]"
	var/typepath = text2path(full_path)

	if(ispath(typepath))
		GLOB.map_export_typepath_cache[cache_key] = typepath
		return typepath

	GLOB.map_export_typepath_cache[cache_key] = FALSE
	stack_trace("Failed to convert vent scrubber to typepath: [full_path]")
	return FALSE

/obj/machinery/atmospherics/components/unary/vent_pump/get_save_vars()
	. = ..()
	. += NAMEOF(src, pump_direction)
	. += NAMEOF(src, pressure_checks)
	. += NAMEOF(src, internal_pressure_bound)
	. += NAMEOF(src, external_pressure_bound)
	. += NAMEOF(src, fan_overclocked)
	return .

/obj/machinery/atmospherics/components/unary/vent_scrubber/get_save_vars()
	. = ..()
	. += NAMEOF(src, scrubbing)
	. += NAMEOF(src, filter_types)
	. += NAMEOF(src, widenet)
	return .

/obj/machinery/atmospherics/components/unary/vent_scrubber/PersistentInitialize()
	. = ..()
	if(widenet)
		set_widenet(widenet)

/obj/machinery/atmospherics/components/unary/thermomachine/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon)
	return .

/obj/machinery/atmospherics/pipe/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon)
	. -= NAMEOF(src, icon_state)
	return .

/obj/machinery/atmospherics/components/get_save_vars()
	. = ..()
	. += NAMEOF(src, welded)

	if(!override_naming)
		. -= NAMEOF(src, name)
	. -= NAMEOF(src, icon_state)
	return .

/obj/item/pipe/get_save_vars()
	. = ..()
	. += NAMEOF(src, piping_layer)
	. += NAMEOF(src, pipe_color)
	return .

/obj/machinery/portable_atmospherics/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon_state)
	return .

/obj/machinery/portable_atmospherics/canister/get_save_vars()
	. = ..()
	. += NAMEOF(src, valve_open)
	. += NAMEOF(src, release_pressure)
	return .

/obj/machinery/portable_atmospherics/get_custom_save_vars()
	. = ..()
	var/datum/gas_mixture/gasmix = air_contents
	.[NAMEOF(src, initial_gas_mix)] = gasmix.to_string()
	return .
