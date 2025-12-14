/obj/item/holochip/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, credits)
	return .

/obj/item/stack/spacecash/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, amount)
	. += NAMEOF(src, value)
	return .

/obj/item/stack/spacecash/PersistentInitialize()
	. = ..()
	update_appearance()
