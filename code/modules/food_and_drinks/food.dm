////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////
/// Note: When adding food items with dummy parents, make sure to add
/// the parent to the exclusion list in code/__HELPERS/unsorted.dm's
/// get_random_food proc.
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_containers/food
	possible_transfer_amounts = list()
	volume = 50 //Sets the default container amount for all food items.
	reagent_flags = INJECTABLE
	resistance_flags = FLAMMABLE

/obj/item/reagent_containers/food/Initialize(mapload)
	. = ..()
	if(!mapload)
		pixel_x = rand(-5, 5)
		pixel_y = rand(-5, 5)
