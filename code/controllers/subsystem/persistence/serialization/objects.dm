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
