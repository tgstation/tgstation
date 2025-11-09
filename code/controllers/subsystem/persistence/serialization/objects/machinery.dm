/obj/machinery/camera/get_save_vars()
	. = ..()
	. += NAMEOF(src, network)
	. += NAMEOF(src, c_tag)
	return .

/obj/machinery/button/get_save_vars()
	. = ..()
	. += NAMEOF(src, id)
	return .

/obj/machinery/conveyor_switch/get_save_vars()
	. = ..()
	. += NAMEOF(src, id)
	return .

/obj/machinery/conveyor/get_save_vars()
	. = ..()
	. += NAMEOF(src, id)
	return .

/obj/machinery/photocopier/get_save_vars()
	. = ..()
	. += NAMEOF(src, paper_stack)
	return .

/obj/machinery/light_switch/get_save_vars()
	. = ..()
	. -= NAMEOF(src, name)
	return .

/obj/machinery/requests_console/get_save_vars()
	. = ..()
	. -= NAMEOF(src, name)
	return .

/obj/machinery/airalarm/get_save_vars()
	. = ..()
	. -= NAMEOF(src, name)
	return .

/obj/item/vending_refill/get_save_vars()
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
