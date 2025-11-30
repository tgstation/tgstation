/obj/machinery/door/password/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, password)
	return .

/obj/item/keycard/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, puzzle_id)
	return .

/obj/machinery/door/puzzle/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, puzzle_id)
	return .

/obj/item/pressure_plate/hologrid/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, reward)
	return .

/obj/structure/light_puzzle/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, queue_size)
	. += NAMEOF(src, puzzle_id)
	return .

/obj/machinery/puzzle/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, queue_size)
	. += NAMEOF(src, id)
	return .

/obj/machinery/puzzle/password/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, password)
	. += NAMEOF(src, tgui_text)
	. += NAMEOF(src, tgui_title)
	. += NAMEOF(src, input_max_len_is_pass)
	return .

/obj/machinery/puzzle/password/pin/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, pin_length)
	return .

/obj/structure/puzzle_blockade/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, id)
	return .

/obj/effect/puzzle_poddoor_open/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, queue_id)
	. += NAMEOF(src, id)
	return .

/obj/effect/decal/puzzle_dots/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, id)
	return .

/obj/effect/decal/cleanable/crayon/puzzle/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, puzzle_id)
	return .

/obj/item/paper/fluff/scrambled_pass/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, puzzle_id)
	return .
