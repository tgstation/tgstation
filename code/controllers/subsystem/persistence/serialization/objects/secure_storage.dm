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
