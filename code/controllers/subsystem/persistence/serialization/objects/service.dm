// seeds are easily spammable
/obj/item/seeds/get_save_vars(save_flags=ALL)
	return FALSE

// grown fruit is also spammable
/obj/item/food/grown/get_save_vars(save_flags=ALL)
	return FALSE

