////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food
	possible_transfer_amounts = list()
	volume = 50	//Sets the default container amount for all food items.
	container_type = INJECTABLE
	resistance_flags = FLAMMABLE

/obj/item/weapon/reagent_containers/food/Initialize(mapload)
	..()
	if(!mapload)
		pixel_x = rand(-5, 5)
		pixel_y = rand(-5, 5)