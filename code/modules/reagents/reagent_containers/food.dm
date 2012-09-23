////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food
	possible_transfer_amounts = null
	volume = 50 //Sets the default container amount for all food items.

/obj/item/weapon/reagent_containers/food/New()
		..()
		src.pixel_x = rand(-5.0, 5)						//Randomizes postion slightly.
		src.pixel_y = rand(-5.0, 5)