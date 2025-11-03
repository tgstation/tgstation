/// SERIALIZATION EXTENSIONS FOR CORE OBJECTS
///
/// Save and load persistence for essential machinery and items (Ore Silos, Airlocks, APCs, Atmospherics, etc.)
/// To ensure their unique runtime state persists across round restarts

///  O R E   S I L O  ///

/obj/machinery/ore_silo/on_object_saved(map_string, turf/current_loc)
	var/datum/component/material_container/material_holder = GetComponent(/datum/component/material_container)
	for(var/each in material_holder.materials)
		var/amount = material_holder.materials[each] / 100
		var/datum/material/material_datum = each
		while((amount > 0))
/*
			if(TGM_MAX_OBJ_CHECK)
				continue
			TGM_OBJ_INCREMENT
*/

			var/obj/item/stack/typepath = material_datum.sheet_type
			var/amount_in_stack = max(1, min(50, amount))
			amount -= amount_in_stack

			var/list/variables = list()
			TGM_ADD_TYPEPATH_VAR(variables, typepath, amount, amount_in_stack)
			TGM_MAP_BLOCK(map_string, typepath, generate_tgm_typepath_metadata(variables))

/obj/machinery/ore_silo/PersistentInitialize()
	. = ..()
	var/datum/component/material_container/silo_container = materials

	// transfer all mats to silo. whatever cannot be transfered is dumped out as sheets
	top_level:
		for(var/obj/item/stack/target_stack in loc)
			var/total_amount = 0
			for(var/mat_type, per_unit_amount in target_stack.mats_per_unit)
				if(!silo_container.can_hold_material(mat_type))
					continue top_level
				total_amount += (per_unit_amount * target_stack.amount)

			if(!silo_container.has_space(total_amount))
				continue top_level

			// yes, a double loop is really neccessary
			for(var/mat_type, per_unit_amount in target_stack.mats_per_unit)
				silo_container.materials[mat_type] += (per_unit_amount * target_stack.amount)

			qdel(target_stack)

///  M A T E R I A L   S T A C K S  ///

/obj/item/stack/get_save_vars()
	. = ..()
	. += NAMEOF(src, amount)
	return .

///  D O C K I N G   P O R T  ///

/obj/docking_port/get_save_vars()
	. = ..()
	. += NAMEOF(src, dheight)
	. += NAMEOF(src, dwidth)
	. += NAMEOF(src, height)
	. += NAMEOF(src, shuttle_id)
	. += NAMEOF(src, width)
	return .

/obj/docking_port/stationary/get_save_vars()
	return ..() + NAMEOF(src, roundstart_template)

///  A T M O S P H E R I C S  ///

/obj/machinery/meter/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon)
	. -= NAMEOF(src, icon_state)
	// /obj/machinery/meter/monitored/distro_loop has an id_tag fix that later
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

/*
/obj/machinery/atmospherics/pipe/smart/get_save_vars()
	. = ..()
	//. -= NAMEOF(src, dir)
	return .
*/

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
/obj/machinery/atmospherics/components/unary/is_saveable()
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


// Don't forget to look into other atmos subtypes for variables to save and initialize
// knock it out now before it gets forgotten in the future













/obj/structure/extinguisher_cabinet/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon_state)
	return .

/obj/machinery/requests_console/get_save_vars()
	. = ..()
	. -= NAMEOF(src, name)
	return .

/// CHECK IF ID_TAGS ARE NEEDED FOR FIREDOOR/FIREALARMS
/obj/machinery/door/firedoor/get_save_vars()
	. = ..()
	. -= NAMEOF(src, name)
	. -= NAMEOF(src, id_tag)
	return .

/obj/machinery/firealarm/get_save_vars()
	. = ..()
	. -= NAMEOF(src, name)
	. -= NAMEOF(src, id_tag)
	return .
/// SEE ABOVE

/obj/machinery/atmospherics/pipe/layer_manifold/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon_state)
	return .

/obj/structure/cable/get_save_vars()
	. = ..()
	. += NAMEOF(src, cable_color)
	. += NAMEOF(src, cable_layer)

	. -= NAMEOF(src, icon_state)
	. -= NAMEOF(src, color)
	return .

/obj/machinery/duct/get_save_vars()
	. = ..()
	// idk shit about plumbing but i think these are correct?
	. += NAMEOF(src, lock_layers)
	. += NAMEOF(src, duct_layer)
	. += NAMEOF(src, ignore_colors)
	. += NAMEOF(src, duct_color)

	. -= NAMEOF(src, icon_state)
	. -= NAMEOF(src, color)
	return .

/obj/machinery/microwave/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon_state)
	return .

/obj/machinery/ai_slipper/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon_state)
	return .

/obj/item/bodypart/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon_state)
	return .

/obj/effect/decal/cleanable/blood/footprints/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon_state)
	return .

/obj/item/stack/cable_coil/get_save_vars()
	. = ..()
	. += NAMEOF(src, cable_color)

	// wires modify several vars immediately after init which results
	// in excessive save data that should be omitted
	. -= NAMEOF(src, name)
	. -= NAMEOF(src, icon_state)
	. -= NAMEOF(src, pixel_x)
	. -= NAMEOF(src, pixel_y)
	. -= NAMEOF(src, color)
	return .

/obj/machinery/atmospherics/components/unary/thermomachine/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon)
	return .

/obj/machinery/light_switch/get_save_vars()
	. = ..()
	. -= NAMEOF(src, name)
	. -= NAMEOF(src, icon_state)
	return .

/obj/structure/steam_vent/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon_state)
	return .

/obj/machinery/smartfridge/drying/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon_state)
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

///  D O O R  &  A I R L O C K  ///

/obj/machinery/door/get_save_vars()
	. = ..()
	. -= NAMEOF(src, density)
	. -= NAMEOF(src, opacity)
	. -= NAMEOF(src, icon_state)
	return .

/obj/machinery/door/airlock/get_save_vars()
	. = ..()
	. += NAMEOF(src, autoname)
	. += NAMEOF(src, emergency)

	if(autoname)
		. -= NAMEOF(src, name)

	. -= NAMEOF(src, density)
	. -= NAMEOF(src, opacity)
	. -= NAMEOF(src, icon_state) // airlocks ignore icon_state and instead use get_airlock_overlay()
	return .

/obj/machinery/door/airlock/on_object_saved(map_string, turf/current_loc)
	if(abandoned)
		TGM_MAP_BLOCK(map_string, /obj/effect/mapping_helpers/airlock/abandoned, null)
	else // Only save these if not abandoned
		if(welded)
			TGM_MAP_BLOCK(map_string, /obj/effect/mapping_helpers/airlock/welded, null)
		if(locked && !cycle_pump) // cycle pumps has funky bolt behavior that needs to be ignored
			TGM_MAP_BLOCK(map_string, /obj/effect/mapping_helpers/airlock/locked, null)
	if(cyclelinkeddir)
		var/obj/effect/mapping_helpers/airlock/cyclelink_helper/typepath = /obj/effect/mapping_helpers/airlock/cyclelink_helper
		var/list/variables = list()
		TGM_ADD_TYPEPATH_VAR(variables, typepath, dir, cyclelinkeddir)
		TGM_MAP_BLOCK(map_string, typepath, generate_tgm_typepath_metadata(variables))

	if(closeOtherId)
		var/obj/effect/mapping_helpers/airlock/cyclelink_helper_multi/typepath = /obj/effect/mapping_helpers/airlock/cyclelink_helper_multi
		var/list/variables = list()
		TGM_ADD_TYPEPATH_VAR(variables, typepath, cycle_id, closeOtherId)
		TGM_MAP_BLOCK(map_string, typepath, generate_tgm_typepath_metadata(variables))

	if(unres_sides)
		for(var/heading in list(NORTH, SOUTH, EAST, WEST))
			if(unres_sides & heading)
				var/obj/effect/mapping_helpers/airlock/unres/typepath = /obj/effect/mapping_helpers/airlock/unres
				var/list/variables = list()
				TGM_ADD_TYPEPATH_VAR(variables, typepath, dir, heading)
				TGM_MAP_BLOCK(map_string, typepath, generate_tgm_typepath_metadata(variables))

/obj/machinery/door/password/get_save_vars()
	. = ..()
	. += NAMEOF(src, password)
	return .

/obj/machinery/door/poddoor/get_save_vars()
	. = ..()
	. += NAMEOF(src, id)
	return .

///  P U Z Z L E  ///

/obj/item/keycard/get_save_vars()
	. = ..()
	. += NAMEOF(src, puzzle_id)
	return .

/obj/machinery/door/puzzle/get_save_vars()
	. = ..()
	. += NAMEOF(src, puzzle_id)
	return .

/obj/item/pressure_plate/hologrid/get_save_vars()
	. = ..()
	. += NAMEOF(src, reward)
	return .

/obj/structure/light_puzzle/get_save_vars()
	. = ..()
	. += NAMEOF(src, queue_size)
	. += NAMEOF(src, puzzle_id)
	return .

/obj/machinery/puzzle/get_save_vars()
	. = ..()
	. += NAMEOF(src, queue_size)
	. += NAMEOF(src, id)
	return .

/obj/machinery/puzzle/password/get_save_vars()
	. = ..()
	. += NAMEOF(src, password)
	. += NAMEOF(src, tgui_text)
	. += NAMEOF(src, tgui_title)
	. += NAMEOF(src, input_max_len_is_pass)
	return .

/obj/machinery/puzzle/password/pin/get_save_vars()
	. = ..()
	. += NAMEOF(src, pin_length)
	return .

/obj/structure/puzzle_blockade/get_save_vars()
	. = ..()
	. += NAMEOF(src, id)
	return .

/obj/effect/puzzle_poddoor_open/get_save_vars()
	. = ..()
	. += NAMEOF(src, queue_id)
	. += NAMEOF(src, id)
	return .

/obj/effect/decal/puzzle_dots/get_save_vars()
	. = ..()
	. += NAMEOF(src, id)
	return .

/obj/effect/decal/cleanable/crayon/puzzle/get_save_vars()
	. = ..()
	. += NAMEOF(src, puzzle_id)
	return .

/obj/item/paper/fluff/scrambled_pass/get_save_vars()
	. = ..()
	. += NAMEOF(src, puzzle_id)
	return .

///  B U T T O N  ///

/obj/machinery/button/get_save_vars()
	. = ..()
	. += NAMEOF(src, id)
	return .

///  N O T I C E   B O A R D  ///

/obj/structure/noticeboard/on_object_saved(map_string, turf/current_loc)
	for(var/obj/item/paper/paper in contents)
/*
		if(TGM_MAX_OBJ_CHECK)
			continue
		TGM_OBJ_INCREMENT
*/

		TGM_MAP_BLOCK(map_string, paper.type, generate_tgm_metadata(paper))


///  F A L S E   W A L L  ///

/obj/structure/falsewall/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon)
	return .

///  C L O S E T  ///

/obj/structure/closet/get_save_vars()
	. = ..()
	. += NAMEOF(src, welded)
	. += NAMEOF(src, opened)
	. += NAMEOF(src, locked)
	return .

///  T R A M  ///

// The tram is a little tricky to save because all the [/obj/structure/transport/linear] get deleted except for the one at the bottom left of the tram. These all get used during Init to determine the size and shape of the tram.
// Next problem is the landmark [/obj/effect/landmark/transport/transport_id] gets attatched to the /datum/transport_controller/ and then deleted.
// To resolve these we are going to insert a transport structure on the same turf as any tram wall/floors.
// Then we lookup the landmark from the datum and insert it on the same turf that has the bottom left transport structure
// Without these fixes the tram will runtime on any map or ruins that has it setup
/*
/obj/structure/thermoplastic/on_object_saved()
	var/data
	if(!(locate(/obj/structure/transport/linear/tram) in loc))
		data += "[data ? ",\n" : ""][/obj/structure/transport/linear/tram]"
	return data

/obj/structure/tram/on_object_saved()
	var/data
	if(!(locate(/obj/structure/transport/linear/tram) in loc))
		data += "[data ? ",\n" : ""][/obj/structure/transport/linear/tram]"
	return data
*/
/obj/structure/transport/linear/tram/is_saveable(turf/current_loc)
	return TRUE // skip multi-tile object checks

/obj/structure/transport/linear/tram/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon_state)
	return .

/obj/structure/tram/spoiler/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon_state)
	return .

/*
/obj/structure/transport/linear/tram/get_save_substitute_type(turf/current_loc)
	// substitute any tram pieces that are not the bottom left turf of the bounding box
	// since the tram is considered a multi-tile object
	if(src.loc == current_loc)
		return FALSE

	if(locate(/obj/structure/thermoplastic) in current_loc) // tram open turf floor
		return /obj/structure/transport/linear/tram
	if(locate(/obj/structure/tram) in current_loc) // tram wall
		return /obj/structure/transport/linear/tram

	var/obj/structure/tram/spoiler/tram_corner = locate(/obj/structure/tram/spoiler) in current_loc
	if(tram_corner)
		switch(tram_corner.dir)
			if(NORTH)
				return /obj/structure/transport/linear/tram/corner/northeast
			if(SOUTH)
				return /obj/structure/transport/linear/tram/corner/southwest
			if(EAST)
				return /obj/structure/transport/linear/tram/corner/southeast
			if(WEST)
				return /obj/structure/transport/linear/tram/corner/northwest

	return FALSE
*/

// these are for public elevators
/obj/structure/transport/linear/public/on_object_saved(map_string, turf/current_loc)
	var/datum/transport_controller/linear/transport = transport_controller_datum

	if(!transport || !transport.specific_transport_id || !length(transport.transport_modules))
		return

	var/total_elevator_turfs = length(transport.transport_modules)
	var/middle_section = ceil(total_elevator_turfs / 2) // 2x3 elevators do not play nice with this calculation
	if(transport.transport_modules[middle_section] != src)
		return

	var/obj/effect/landmark/transport/transport_id/landmark_typepath = /obj/effect/landmark/transport/transport_id
	var/list/landmark_variables = list()
	TGM_ADD_TYPEPATH_VAR(landmark_variables, landmark_typepath, specific_transport_id, transport.specific_transport_id)
	TGM_MAP_BLOCK(map_string, landmark_typepath, generate_tgm_typepath_metadata(landmark_variables))

	var/obj/effect/abstract/elevator_music_zone/elevator_music_path = /obj/effect/abstract/elevator_music_zone
	var/list/elevator_variables = list()
	TGM_ADD_TYPEPATH_VAR(elevator_variables, elevator_music_path, linked_elevator_id, transport.specific_transport_id)
	TGM_MAP_BLOCK(map_string, elevator_music_path, generate_tgm_typepath_metadata(elevator_variables))

// these are for the tram
/obj/structure/transport/linear/tram/on_object_saved(map_string, turf/current_loc)
	// only save the landmark to the bottom left turf of the bounding box since
	// the tram is considered a multi-tile object
	if(src.loc != current_loc)
		return

	var/datum/transport_controller/linear/transport = transport_controller_datum
	if(transport?.specific_transport_id)
		var/obj/effect/landmark/transport/transport_id/landmark_typepath = /obj/effect/landmark/transport/transport_id
		var/list/landmark_variables = list()
		TGM_ADD_TYPEPATH_VAR(landmark_variables, landmark_typepath, specific_transport_id, transport.specific_transport_id)
		TGM_MAP_BLOCK(map_string, landmark_typepath, generate_tgm_typepath_metadata(landmark_variables))

/obj/machinery/elevator_control_panel/get_save_vars()
	. = ..()
	. += NAMEOF(src, linked_elevator_id)
	. += NAMEOF(src, preset_destination_names)
	return .

/obj/machinery/lift_indicator/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon_state)

	. += NAMEOF(src, linked_elevator_id)
	. += NAMEOF(src, current_lift_floor)
	return .

///  A R T  ///

/obj/structure/sign/painting/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon)
	return .

/obj/item/photo/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon)
	return .


///  A I R   A L A R M  ///

/obj/machinery/airalarm/get_save_vars()
	. = ..()
	. -= NAMEOF(src, name)
	return .

///  P H O T O C O P I E R  ///

/obj/machinery/photocopier/get_save_vars()
	. = ..()
	. += NAMEOF(src, paper_stack)
	return .

/// P O W E R ///

// these spawn underneath apc's but are created by them in Initilization()
/obj/machinery/power/terminal/is_saveable()
	if(locate(/obj/machinery/power/apc) in loc)
		return FALSE

	return ..()

/obj/machinery/power/apc/get_save_vars()
	. = ..()
	. += NAMEOF(src, opened)
	. += NAMEOF(src, coverlocked)
	. += NAMEOF(src, lighting)
	. += NAMEOF(src, equipment)
	. += NAMEOF(src, environ)
	. += NAMEOF(src, cell_type)

	if(auto_name)
		. -= NAMEOF(src, name)

	// TODO save the wire data but need to include states for cute wires, signalers attached to wires, etc.
	//. += NAMEOF(src, shorted)
	//. += NAMEOF(src, locked)
	return .

/obj/machinery/power/apc/get_custom_save_vars()
	. = ..()
	if(cell_type)
		.[NAMEOF(src, start_charge)] = round((cell.charge / cell.maxcharge * 100))
	return .

/obj/machinery/power/smes/get_save_vars()
	. = ..()
	. += NAMEOF(src, input_level)
	. += NAMEOF(src, output_level)
	return .

/obj/machinery/power/smes/get_custom_save_vars()
	. = ..()
	.[NAMEOF(src, charge)] = total_charge()
	return .

/obj/item/stock_parts/power_store/get_save_vars()
	. = ..()
	. += NAMEOF(src, charge)
	. += NAMEOF(src, rigged)
	return .

/// MONEY ///

/obj/item/holochip/get_save_vars()
	. = ..()
	. += NAMEOF(src, credits)

	. -= NAMEOF(src, name)
	return .

///  L I G H T I N G  ///

/obj/machinery/light/get_save_vars()
	. = ..()
	. += NAMEOF(src, status)

	. -= NAMEOF(src, icon_state)
	return .

/obj/machinery/light/get_save_substitute_type()
	if(type != /obj/machinery/light)
		return FALSE

	switch(status)
		if(LIGHT_EMPTY)
			return /obj/machinery/light/built
		if(LIGHT_BROKEN)
			return /obj/machinery/light/broken
		if(LIGHT_BURNED)
			return //obj/machinery/light/burned
	return FALSE

/obj/machinery/light/built/get_save_substitute_type()
	switch(status)
		if(LIGHT_OK)
			return /obj/machinery/light
		if(LIGHT_BROKEN)
			return /obj/machinery/light/broken
		if(LIGHT_BURNED)
			return //obj/machinery/light/burned
	return FALSE

/obj/machinery/light/broken/get_save_substitute_type()
	switch(status)
		if(LIGHT_OK)
			return /obj/machinery/light
		if(LIGHT_EMPTY)
			return /obj/machinery/light/built
		if(LIGHT_BURNED)
			return //obj/machinery/light/burned
	return FALSE

/obj/machinery/light/small/get_save_substitute_type()
	if(type != /obj/machinery/light/small)
		return FALSE

	switch(status)
		if(LIGHT_EMPTY)
			return /obj/machinery/light/small/built
		if(LIGHT_BROKEN)
			return /obj/machinery/light/small/broken
		if(LIGHT_BURNED)
			return //obj/machinery/light/small/burned
	return FALSE

/obj/machinery/light/small/built/get_save_substitute_type()
	switch(status)
		if(LIGHT_OK)
			return /obj/machinery/light/small
		if(LIGHT_BROKEN)
			return /obj/machinery/light/small/broken
		if(LIGHT_BURNED)
			return //obj/machinery/light/small/burned
	return FALSE

/obj/machinery/light/small/broken/get_save_substitute_type()
	switch(status)
		if(LIGHT_OK)
			return /obj/machinery/light/small
		if(LIGHT_EMPTY)
			return /obj/machinery/light/small/built
		if(LIGHT_BURNED)
			return //obj/machinery/light/small/burned
	return FALSE

// Floor lights
/obj/machinery/light/floor/get_save_substitute_type()
	if(type != /obj/machinery/light/floor)
		return FALSE

	switch(status)
		if(LIGHT_BROKEN)
			return /obj/machinery/light/floor/broken
		if(LIGHT_BURNED)
			return //obj/machinery/light/floor/burned
		// LIGHT_EMPTY - no /built subtype exists yet for floor lights
	return FALSE

/obj/machinery/light/floor/broken/get_save_substitute_type()
	switch(status)
		if(LIGHT_OK)
			return /obj/machinery/light/floor
		if(LIGHT_BURNED)
			return //obj/machinery/light/floor/burned
		// LIGHT_EMPTY - no /built subtype exists yet for floor lights
	return FALSE

/obj/structure/light_construct/get_save_vars()
	. = ..()
	. += NAMEOF(src, stage)
	. += NAMEOF(src, fixture_type)

	. -= NAMEOF(src, icon_state)
	return .

/obj/item/reagent_containers/get_save_vars()
	. = ..()
	. += NAMEOF(src, amount_per_transfer_from_this)
	return .

/obj/item/reagent_containers/get_custom_save_vars()
	. = ..()
	var/has_identical_reagents = TRUE
	var/list/cached_reagents = reagents.reagent_list
	var/list/reagents_to_save
	for(var/datum/reagent/reagent as anything in cached_reagents)
		var/amount = floor(reagent.volume)
		if(amount <= 0)
			continue

		LAZYSET(reagents_to_save, reagent.type, amount)

		// checks if reagent & amount inside both reagent lists are identical
		if(LAZYACCESS(list_reagents, reagent.type) == amount)
			continue
		has_identical_reagents = FALSE

	if(length(reagents_to_save) != length(list_reagents))
		has_identical_reagents = FALSE

	if(!has_identical_reagents)
		.[NAMEOF(src, list_reagents)] = reagents_to_save

	if(initial(initial_reagent_flags) != reagents.flags)
		.[NAMEOF(src, initial_reagent_flags)] = reagents.flags

	return .

///  B O T A N Y  ///

// both seeds and grown fruit are easily spammable with different variables
// also look into returning FALSE instead of empty list might be faster for all
// objects
/obj/item/seeds/get_save_vars()
	return list()

/obj/item/food/grown/get_save_vars()
	return list()

/obj/machinery/camera/get_save_vars()
	. = ..()
	. += NAMEOF(src, network)
	. += NAMEOF(src, c_tag)

	return .

/obj/item/storage/briefcase/secure/get_save_vars()
	. = ..()
	. += NAMEOF(src, stored_lock_code)
	return .

/obj/item/wallframe/secure_safe/get_save_vars()
	. = ..()
	. += NAMEOF(src, stored_lock_code)
	return .

/obj/structure/secure_safe/get_save_vars()
	. = ..()
	. += NAMEOF(src, stored_lock_code)
	return .

/obj/structure/safe/get_save_vars()
	. = ..()
	. += NAMEOF(src, open)
	. += NAMEOF(src, locked)
	. += NAMEOF(src, tumblers)
	. += NAMEOF(src, explosion_count)
	return .

/obj/structure/safe/get_custom_save_vars()
	. = ..()
	// we don't need to set new tumblers otherwise the tumblers list grows out of control
	.[NAMEOF(src, number_of_tumblers)] = 0
	return .

/obj/structure/safe/PersistentInitialize()
	. = ..()
	update_appearance()

/*
/obj/item/card/id/on_object_saved()
	var/data
	if(!registered_account)
		return
	if(registered_account.account_balance <= 0)
		return

	var/credits_var = NAMEOF_TYPEPATH(/obj/item/holochip, credits)
	var/balance = registered_account.account_balance
	data += "[data ? ",\n" : ""][/obj/item/holochip::type]{\n\t[credits_var] = [balance]\n\t}"
	return data

/obj/item/card/id/PersistentInitialize()
	. = ..()

	for(var/obj/item/holochip/money in loc)
		var/credits = money.get_item_credit_value()
		if(!credits)
			continue
		registered_account.adjust_money(credits)
		qdel(money)


/obj/machinery/light/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon_state) // the tube changes color depending on low power, which we don't want to track

	. += NAMEOF(src, has_mock_cell)
	. += NAMEOF(src, status)
	return .

/obj/structure/light_construct/get_save_vars()
	. = ..()
	. += NAMEOF(src, stage)
	. += NAMEOF(src, fixture_type)
	return .


/obj/item/paper/get_save_vars()
	. = ..()
	. += NAMEOF(src, show_written_words)
	. += NAMEOF(src, input_field_count)
	. += NAMEOF(src, default_raw_text)
	return .

/obj/item/paper/get_custom_save_vars()
	. = ..()

	// Don't save anything if the paper is empty
	if(is_empty())
		return .

	// Convert the paper's complex data to a serializable format
	var/list/paper_data = convert_to_data()

	if(LAZYLEN(paper_data[LIST_PAPER_RAW_TEXT_INPUT]))
		.[NAMEOF(src, raw_text_inputs)] = paper_data[LIST_PAPER_RAW_TEXT_INPUT]

	if(LAZYLEN(paper_data[LIST_PAPER_RAW_STAMP_INPUT]))
		.[NAMEOF(src, raw_stamp_data)] = paper_data[LIST_PAPER_RAW_STAMP_INPUT]

	if(LAZYLEN(paper_data[LIST_PAPER_RAW_FIELD_INPUT]))
		.[NAMEOF(src, raw_field_input_data)] = paper_data[LIST_PAPER_RAW_FIELD_INPUT]

	return .

/obj/item/paper/PersistentInitialize()
	. = ..()

	// If we have saved data in list format, reconstruct the paper
	if(islist(raw_text_inputs) || islist(raw_stamp_data) || islist(raw_field_input_data))
		var/list/saved_data = list()

		// Reconstruct the data structure expected by write_from_data
		saved_data[LIST_PAPER_RAW_TEXT_INPUT] = islist(raw_text_inputs) ? raw_text_inputs : list()
		saved_data[LIST_PAPER_RAW_STAMP_INPUT] = islist(raw_stamp_data) ? raw_stamp_data : list()
		saved_data[LIST_PAPER_RAW_FIELD_INPUT] = islist(raw_field_input_data) ? raw_field_input_data : list()
		saved_data[LIST_PAPER_COLOR] = color || COLOR_WHITE
		saved_data[LIST_PAPER_NAME] = name

		// Clear the raw lists first
		raw_text_inputs = null
		raw_stamp_data = null
		raw_field_input_data = null

		// Rebuild the paper from the saved data
		write_from_data(saved_data)
		update_appearance()

/obj/item/clipboard/on_object_saved()
	var/data
	// Save the pen if there is one
	if(pen)
		var/metadata = generate_tgm_metadata(pen)
		data += "[data ? ",\n" : ""][pen.type][metadata]"

	// Save any papers attached to the clipboard
	for(var/obj/item/paper/paper in contents)
		var/metadata = generate_tgm_metadata(paper)
		data += "[data ? ",\n" : ""][paper.type][metadata]"

	return data

/obj/item/clipboard/PersistentInitialize()
	. = ..()

	// Move any pens from the same tile into the clipboard
	var/obj/item/pen/found_pen = locate() in loc
	if(found_pen && !pen)
		found_pen.forceMove(src)
		pen = found_pen

	// Move any papers from the same tile into the clipboard
	for(var/obj/item/paper/paper in loc)
		paper.forceMove(src)

	// Update appearance once at the end after all items are collected
	update_appearance(UPDATE_ICON)


*/
