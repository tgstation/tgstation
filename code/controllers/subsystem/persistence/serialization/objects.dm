/// SERIALIZATION EXTENSIONS FOR CORE OBJECTS
///
/// Save and load persistence for essential machinery and items (Ore Silos, Airlocks, APCs, Atmospherics, etc.)
/// To ensure their unique runtime state persists across round restarts

///  O R E   S I L O  ///

/obj/machinery/ore_silo/on_object_saved()
	var/data
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

			var/obj/item/stack/stack = material_datum.sheet_type
			var/amount_var = NAMEOF_TYPEPATH(stack, amount)
			var/amount_in_stack = max(1, min(50, amount))
			amount -= amount_in_stack
			data += "[data ? ",\n" : ""][stack.type]{\n\t[amount_var] = [amount_in_stack]\n\t}"
	return data

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

/obj/machinery/atmospherics/pipe/smart/simple/get_save_vars()
	. = ..()
	. -= NAMEOF(src, dir)
	return .

/obj/machinery/atmospherics/pipe/smart/simple/get_save_substitute_type()
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
	. = ..()

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
	. -= NAMEOF(src, icon_state)
	return .

/obj/machinery/duct/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon_state)
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

/obj/machinery/door/airlock/get_save_vars()
	. = ..()
	. += NAMEOF(src, autoname)
	. += NAMEOF(src, emergency)

	if(autoname)
		. -= NAMEOF(src, name)

	. -= NAMEOF(src, icon_state) // airlocks ignore icon_state and instead use get_airlock_overlay()
	return .

/obj/machinery/door/airlock/on_object_saved()
	var/data

	if(abandoned)
		data += "[data ? ",\n" : ""][/obj/effect/mapping_helpers/airlock/abandoned]"
	else // Only save these if not abandoned
		if(welded)
			data += "[data ? ",\n" : ""][/obj/effect/mapping_helpers/airlock/welded]"

		if(locked)
			data += "[data ? ",\n" : ""][/obj/effect/mapping_helpers/airlock/locked]"

	if(cyclelinkeddir)
		var/obj/effect/mapping_helpers/airlock/cyclelink_helper/helper_path = /obj/effect/mapping_helpers/airlock/cyclelink_helper
		var/dir_var = NAMEOF_TYPEPATH(helper_path, dir)
		data += "[data ? ",\n" : ""][helper_path]{\n\t[dir_var] = [cyclelinkeddir]\n\t}"

	if(closeOtherId)
		var/obj/effect/mapping_helpers/airlock/cyclelink_helper_multi/helper_path = /obj/effect/mapping_helpers/airlock/cyclelink_helper_multi
		var/cycle_id_var = NAMEOF_TYPEPATH(helper_path, cycle_id)
		data += "[data ? ",\n" : ""][helper_path]{\n\t[cycle_id_var] = \"[closeOtherId]\"\n\t}"

	if(unres_sides)
		for(var/heading in list(NORTH, SOUTH, EAST, WEST))
			if(unres_sides & heading)
				var/obj/effect/mapping_helpers/airlock/unres/helper_path = /obj/effect/mapping_helpers/airlock/unres
				var/dir_var = NAMEOF_TYPEPATH(helper_path, dir)
				data += "[data ? ",\n" : ""][helper_path]{\n\t[dir_var] = [heading]\n\t}"

	return data

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

/obj/structure/noticeboard/on_object_saved()
	var/data

	for(var/obj/item/paper/paper in contents)
/*
		if(TGM_MAX_OBJ_CHECK)
			continue
		TGM_OBJ_INCREMENT
*/

		var/metadata = generate_tgm_metadata(paper)
		data += "[data ? ",\n" : ""][paper.type][metadata]"
	return data


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
	. += NAMEOF(src, anchorable)
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
