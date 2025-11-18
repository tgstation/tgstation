// Don't forget to look into other atmos subtypes for variables to save and initialize
// knock it out now before it gets forgotten in the future
/obj/machinery/meter/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, target_layer)
	return .

/obj/machinery/atmospherics/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, piping_layer)
	. += NAMEOF(src, pipe_color)
	. += NAMEOF(src, on)
	. += NAMEOF(src, vent_movement)

	. -= NAMEOF(src, id_tag)
	return .

/obj/machinery/atmospherics/pipe/smart/substitute_with_typepath(map_string)
	var/base_type = /obj/machinery/atmospherics/pipe/smart/manifold4w
	var/cache_key = "[base_type]-[pipe_color]-[hide]-[piping_layer]"
	if(isnull(GLOB.map_export_typepath_cache[cache_key]))
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
		else
			GLOB.map_export_typepath_cache[cache_key] = FALSE
			stack_trace("Failed to convert pipe to typepath: [full_path]")

	var/cached_typepath = GLOB.map_export_typepath_cache[cache_key]
	if(cached_typepath)
		var/obj/machinery/atmospherics/pipe/smart/manifold4w/typepath = cached_typepath
		// all relevant variables are in the typepath string
		TGM_MAP_BLOCK(map_string, typepath, null)

	return cached_typepath

// these spawn underneath cryo machines and will duplicate after every save
/obj/machinery/atmospherics/components/unary/is_saveable(turf/current_loc, list/obj_blacklist)
	if(locate(/obj/machinery/cryo_cell) in loc)
		return FALSE

	return ..()

/obj/machinery/atmospherics/components/unary/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, welded)
	return .

/obj/machinery/atmospherics/components/unary/vent_pump/substitute_with_typepath(map_string)
	var/base_type
	if(istype(src, /obj/machinery/atmospherics/components/unary/vent_pump/high_volume))
		base_type = /obj/machinery/atmospherics/components/unary/vent_pump/high_volume
	else
		base_type = /obj/machinery/atmospherics/components/unary/vent_pump

	var/cache_key = "[base_type]-[on]-[piping_layer]"
	if(isnull(GLOB.map_export_typepath_cache[cache_key]))
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
		else
			GLOB.map_export_typepath_cache[cache_key] = FALSE
			stack_trace("Failed to convert vent scrubber to typepath: [full_path]")

	var/cached_typepath = GLOB.map_export_typepath_cache[cache_key]
	if(cached_typepath)
		var/obj/machinery/atmospherics/components/unary/vent_pump/typepath = cached_typepath
		var/list/variables = list()
		TGM_ADD_TYPEPATH_VAR(variables, typepath, dir, dir)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, welded, welded)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, pump_direction, pump_direction)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, pressure_checks, pressure_checks)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, internal_pressure_bound, internal_pressure_bound)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, external_pressure_bound, external_pressure_bound)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, fan_overclocked, fan_overclocked)

		TGM_MAP_BLOCK(map_string, typepath, generate_tgm_typepath_metadata(variables))

	return cached_typepath

/obj/machinery/atmospherics/components/unary/vent_pump/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, pump_direction)
	. += NAMEOF(src, pressure_checks)
	. += NAMEOF(src, internal_pressure_bound)
	. += NAMEOF(src, external_pressure_bound)
	. += NAMEOF(src, fan_overclocked)
	return .

/obj/machinery/atmospherics/components/unary/vent_scrubber/substitute_with_typepath(map_string)
	var/base_type = /obj/machinery/atmospherics/components/unary/vent_scrubber
	var/cache_key = "[base_type]-[on]-[piping_layer]"
	if(isnull(GLOB.map_export_typepath_cache[cache_key]))
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
		else
			GLOB.map_export_typepath_cache[cache_key] = FALSE
			stack_trace("Failed to convert vent scrubber to typepath: [full_path]")

	var/cached_typepath = GLOB.map_export_typepath_cache[cache_key]
	if(cached_typepath)
		var/obj/machinery/atmospherics/components/unary/vent_scrubber/typepath = cached_typepath
		var/list/variables = list()
		TGM_ADD_TYPEPATH_VAR(variables, typepath, dir, dir)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, welded, welded)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, scrubbing, scrubbing)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, filter_types, filter_types)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, widenet, widenet)

		TGM_MAP_BLOCK(map_string, typepath, generate_tgm_typepath_metadata(variables))

	return cached_typepath

/obj/machinery/atmospherics/components/unary/vent_scrubber/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, scrubbing)
	. += NAMEOF(src, filter_types)
	. += NAMEOF(src, widenet)
	return .

/obj/machinery/atmospherics/components/unary/vent_scrubber/PersistentInitialize()
	. = ..()
	if(widenet)
		set_widenet(widenet)

/obj/machinery/atmospherics/components/unary/thermomachine/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, target_temperature)
	return .

/obj/machinery/atmospherics/components/trinary/filter/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, transfer_rate)
	. += NAMEOF(src, filter_type)
	return .

/obj/machinery/atmospherics/components/trinary/mixer/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, target_pressure)
	. += NAMEOF(src, node1_concentration)
	. += NAMEOF(src, node2_concentration)
	return .

/obj/machinery/atmospherics/components/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, welded)

	if(override_naming)
		. += NAMEOF(src, name)
	return .

/obj/item/pipe/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, piping_layer)
	. += NAMEOF(src, pipe_color)
	return .

/obj/machinery/portable_atmospherics/canister/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, valve_open)
	. += NAMEOF(src, release_pressure)
	return .

/obj/machinery/portable_atmospherics/get_custom_save_vars(save_flags=ALL)
	. = ..()
	var/datum/gas_mixture/gasmix = air_contents
	.[NAMEOF(src, initial_gas_mix)] = gasmix.to_string()
	return .
