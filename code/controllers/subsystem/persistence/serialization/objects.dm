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
		while(amount > 0)
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

/obj/machinery/atmospherics/get_save_vars()
	. = ..()
	. += NAMEOF(src, piping_layer)
	. += NAMEOF(src, pipe_color)
	return .

/obj/machinery/atmospherics/components/get_save_vars()
	. = ..()
	if(!override_naming)
		// Prevents saving the dynamic name with \proper due to it converting to "???"
		. -= NAMEOF(src, name)
	. += NAMEOF(src, welded)
	return .

/obj/item/pipe/get_save_vars()
	. = ..()
	. += NAMEOF(src, piping_layer)
	. += NAMEOF(src, pipe_color)
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

/obj/machinery/door/on_object_saved()
	var/data

	if(welded)
		data += "[data ? ",\n" : ""][/obj/effect/mapping_helpers/airlock/welded]"

	return data

/obj/machinery/door/airlock/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon_state) // airlocks ignore icon_state and instead use get_airlock_overlay()
	// TODO save the wire data but need to include states for cute wires, signalers attached to wires, etc.
	return .

/obj/machinery/door/password/get_save_vars()
	return ..() + NAMEOF(src, password)

/obj/machinery/door/poddoor/get_save_vars()
	return ..() + NAMEOF(src, id)

///  P U Z Z L E  ///

/obj/item/keycard/get_save_vars()
	return ..() + NAMEOF(src, puzzle_id)

/obj/machinery/door/puzzle/get_save_vars()
	return ..() + NAMEOF(src, puzzle_id)

/obj/item/pressure_plate/hologrid/get_save_vars()
	return ..() + NAMEOF(src, reward)

/obj/structure/light_puzzle/get_save_vars()
	return ..() + list(NAMEOF(src, queue_size), NAMEOF(src, puzzle_id))

/obj/machinery/puzzle/get_save_vars()
	return ..() + list(NAMEOF(src, queue_size), NAMEOF(src, id))

/obj/machinery/puzzle/password/get_save_vars()
	return ..() + list(NAMEOF(src, password), NAMEOF(src, tgui_text), NAMEOF(src, tgui_title), NAMEOF(src, input_max_len_is_pass))

/obj/machinery/puzzle/password/pin/get_save_vars()
	return ..() + NAMEOF(src, pin_length)

/obj/structure/puzzle_blockade/get_save_vars()
	return ..() + NAMEOF(src, id)

/obj/effect/puzzle_poddoor_open/get_save_vars()
	return ..() + list(NAMEOF(src, queue_id), NAMEOF(src, id))

/obj/effect/decal/puzzle_dots/get_save_vars()
	return ..() + NAMEOF(src, id)

/obj/effect/decal/cleanable/crayon/puzzle/get_save_vars()
	return ..() + NAMEOF(src, puzzle_id)

/obj/item/paper/fluff/scrambled_pass/get_save_vars()
	return ..() + NAMEOF(src, puzzle_id)

///  B U T T O N  ///

/obj/machinery/button/get_save_vars()
	return ..() + NAMEOF(src, id)

///  N O T I C E   B O A R D  ///

/obj/structure/noticeboard/on_object_saved()
	var/data

	for(var/obj/item/paper/paper in contents)
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
	return ..() - NAMEOF(src, icon)

/obj/item/photo/get_save_vars()
	return ..() - NAMEOF(src, icon)


///  A I R   A L A R M  ///

/obj/machinery/airalarm/get_save_vars()
	return ..() - NAMEOF(src, name)

///  P H O T O C O P I E R  ///

/obj/machinery/photocopier/get_save_vars()
	. = ..()
	. += NAMEOF(src, paper_stack)
	return .

/// P O W E R ///

/obj/machinery/power/apc/get_save_vars()
	. = ..()
	if(auto_name)
		. -= NAMEOF(src, name)
	. += NAMEOF(src, opened)
	. += NAMEOF(src, coverlocked)
	. += NAMEOF(src, lighting)
	. += NAMEOF(src, equipment)
	. += NAMEOF(src, environ)
	. += NAMEOF(src, cell_type)

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
