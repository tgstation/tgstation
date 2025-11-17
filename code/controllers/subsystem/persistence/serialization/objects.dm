///  B O T A N Y  ///

// both seeds and grown fruit are easily spammable with different variables
// also look into returning FALSE instead of empty list might be faster for all
// objects
/obj/item/seeds/get_save_vars(save_flags=ALL)
	return list()

/obj/item/food/grown/get_save_vars(save_flags=ALL)
	return list()



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


/obj/machinery/light/get_save_vars(save_flags=ALL)
	. = ..()
	. -= NAMEOF(src, icon_state) // the tube changes color depending on low power, which we don't want to track

	. += NAMEOF(src, has_mock_cell)
	. += NAMEOF(src, status)
	return .

/obj/structure/light_construct/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, stage)
	. += NAMEOF(src, fixture_type)
	return .


/obj/item/paper/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, show_written_words)
	. += NAMEOF(src, input_field_count)
	. += NAMEOF(src, default_raw_text)
	return .

/obj/item/paper/get_custom_save_vars(save_flags=ALL)
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
