/obj/machinery/camera/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, network)
	. += NAMEOF(src, c_tag)
	return .

/obj/machinery/button/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, id)
	return .

/obj/machinery/conveyor_switch/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, id)
	return .

/obj/machinery/conveyor/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, id)
	return .

/obj/machinery/photocopier/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, paper_stack)
	return .

/// CHECK IF ID_TAGS ARE NEEDED FOR FIREDOOR/FIREALARMS
/obj/machinery/door/firedoor/get_save_vars(save_flags=ALL)
	. = ..()
	. -= NAMEOF(src, id_tag)
	return .

/obj/machinery/firealarm/get_save_vars(save_flags=ALL)
	. = ..()
	. -= NAMEOF(src, id_tag)
	return .

/obj/machinery/suit_storage_unit/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, density)
	. += NAMEOF(src, state_open)
	. += NAMEOF(src, panel_open)
	. += NAMEOF(src, locked)
	. += NAMEOF(src, safeties)
	// ignore card reader stuff for now
	return .

/obj/machinery/suit_storage_unit/get_custom_save_vars(save_flags=ALL)
	. = ..()
	// since these aren't inside contents only save the typepaths
	if(suit)
		.[NAMEOF(src, suit_type)] = suit.type
	if(helmet)
		.[NAMEOF(src, helmet_type)] = helmet.type
	if(mask)
		.[NAMEOF(src, mask_type)] = mask.type
	if(mod)
		.[NAMEOF(src, mod_type)] = mod.type
	if(storage)
		.[NAMEOF(src, storage_type)] = storage.type
	return .

/obj/machinery/suit_storage_unit/PersistentInitialize()
	. = ..()
	update_appearance()
