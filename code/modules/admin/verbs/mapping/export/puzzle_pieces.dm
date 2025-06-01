/obj/item/keycard/get_save_vars()
	return ..() + NAMEOF(src, puzzle_id)

/obj/machinery/door/puzzle/get_save_vars()
	return ..() + NAMEOF(src, puzzle_id)

/obj/item/pressure_plate/hologrid/get_save_vars()
	return ..() + NAMEOF(src, reward)

/obj/structure/light_puzzle/get_save_vars()
	return ..() + list(NAMEOF(src, queue_size), NAMEOF(src, puzzle_id))

/obj/machinery/puzzle/get_save_vars()
	. = ..()
	. += NAMEOF(src, queue_size)
	. += NAMEOF(src, id)

/obj/machinery/puzzle/password/get_save_vars()
	. = ..()
	. += NAMEOF(src, password)
	. += NAMEOF(src, tgui_text)
	. += NAMEOF(src, tgui_title)
	. += NAMEOF(src, input_max_len_is_pass)

/obj/machinery/puzzle/password/pin/get_save_vars()
	. = ..()
	. += NAMEOF(src, pin_length)

/obj/structure/puzzle_blockade/get_save_vars()
	. = ..()
	. += NAMEOF(src, id)

/obj/effect/puzzle_poddoor_open/get_save_vars()
	. = ..()
	. += NAMEOF(src, queue_id)
	. += NAMEOF(src, id)

/obj/item/paper/fluff/scrambled_pass/get_save_vars()
	. = ..()
	. += NAMEOF(src, puzzle_id)

/obj/effect/decal/cleanable/crayon/puzzle/get_save_vars()
	. = ..()
	. += NAMEOF(src, puzzle_id)
