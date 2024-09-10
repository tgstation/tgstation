/obj/item
	/// How much power would this item use?
	var/power_use_amount = POWER_CELL_USE_NORMAL


/// Use the power of an attached component that posesses power handling, will return the signal bitflag.
/obj/item/proc/item_use_power(use_amount, mob/user, check_only)
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(src, COMSIG_ITEM_POWER_USE, use_amount, user, check_only)
