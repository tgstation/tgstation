/obj/item/stock_parts/cell/give(amount)
	. = ..()
	SEND_SIGNAL(src, COMSIG_CELL_GIVE, .)
