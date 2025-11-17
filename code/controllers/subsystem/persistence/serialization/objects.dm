///  B O T A N Y  ///

// both seeds and grown fruit are easily spammable with different variables
// also look into returning FALSE instead of empty list might be faster for all
// objects
/obj/item/seeds/get_save_vars(save_flags=ALL)
	return list()

/obj/item/food/grown/get_save_vars(save_flags=ALL)
	return list()
