/obj/item/stock_parts/power_store/give(amount)
	. = ..()
	SEND_SIGNAL(src, COMSIG_POWER_STORE_GIVE, .)
